#!/usr/bin/env node
import { Project } from 'ts-morph'

import { getBundledJs } from './fns/esbuild/bundle'
import {
  getClientInitFileName,
  getClientInitSQL
} from './fns/plv8/startProc/client'
import {
  getInitFunction,
  getInitFunctionFilename,
  getInitFunctionName
} from './fns/plv8/startProc/init'
import { getParamsCall } from './fns/ts-morph/toJs'
import {
  getBindParams,
  getSQLFunction,
  getSQLFunctionFileName
} from './fns/ts-morph/toSQL'
import { writeFile } from './utils'

import arg = require('arg')
import fs = require('fs')

export type Mode = 'inline' | 'start_proc'

async function main() {
  // CLI Args
  const args = arg({
    '--write-esbuild-output': Boolean,
    '--input-file': String,
    '--output-folder': String,
    '--scope-prefix': String,
    '--pg-function-delimiter': String,
    '--fallback-type': String,
    '--mode': String,
    '--debug': Boolean,
  })

  if (args._.length === 0) {
    throw new Error(
      `Please specify a command. Available commands: generate, version`
    )
  }

  if (args._[0] === 'version') {
    const pkg = require('../package.json')
    console.log(`Version: ${pkg.version}`)
    process.exit(0)
  }

  const writeEsbuildOutput = args['--write-esbuild-output'] || false
  const inputFile = args['--input-file'] || 'input.ts'
  const outputFolder = args['--output-folder'] || 'plv8ify-dist'
  const scopePrefix = args['--scope-prefix'] || 'plv8ify'
  const pgFunctionDelimiter = args['--pg-function-delimiter'] || '$plv8ify$'
  const fallbackType = args['--fallback-type'] || 'JSONB'
  const mode = (args['--mode'] || 'inline') as Mode
  const debug = args['--debug'] || false

  fs.mkdirSync(outputFolder, { recursive: true })

  const bundledJs = await getBundledJs({
    mode,
    inputFile,
    outputFolder,
    scopePrefix: 'plv8ify',
  })

  // Optionally, write ESBuild output file
  if (writeEsbuildOutput) {
    writeFile(`${outputFolder}/output.js`, bundledJs)
  }

  // TS-Morph to parse the input Typescript file
  const project = new Project()
  const sourceFile = project.addSourceFileAtPath(inputFile)

  if (mode === 'start_proc') {
    // -- PLV8 + Server
    const initFunctionName = getInitFunctionName(scopePrefix)
    const initFunction = getInitFunction(initFunctionName, bundledJs)
    const initFileName = getInitFunctionFilename(outputFolder, initFunctionName)
    writeFile(initFileName, initFunction)

    // -- PLV8 + Client Initialization
    const clientInitSQL = getClientInitSQL()
    const startProcFileName = getClientInitFileName(outputFolder)
    writeFile(startProcFileName, clientInitSQL)
  }

  // Emit SQL files for each exported function
  const fns = sourceFile.getFunctions()
  fns.forEach((fnAst) => {
    if (!fnAst.isExported()) {
      return
    }

    const fnName = fnAst.getName()
    const scopedName = scopePrefix + '_' + fnName
    const params = fnAst.getParameters()

    // Js to SQL type mapping happens here
    const paramsBind = getBindParams({
      params,
      fallbackType,
      debug,
    })

    // Strip types, comma-separated param names from the AST to be printed in a function call
    const paramsCall = getParamsCall({
      params,
    })

    const SQLFunction = getSQLFunction({
      scopedName,
      fnName,
      pgFunctionDelimiter,
      paramsBind,
      paramsCall,
      fallbackType,
      mode,
      bundledJs,
    })

    const filename = getSQLFunctionFileName({
      outputFolder,
      scopedName,
    })
    writeFile(filename, SQLFunction)
  })
}

main()
