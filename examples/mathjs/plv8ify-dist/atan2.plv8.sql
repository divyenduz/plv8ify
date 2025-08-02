DROP FUNCTION IF EXISTS atan2(one float8,two float8);
CREATE OR REPLACE FUNCTION atan2(one float8,two float8) RETURNS float8 AS $plv8ify$
var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __markAsModule = (target) => __defProp(target, "__esModule", { value: true });
var __commonJS = (cb, mod2) => function __require() {
  return mod2 || (0, cb[__getOwnPropNames(cb)[0]])((mod2 = { exports: {} }).exports, mod2), mod2.exports;
};
var __reExport = (target, module, copyDefault, desc) => {
  if (module && typeof module === "object" || typeof module === "function") {
    for (let key of __getOwnPropNames(module))
      if (!__hasOwnProp.call(target, key) && (copyDefault || key !== "default"))
        __defProp(target, key, { get: () => module[key], enumerable: !(desc = __getOwnPropDesc(module, key)) || desc.enumerable });
  }
  return target;
};
var __toESM = (module, isNodeMode) => {
  return __reExport(__markAsModule(__defProp(module != null ? __create(__getProtoOf(module)) : {}, "default", !isNodeMode && module && module.__esModule ? { get: () => module.default, enumerable: true } : { value: module, enumerable: true })), module);
};

// node_modules/typed-function/lib/umd/typed-function.js
var require_typed_function = __commonJS({
  "node_modules/typed-function/lib/umd/typed-function.js"(exports, module) {
    (function(global, factory2) {
      typeof exports === "object" && typeof module !== "undefined" ? module.exports = factory2() : typeof define === "function" && define.amd ? define(factory2) : (global = typeof globalThis !== "undefined" ? globalThis : global || self, global["'typed'"] = factory2());
    })(exports, function() {
      "use strict";
      function ok() {
        return true;
      }
      function notOk() {
        return false;
      }
      function undef() {
        return void 0;
      }
      const NOT_TYPED_FUNCTION = "Argument is not a typed-function.";
      function create() {
        function isPlainObject2(x) {
          return typeof x === "object" && x !== null && x.constructor === Object;
        }
        const _types = [{
          name: "number",
          test: function(x) {
            return typeof x === "number";
          }
        }, {
          name: "string",
          test: function(x) {
            return typeof x === "string";
          }
        }, {
          name: "boolean",
          test: function(x) {
            return typeof x === "boolean";
          }
        }, {
          name: "Function",
          test: function(x) {
            return typeof x === "function";
          }
        }, {
          name: "Array",
          test: Array.isArray
        }, {
          name: "Date",
          test: function(x) {
            return x instanceof Date;
          }
        }, {
          name: "RegExp",
          test: function(x) {
            return x instanceof RegExp;
          }
        }, {
          name: "Object",
          test: isPlainObject2
        }, {
          name: "null",
          test: function(x) {
            return x === null;
          }
        }, {
          name: "undefined",
          test: function(x) {
            return x === void 0;
          }
        }];
        const anyType = {
          name: "any",
          test: ok,
          isAny: true
        };
        let typeMap;
        let typeList;
        let nConversions = 0;
        let typed2 = {
          createCount: 0
        };
        function findType(typeName) {
          const type = typeMap.get(typeName);
          if (type) {
            return type;
          }
          let message = 'Unknown type "' + typeName + '"';
          const name21 = typeName.toLowerCase();
          let otherName;
          for (otherName of typeList) {
            if (otherName.toLowerCase() === name21) {
              message += '. Did you mean "' + otherName + '" ?';
              break;
            }
          }
          throw new TypeError(message);
        }
        function addTypes(types) {
          let beforeSpec = arguments.length > 1 && arguments[1] !== void 0 ? arguments[1] : "any";
          const beforeIndex = beforeSpec ? findType(beforeSpec).index : typeList.length;
          const newTypes = [];
          for (let i = 0; i < types.length; ++i) {
            if (!types[i] || typeof types[i].name !== "string" || typeof types[i].test !== "function") {
              throw new TypeError("Object with properties {name: string, test: function} expected");
            }
            const typeName = types[i].name;
            if (typeMap.has(typeName)) {
              throw new TypeError('Duplicate type name "' + typeName + '"');
            }
            newTypes.push(typeName);
            typeMap.set(typeName, {
              name: typeName,
              test: types[i].test,
              isAny: types[i].isAny,
              index: beforeIndex + i,
              conversionsTo: []
            });
          }
          const affectedTypes = typeList.slice(beforeIndex);
          typeList = typeList.slice(0, beforeIndex).concat(newTypes).concat(affectedTypes);
          for (let i = beforeIndex + newTypes.length; i < typeList.length; ++i) {
            typeMap.get(typeList[i]).index = i;
          }
        }
        function clear() {
          typeMap = /* @__PURE__ */ new Map();
          typeList = [];
          nConversions = 0;
          addTypes([anyType], false);
        }
        clear();
        addTypes(_types);
        function clearConversions() {
          let typeName;
          for (typeName of typeList) {
            typeMap.get(typeName).conversionsTo = [];
          }
          nConversions = 0;
        }
        function findTypeNames(value) {
          const matches = typeList.filter((name21) => {
            const type = typeMap.get(name21);
            return !type.isAny && type.test(value);
          });
          if (matches.length) {
            return matches;
          }
          return ["any"];
        }
        function isTypedFunction(entity) {
          return entity && typeof entity === "function" && "_typedFunctionData" in entity;
        }
        function findSignature(fn, signature, options) {
          if (!isTypedFunction(fn)) {
            throw new TypeError(NOT_TYPED_FUNCTION);
          }
          const exact = options && options.exact;
          const stringSignature = Array.isArray(signature) ? signature.join(",") : signature;
          const params = parseSignature(stringSignature);
          const canonicalSignature = stringifyParams(params);
          if (!exact || canonicalSignature in fn.signatures) {
            const match = fn._typedFunctionData.signatureMap.get(canonicalSignature);
            if (match) {
              return match;
            }
          }
          const nParams = params.length;
          let remainingSignatures;
          if (exact) {
            remainingSignatures = [];
            let name21;
            for (name21 in fn.signatures) {
              remainingSignatures.push(fn._typedFunctionData.signatureMap.get(name21));
            }
          } else {
            remainingSignatures = fn._typedFunctionData.signatures;
          }
          for (let i = 0; i < nParams; ++i) {
            const want = params[i];
            const filteredSignatures = [];
            let possibility;
            for (possibility of remainingSignatures) {
              const have = getParamAtIndex(possibility.params, i);
              if (!have || want.restParam && !have.restParam) {
                continue;
              }
              if (!have.hasAny) {
                const haveTypes = paramTypeSet(have);
                if (want.types.some((wtype) => !haveTypes.has(wtype.name))) {
                  continue;
                }
              }
              filteredSignatures.push(possibility);
            }
            remainingSignatures = filteredSignatures;
            if (remainingSignatures.length === 0)
              break;
          }
          let candidate;
          for (candidate of remainingSignatures) {
            if (candidate.params.length <= nParams) {
              return candidate;
            }
          }
          throw new TypeError("Signature not found (signature: " + (fn.name || "unnamed") + "(" + stringifyParams(params, ", ") + "))");
        }
        function find(fn, signature, options) {
          return findSignature(fn, signature, options).implementation;
        }
        function convert(value, typeName) {
          const type = findType(typeName);
          if (type.test(value)) {
            return value;
          }
          const conversions = type.conversionsTo;
          if (conversions.length === 0) {
            throw new Error("There are no conversions to " + typeName + " defined.");
          }
          for (let i = 0; i < conversions.length; i++) {
            const fromType = findType(conversions[i].from);
            if (fromType.test(value)) {
              return conversions[i].convert(value);
            }
          }
          throw new Error("Cannot convert " + value + " to " + typeName);
        }
        function stringifyParams(params) {
          let separator = arguments.length > 1 && arguments[1] !== void 0 ? arguments[1] : ",";
          return params.map((p) => p.name).join(separator);
        }
        function parseParam(param) {
          const restParam = param.indexOf("...") === 0;
          const types = !restParam ? param : param.length > 3 ? param.slice(3) : "any";
          const typeDefs = types.split("|").map((s) => findType(s.trim()));
          let hasAny = false;
          let paramName = restParam ? "..." : "";
          const exactTypes = typeDefs.map(function(type) {
            hasAny = type.isAny || hasAny;
            paramName += type.name + "|";
            return {
              name: type.name,
              typeIndex: type.index,
              test: type.test,
              isAny: type.isAny,
              conversion: null,
              conversionIndex: -1
            };
          });
          return {
            types: exactTypes,
            name: paramName.slice(0, -1),
            hasAny,
            hasConversion: false,
            restParam
          };
        }
        function expandParam(param) {
          const typeNames = param.types.map((t) => t.name);
          const matchingConversions = availableConversions(typeNames);
          let hasAny = param.hasAny;
          let newName = param.name;
          const convertibleTypes = matchingConversions.map(function(conversion) {
            const type = findType(conversion.from);
            hasAny = type.isAny || hasAny;
            newName += "|" + conversion.from;
            return {
              name: conversion.from,
              typeIndex: type.index,
              test: type.test,
              isAny: type.isAny,
              conversion,
              conversionIndex: conversion.index
            };
          });
          return {
            types: param.types.concat(convertibleTypes),
            name: newName,
            hasAny,
            hasConversion: convertibleTypes.length > 0,
            restParam: param.restParam
          };
        }
        function paramTypeSet(param) {
          if (!param.typeSet) {
            param.typeSet = /* @__PURE__ */ new Set();
            param.types.forEach((type) => param.typeSet.add(type.name));
          }
          return param.typeSet;
        }
        function parseSignature(rawSignature) {
          const params = [];
          if (typeof rawSignature !== "string") {
            throw new TypeError("Signatures must be strings");
          }
          const signature = rawSignature.trim();
          if (signature === "") {
            return params;
          }
          const rawParams = signature.split(",");
          for (let i = 0; i < rawParams.length; ++i) {
            const parsedParam = parseParam(rawParams[i].trim());
            if (parsedParam.restParam && i !== rawParams.length - 1) {
              throw new SyntaxError('Unexpected rest parameter "' + rawParams[i] + '": only allowed for the last parameter');
            }
            if (parsedParam.types.length === 0) {
              return null;
            }
            params.push(parsedParam);
          }
          return params;
        }
        function hasRestParam(params) {
          const param = last(params);
          return param ? param.restParam : false;
        }
        function compileTest(param) {
          if (!param || param.types.length === 0) {
            return ok;
          } else if (param.types.length === 1) {
            return findType(param.types[0].name).test;
          } else if (param.types.length === 2) {
            const test0 = findType(param.types[0].name).test;
            const test1 = findType(param.types[1].name).test;
            return function or(x) {
              return test0(x) || test1(x);
            };
          } else {
            const tests = param.types.map(function(type) {
              return findType(type.name).test;
            });
            return function or(x) {
              for (let i = 0; i < tests.length; i++) {
                if (tests[i](x)) {
                  return true;
                }
              }
              return false;
            };
          }
        }
        function compileTests(params) {
          let tests, test0, test1;
          if (hasRestParam(params)) {
            tests = initial(params).map(compileTest);
            const varIndex = tests.length;
            const lastTest = compileTest(last(params));
            const testRestParam = function(args) {
              for (let i = varIndex; i < args.length; i++) {
                if (!lastTest(args[i])) {
                  return false;
                }
              }
              return true;
            };
            return function testArgs(args) {
              for (let i = 0; i < tests.length; i++) {
                if (!tests[i](args[i])) {
                  return false;
                }
              }
              return testRestParam(args) && args.length >= varIndex + 1;
            };
          } else {
            if (params.length === 0) {
              return function testArgs(args) {
                return args.length === 0;
              };
            } else if (params.length === 1) {
              test0 = compileTest(params[0]);
              return function testArgs(args) {
                return test0(args[0]) && args.length === 1;
              };
            } else if (params.length === 2) {
              test0 = compileTest(params[0]);
              test1 = compileTest(params[1]);
              return function testArgs(args) {
                return test0(args[0]) && test1(args[1]) && args.length === 2;
              };
            } else {
              tests = params.map(compileTest);
              return function testArgs(args) {
                for (let i = 0; i < tests.length; i++) {
                  if (!tests[i](args[i])) {
                    return false;
                  }
                }
                return args.length === tests.length;
              };
            }
          }
        }
        function getParamAtIndex(params, index) {
          return index < params.length ? params[index] : hasRestParam(params) ? last(params) : null;
        }
        function getTypeSetAtIndex(params, index) {
          const param = getParamAtIndex(params, index);
          if (!param) {
            return /* @__PURE__ */ new Set();
          }
          return paramTypeSet(param);
        }
        function isExactType(type) {
          return type.conversion === null || type.conversion === void 0;
        }
        function mergeExpectedParams(signatures, index) {
          const typeSet = /* @__PURE__ */ new Set();
          signatures.forEach((signature) => {
            const paramSet = getTypeSetAtIndex(signature.params, index);
            let name21;
            for (name21 of paramSet) {
              typeSet.add(name21);
            }
          });
          return typeSet.has("any") ? ["any"] : Array.from(typeSet);
        }
        function createError(name21, args, signatures) {
          let err, expected;
          const _name = name21 || "unnamed";
          let matchingSignatures = signatures;
          let index;
          for (index = 0; index < args.length; index++) {
            const nextMatchingDefs = [];
            matchingSignatures.forEach((signature) => {
              const param = getParamAtIndex(signature.params, index);
              const test = compileTest(param);
              if ((index < signature.params.length || hasRestParam(signature.params)) && test(args[index])) {
                nextMatchingDefs.push(signature);
              }
            });
            if (nextMatchingDefs.length === 0) {
              expected = mergeExpectedParams(matchingSignatures, index);
              if (expected.length > 0) {
                const actualTypes = findTypeNames(args[index]);
                err = new TypeError("Unexpected type of argument in function " + _name + " (expected: " + expected.join(" or ") + ", actual: " + actualTypes.join(" | ") + ", index: " + index + ")");
                err.data = {
                  category: "wrongType",
                  fn: _name,
                  index,
                  actual: actualTypes,
                  expected
                };
                return err;
              }
            } else {
              matchingSignatures = nextMatchingDefs;
            }
          }
          const lengths = matchingSignatures.map(function(signature) {
            return hasRestParam(signature.params) ? Infinity : signature.params.length;
          });
          if (args.length < Math.min.apply(null, lengths)) {
            expected = mergeExpectedParams(matchingSignatures, index);
            err = new TypeError("Too few arguments in function " + _name + " (expected: " + expected.join(" or ") + ", index: " + args.length + ")");
            err.data = {
              category: "tooFewArgs",
              fn: _name,
              index: args.length,
              expected
            };
            return err;
          }
          const maxLength = Math.max.apply(null, lengths);
          if (args.length > maxLength) {
            err = new TypeError("Too many arguments in function " + _name + " (expected: " + maxLength + ", actual: " + args.length + ")");
            err.data = {
              category: "tooManyArgs",
              fn: _name,
              index: args.length,
              expectedLength: maxLength
            };
            return err;
          }
          const argTypes = [];
          for (let i = 0; i < args.length; ++i) {
            argTypes.push(findTypeNames(args[i]).join("|"));
          }
          err = new TypeError('Arguments of type "' + argTypes.join(", ") + '" do not match any of the defined signatures of function ' + _name + ".");
          err.data = {
            category: "mismatch",
            actual: argTypes
          };
          return err;
        }
        function getLowestTypeIndex(param) {
          let min2 = typeList.length + 1;
          for (let i = 0; i < param.types.length; i++) {
            if (isExactType(param.types[i])) {
              min2 = Math.min(min2, param.types[i].typeIndex);
            }
          }
          return min2;
        }
        function getLowestConversionIndex(param) {
          let min2 = nConversions + 1;
          for (let i = 0; i < param.types.length; i++) {
            if (!isExactType(param.types[i])) {
              min2 = Math.min(min2, param.types[i].conversionIndex);
            }
          }
          return min2;
        }
        function compareParams(param1, param2) {
          if (param1.hasAny) {
            if (!param2.hasAny) {
              return 1;
            }
          } else if (param2.hasAny) {
            return -1;
          }
          if (param1.restParam) {
            if (!param2.restParam) {
              return 1;
            }
          } else if (param2.restParam) {
            return -1;
          }
          if (param1.hasConversion) {
            if (!param2.hasConversion) {
              return 1;
            }
          } else if (param2.hasConversion) {
            return -1;
          }
          const typeDiff = getLowestTypeIndex(param1) - getLowestTypeIndex(param2);
          if (typeDiff < 0) {
            return -1;
          }
          if (typeDiff > 0) {
            return 1;
          }
          const convDiff = getLowestConversionIndex(param1) - getLowestConversionIndex(param2);
          if (convDiff < 0) {
            return -1;
          }
          if (convDiff > 0) {
            return 1;
          }
          return 0;
        }
        function compareSignatures(signature1, signature2) {
          const pars1 = signature1.params;
          const pars2 = signature2.params;
          const last1 = last(pars1);
          const last2 = last(pars2);
          const hasRest1 = hasRestParam(pars1);
          const hasRest2 = hasRestParam(pars2);
          if (hasRest1 && last1.hasAny) {
            if (!hasRest2 || !last2.hasAny) {
              return 1;
            }
          } else if (hasRest2 && last2.hasAny) {
            return -1;
          }
          let any1 = 0;
          let conv1 = 0;
          let par;
          for (par of pars1) {
            if (par.hasAny)
              ++any1;
            if (par.hasConversion)
              ++conv1;
          }
          let any2 = 0;
          let conv2 = 0;
          for (par of pars2) {
            if (par.hasAny)
              ++any2;
            if (par.hasConversion)
              ++conv2;
          }
          if (any1 !== any2) {
            return any1 - any2;
          }
          if (hasRest1 && last1.hasConversion) {
            if (!hasRest2 || !last2.hasConversion) {
              return 1;
            }
          } else if (hasRest2 && last2.hasConversion) {
            return -1;
          }
          if (conv1 !== conv2) {
            return conv1 - conv2;
          }
          if (hasRest1) {
            if (!hasRest2) {
              return 1;
            }
          } else if (hasRest2) {
            return -1;
          }
          const lengthCriterion = (pars1.length - pars2.length) * (hasRest1 ? -1 : 1);
          if (lengthCriterion !== 0) {
            return lengthCriterion;
          }
          const comparisons = [];
          let tc = 0;
          for (let i = 0; i < pars1.length; ++i) {
            const thisComparison = compareParams(pars1[i], pars2[i]);
            comparisons.push(thisComparison);
            tc += thisComparison;
          }
          if (tc !== 0) {
            return tc;
          }
          let c;
          for (c of comparisons) {
            if (c !== 0) {
              return c;
            }
          }
          return 0;
        }
        function availableConversions(typeNames) {
          if (typeNames.length === 0) {
            return [];
          }
          const types = typeNames.map(findType);
          if (typeNames.length > 1) {
            types.sort((t1, t2) => t1.index - t2.index);
          }
          let matches = types[0].conversionsTo;
          if (typeNames.length === 1) {
            return matches;
          }
          matches = matches.concat([]);
          const knownTypes = new Set(typeNames);
          for (let i = 1; i < types.length; ++i) {
            let newMatch;
            for (newMatch of types[i].conversionsTo) {
              if (!knownTypes.has(newMatch.from)) {
                matches.push(newMatch);
                knownTypes.add(newMatch.from);
              }
            }
          }
          return matches;
        }
        function compileArgsPreprocessing(params, fn) {
          let fnConvert = fn;
          if (params.some((p) => p.hasConversion)) {
            const restParam = hasRestParam(params);
            const compiledConversions = params.map(compileArgConversion);
            fnConvert = function convertArgs() {
              const args = [];
              const last2 = restParam ? arguments.length - 1 : arguments.length;
              for (let i = 0; i < last2; i++) {
                args[i] = compiledConversions[i](arguments[i]);
              }
              if (restParam) {
                args[last2] = arguments[last2].map(compiledConversions[last2]);
              }
              return fn.apply(this, args);
            };
          }
          let fnPreprocess = fnConvert;
          if (hasRestParam(params)) {
            const offset = params.length - 1;
            fnPreprocess = function preprocessRestParams() {
              return fnConvert.apply(this, slice(arguments, 0, offset).concat([slice(arguments, offset)]));
            };
          }
          return fnPreprocess;
        }
        function compileArgConversion(param) {
          let test0, test1, conversion0, conversion1;
          const tests = [];
          const conversions = [];
          param.types.forEach(function(type) {
            if (type.conversion) {
              tests.push(findType(type.conversion.from).test);
              conversions.push(type.conversion.convert);
            }
          });
          switch (conversions.length) {
            case 0:
              return function convertArg(arg) {
                return arg;
              };
            case 1:
              test0 = tests[0];
              conversion0 = conversions[0];
              return function convertArg(arg) {
                if (test0(arg)) {
                  return conversion0(arg);
                }
                return arg;
              };
            case 2:
              test0 = tests[0];
              test1 = tests[1];
              conversion0 = conversions[0];
              conversion1 = conversions[1];
              return function convertArg(arg) {
                if (test0(arg)) {
                  return conversion0(arg);
                }
                if (test1(arg)) {
                  return conversion1(arg);
                }
                return arg;
              };
            default:
              return function convertArg(arg) {
                for (let i = 0; i < conversions.length; i++) {
                  if (tests[i](arg)) {
                    return conversions[i](arg);
                  }
                }
                return arg;
              };
          }
        }
        function splitParams(params) {
          function _splitParams(params2, index, paramsSoFar) {
            if (index < params2.length) {
              const param = params2[index];
              let resultingParams = [];
              if (param.restParam) {
                const exactTypes = param.types.filter(isExactType);
                if (exactTypes.length < param.types.length) {
                  resultingParams.push({
                    types: exactTypes,
                    name: "..." + exactTypes.map((t) => t.name).join("|"),
                    hasAny: exactTypes.some((t) => t.isAny),
                    hasConversion: false,
                    restParam: true
                  });
                }
                resultingParams.push(param);
              } else {
                resultingParams = param.types.map(function(type) {
                  return {
                    types: [type],
                    name: type.name,
                    hasAny: type.isAny,
                    hasConversion: type.conversion,
                    restParam: false
                  };
                });
              }
              return flatMap(resultingParams, function(nextParam) {
                return _splitParams(params2, index + 1, paramsSoFar.concat([nextParam]));
              });
            } else {
              return [paramsSoFar];
            }
          }
          return _splitParams(params, 0, []);
        }
        function conflicting(params1, params2) {
          const ii = Math.max(params1.length, params2.length);
          for (let i = 0; i < ii; i++) {
            const typeSet1 = getTypeSetAtIndex(params1, i);
            const typeSet2 = getTypeSetAtIndex(params2, i);
            let overlap = false;
            let name21;
            for (name21 of typeSet2) {
              if (typeSet1.has(name21)) {
                overlap = true;
                break;
              }
            }
            if (!overlap) {
              return false;
            }
          }
          const len1 = params1.length;
          const len2 = params2.length;
          const restParam1 = hasRestParam(params1);
          const restParam2 = hasRestParam(params2);
          return restParam1 ? restParam2 ? len1 === len2 : len2 >= len1 : restParam2 ? len1 >= len2 : len1 === len2;
        }
        function clearResolutions(functionList) {
          return functionList.map((fn) => {
            if (isReferToSelf(fn)) {
              return referToSelf(fn.referToSelf.callback);
            }
            if (isReferTo(fn)) {
              return makeReferTo(fn.referTo.references, fn.referTo.callback);
            }
            return fn;
          });
        }
        function collectResolutions(references, functionList, signatureMap) {
          const resolvedReferences = [];
          let reference;
          for (reference of references) {
            let resolution = signatureMap[reference];
            if (typeof resolution !== "number") {
              throw new TypeError('No definition for referenced signature "' + reference + '"');
            }
            resolution = functionList[resolution];
            if (typeof resolution !== "function") {
              return false;
            }
            resolvedReferences.push(resolution);
          }
          return resolvedReferences;
        }
        function resolveReferences(functionList, signatureMap, self2) {
          const resolvedFunctions = clearResolutions(functionList);
          const isResolved = new Array(resolvedFunctions.length).fill(false);
          let leftUnresolved = true;
          while (leftUnresolved) {
            leftUnresolved = false;
            let nothingResolved = true;
            for (let i = 0; i < resolvedFunctions.length; ++i) {
              if (isResolved[i])
                continue;
              const fn = resolvedFunctions[i];
              if (isReferToSelf(fn)) {
                resolvedFunctions[i] = fn.referToSelf.callback(self2);
                resolvedFunctions[i].referToSelf = fn.referToSelf;
                isResolved[i] = true;
                nothingResolved = false;
              } else if (isReferTo(fn)) {
                const resolvedReferences = collectResolutions(fn.referTo.references, resolvedFunctions, signatureMap);
                if (resolvedReferences) {
                  resolvedFunctions[i] = fn.referTo.callback.apply(this, resolvedReferences);
                  resolvedFunctions[i].referTo = fn.referTo;
                  isResolved[i] = true;
                  nothingResolved = false;
                } else {
                  leftUnresolved = true;
                }
              }
            }
            if (nothingResolved && leftUnresolved) {
              throw new SyntaxError("Circular reference detected in resolving typed.referTo");
            }
          }
          return resolvedFunctions;
        }
        function validateDeprecatedThis(signaturesMap) {
          const deprecatedThisRegex = /\bthis(\(|\.signatures\b)/;
          Object.keys(signaturesMap).forEach((signature) => {
            const fn = signaturesMap[signature];
            if (deprecatedThisRegex.test(fn.toString())) {
              throw new SyntaxError("Using `this` to self-reference a function is deprecated since typed-function@3. Use typed.referTo and typed.referToSelf instead.");
            }
          });
        }
        function createTypedFunction(name21, rawSignaturesMap) {
          typed2.createCount++;
          if (Object.keys(rawSignaturesMap).length === 0) {
            throw new SyntaxError("No signatures provided");
          }
          if (typed2.warnAgainstDeprecatedThis) {
            validateDeprecatedThis(rawSignaturesMap);
          }
          const parsedParams = [];
          const originalFunctions = [];
          const signaturesMap = {};
          const preliminarySignatures = [];
          let signature;
          for (signature in rawSignaturesMap) {
            if (!Object.prototype.hasOwnProperty.call(rawSignaturesMap, signature)) {
              continue;
            }
            const params = parseSignature(signature);
            if (!params)
              continue;
            parsedParams.forEach(function(pp) {
              if (conflicting(pp, params)) {
                throw new TypeError('Conflicting signatures "' + stringifyParams(pp) + '" and "' + stringifyParams(params) + '".');
              }
            });
            parsedParams.push(params);
            const functionIndex = originalFunctions.length;
            originalFunctions.push(rawSignaturesMap[signature]);
            const conversionParams = params.map(expandParam);
            let sp;
            for (sp of splitParams(conversionParams)) {
              const spName = stringifyParams(sp);
              preliminarySignatures.push({
                params: sp,
                name: spName,
                fn: functionIndex
              });
              if (sp.every((p) => !p.hasConversion)) {
                signaturesMap[spName] = functionIndex;
              }
            }
          }
          preliminarySignatures.sort(compareSignatures);
          const resolvedFunctions = resolveReferences(originalFunctions, signaturesMap, theTypedFn);
          let s;
          for (s in signaturesMap) {
            if (Object.prototype.hasOwnProperty.call(signaturesMap, s)) {
              signaturesMap[s] = resolvedFunctions[signaturesMap[s]];
            }
          }
          const signatures = [];
          const internalSignatureMap = /* @__PURE__ */ new Map();
          for (s of preliminarySignatures) {
            if (!internalSignatureMap.has(s.name)) {
              s.fn = resolvedFunctions[s.fn];
              signatures.push(s);
              internalSignatureMap.set(s.name, s);
            }
          }
          const ok0 = signatures[0] && signatures[0].params.length <= 2 && !hasRestParam(signatures[0].params);
          const ok1 = signatures[1] && signatures[1].params.length <= 2 && !hasRestParam(signatures[1].params);
          const ok2 = signatures[2] && signatures[2].params.length <= 2 && !hasRestParam(signatures[2].params);
          const ok3 = signatures[3] && signatures[3].params.length <= 2 && !hasRestParam(signatures[3].params);
          const ok4 = signatures[4] && signatures[4].params.length <= 2 && !hasRestParam(signatures[4].params);
          const ok5 = signatures[5] && signatures[5].params.length <= 2 && !hasRestParam(signatures[5].params);
          const allOk = ok0 && ok1 && ok2 && ok3 && ok4 && ok5;
          for (let i = 0; i < signatures.length; ++i) {
            signatures[i].test = compileTests(signatures[i].params);
          }
          const test00 = ok0 ? compileTest(signatures[0].params[0]) : notOk;
          const test10 = ok1 ? compileTest(signatures[1].params[0]) : notOk;
          const test20 = ok2 ? compileTest(signatures[2].params[0]) : notOk;
          const test30 = ok3 ? compileTest(signatures[3].params[0]) : notOk;
          const test40 = ok4 ? compileTest(signatures[4].params[0]) : notOk;
          const test50 = ok5 ? compileTest(signatures[5].params[0]) : notOk;
          const test01 = ok0 ? compileTest(signatures[0].params[1]) : notOk;
          const test11 = ok1 ? compileTest(signatures[1].params[1]) : notOk;
          const test21 = ok2 ? compileTest(signatures[2].params[1]) : notOk;
          const test31 = ok3 ? compileTest(signatures[3].params[1]) : notOk;
          const test41 = ok4 ? compileTest(signatures[4].params[1]) : notOk;
          const test51 = ok5 ? compileTest(signatures[5].params[1]) : notOk;
          for (let i = 0; i < signatures.length; ++i) {
            signatures[i].implementation = compileArgsPreprocessing(signatures[i].params, signatures[i].fn);
          }
          const fn0 = ok0 ? signatures[0].implementation : undef;
          const fn1 = ok1 ? signatures[1].implementation : undef;
          const fn2 = ok2 ? signatures[2].implementation : undef;
          const fn3 = ok3 ? signatures[3].implementation : undef;
          const fn4 = ok4 ? signatures[4].implementation : undef;
          const fn5 = ok5 ? signatures[5].implementation : undef;
          const len0 = ok0 ? signatures[0].params.length : -1;
          const len1 = ok1 ? signatures[1].params.length : -1;
          const len2 = ok2 ? signatures[2].params.length : -1;
          const len3 = ok3 ? signatures[3].params.length : -1;
          const len4 = ok4 ? signatures[4].params.length : -1;
          const len5 = ok5 ? signatures[5].params.length : -1;
          const iStart = allOk ? 6 : 0;
          const iEnd = signatures.length;
          const tests = signatures.map((s2) => s2.test);
          const fns = signatures.map((s2) => s2.implementation);
          const generic = function generic2() {
            for (let i = iStart; i < iEnd; i++) {
              if (tests[i](arguments)) {
                return fns[i].apply(this, arguments);
              }
            }
            return typed2.onMismatch(name21, arguments, signatures);
          };
          function theTypedFn(arg0, arg1) {
            if (arguments.length === len0 && test00(arg0) && test01(arg1)) {
              return fn0.apply(this, arguments);
            }
            if (arguments.length === len1 && test10(arg0) && test11(arg1)) {
              return fn1.apply(this, arguments);
            }
            if (arguments.length === len2 && test20(arg0) && test21(arg1)) {
              return fn2.apply(this, arguments);
            }
            if (arguments.length === len3 && test30(arg0) && test31(arg1)) {
              return fn3.apply(this, arguments);
            }
            if (arguments.length === len4 && test40(arg0) && test41(arg1)) {
              return fn4.apply(this, arguments);
            }
            if (arguments.length === len5 && test50(arg0) && test51(arg1)) {
              return fn5.apply(this, arguments);
            }
            return generic.apply(this, arguments);
          }
          try {
            Object.defineProperty(theTypedFn, "name", {
              value: name21
            });
          } catch (err) {
          }
          theTypedFn.signatures = signaturesMap;
          theTypedFn._typedFunctionData = {
            signatures,
            signatureMap: internalSignatureMap
          };
          return theTypedFn;
        }
        function _onMismatch(name21, args, signatures) {
          throw createError(name21, args, signatures);
        }
        function initial(arr) {
          return slice(arr, 0, arr.length - 1);
        }
        function last(arr) {
          return arr[arr.length - 1];
        }
        function slice(arr, start, end) {
          return Array.prototype.slice.call(arr, start, end);
        }
        function findInArray(arr, test) {
          for (let i = 0; i < arr.length; i++) {
            if (test(arr[i])) {
              return arr[i];
            }
          }
          return void 0;
        }
        function flatMap(arr, callback) {
          return Array.prototype.concat.apply([], arr.map(callback));
        }
        function referTo() {
          const references = initial(arguments).map((s) => stringifyParams(parseSignature(s)));
          const callback = last(arguments);
          if (typeof callback !== "function") {
            throw new TypeError("Callback function expected as last argument");
          }
          return makeReferTo(references, callback);
        }
        function makeReferTo(references, callback) {
          return {
            referTo: {
              references,
              callback
            }
          };
        }
        function referToSelf(callback) {
          if (typeof callback !== "function") {
            throw new TypeError("Callback function expected as first argument");
          }
          return {
            referToSelf: {
              callback
            }
          };
        }
        function isReferTo(objectOrFn) {
          return objectOrFn && typeof objectOrFn.referTo === "object" && Array.isArray(objectOrFn.referTo.references) && typeof objectOrFn.referTo.callback === "function";
        }
        function isReferToSelf(objectOrFn) {
          return objectOrFn && typeof objectOrFn.referToSelf === "object" && typeof objectOrFn.referToSelf.callback === "function";
        }
        function checkName(nameSoFar, newName) {
          if (!nameSoFar) {
            return newName;
          }
          if (newName && newName !== nameSoFar) {
            const err = new Error("Function names do not match (expected: " + nameSoFar + ", actual: " + newName + ")");
            err.data = {
              actual: newName,
              expected: nameSoFar
            };
            throw err;
          }
          return nameSoFar;
        }
        function getObjectName(obj) {
          let name21;
          for (const key in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, key) && (isTypedFunction(obj[key]) || typeof obj[key].signature === "string")) {
              name21 = checkName(name21, obj[key].name);
            }
          }
          return name21;
        }
        function mergeSignatures(dest, source) {
          let key;
          for (key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
              if (key in dest) {
                if (source[key] !== dest[key]) {
                  const err = new Error('Signature "' + key + '" is defined twice');
                  err.data = {
                    signature: key,
                    sourceFunction: source[key],
                    destFunction: dest[key]
                  };
                  throw err;
                }
              }
              dest[key] = source[key];
            }
          }
        }
        const saveTyped = typed2;
        typed2 = function(maybeName) {
          const named = typeof maybeName === "string";
          const start = named ? 1 : 0;
          let name21 = named ? maybeName : "";
          const allSignatures = {};
          for (let i = start; i < arguments.length; ++i) {
            const item = arguments[i];
            let theseSignatures = {};
            let thisName;
            if (typeof item === "function") {
              thisName = item.name;
              if (typeof item.signature === "string") {
                theseSignatures[item.signature] = item;
              } else if (isTypedFunction(item)) {
                theseSignatures = item.signatures;
              }
            } else if (isPlainObject2(item)) {
              theseSignatures = item;
              if (!named) {
                thisName = getObjectName(item);
              }
            }
            if (Object.keys(theseSignatures).length === 0) {
              const err = new TypeError("Argument to 'typed' at index " + i + " is not a (typed) function, nor an object with signatures as keys and functions as values.");
              err.data = {
                index: i,
                argument: item
              };
              throw err;
            }
            if (!named) {
              name21 = checkName(name21, thisName);
            }
            mergeSignatures(allSignatures, theseSignatures);
          }
          return createTypedFunction(name21 || "", allSignatures);
        };
        typed2.create = create;
        typed2.createCount = saveTyped.createCount;
        typed2.onMismatch = _onMismatch;
        typed2.throwMismatchError = _onMismatch;
        typed2.createError = createError;
        typed2.clear = clear;
        typed2.clearConversions = clearConversions;
        typed2.addTypes = addTypes;
        typed2._findType = findType;
        typed2.referTo = referTo;
        typed2.referToSelf = referToSelf;
        typed2.convert = convert;
        typed2.findSignature = findSignature;
        typed2.find = find;
        typed2.isTypedFunction = isTypedFunction;
        typed2.warnAgainstDeprecatedThis = true;
        typed2.addType = function(type, beforeObjectTest) {
          let before = "any";
          if (beforeObjectTest !== false && typeMap.has("Object")) {
            before = "Object";
          }
          typed2.addTypes([type], before);
        };
        function _validateConversion(conversion) {
          if (!conversion || typeof conversion.from !== "string" || typeof conversion.to !== "string" || typeof conversion.convert !== "function") {
            throw new TypeError("Object with properties {from: string, to: string, convert: function} expected");
          }
          if (conversion.to === conversion.from) {
            throw new SyntaxError('Illegal to define conversion from "' + conversion.from + '" to itself.');
          }
        }
        typed2.addConversion = function(conversion) {
          let options = arguments.length > 1 && arguments[1] !== void 0 ? arguments[1] : {
            override: false
          };
          _validateConversion(conversion);
          const to = findType(conversion.to);
          const existing = to.conversionsTo.find((other) => other.from === conversion.from);
          if (existing) {
            if (options && options.override) {
              typed2.removeConversion({
                from: existing.from,
                to: conversion.to,
                convert: existing.convert
              });
            } else {
              throw new Error('There is already a conversion from "' + conversion.from + '" to "' + to.name + '"');
            }
          }
          to.conversionsTo.push({
            from: conversion.from,
            convert: conversion.convert,
            index: nConversions++
          });
        };
        typed2.addConversions = function(conversions, options) {
          conversions.forEach((conversion) => typed2.addConversion(conversion, options));
        };
        typed2.removeConversion = function(conversion) {
          _validateConversion(conversion);
          const to = findType(conversion.to);
          const existingConversion = findInArray(to.conversionsTo, (c) => c.from === conversion.from);
          if (!existingConversion) {
            throw new Error("Attempt to remove nonexistent conversion from " + conversion.from + " to " + conversion.to);
          }
          if (existingConversion.convert !== conversion.convert) {
            throw new Error("Conversion to remove does not match existing conversion");
          }
          const index = to.conversionsTo.indexOf(existingConversion);
          to.conversionsTo.splice(index, 1);
        };
        typed2.resolve = function(tf, argList) {
          if (!isTypedFunction(tf)) {
            throw new TypeError(NOT_TYPED_FUNCTION);
          }
          const sigs = tf._typedFunctionData.signatures;
          for (let i = 0; i < sigs.length; ++i) {
            if (sigs[i].test(argList)) {
              return sigs[i];
            }
          }
          return null;
        };
        return typed2;
      }
      var typedFunction2 = create();
      return typedFunction2;
    });
  }
});

// node_modules/@babel/runtime/helpers/esm/extends.js
function _extends() {
  return _extends = Object.assign ? Object.assign.bind() : function(n) {
    for (var e = 1; e < arguments.length; e++) {
      var t = arguments[e];
      for (var r in t)
        ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]);
    }
    return n;
  }, _extends.apply(null, arguments);
}

// node_modules/mathjs/lib/esm/core/config.js
var DEFAULT_CONFIG = {
  epsilon: 1e-12,
  matrix: "Matrix",
  number: "number",
  precision: 64,
  predictable: false,
  randomSeed: null
};

// node_modules/mathjs/lib/esm/utils/is.js
function isNumber(x) {
  return typeof x === "number";
}
function isBigNumber(x) {
  if (!x || typeof x !== "object" || typeof x.constructor !== "function") {
    return false;
  }
  if (x.isBigNumber === true && typeof x.constructor.prototype === "object" && x.constructor.prototype.isBigNumber === true) {
    return true;
  }
  if (typeof x.constructor.isDecimal === "function" && x.constructor.isDecimal(x) === true) {
    return true;
  }
  return false;
}
function isComplex(x) {
  return x && typeof x === "object" && Object.getPrototypeOf(x).isComplex === true || false;
}
function isFraction(x) {
  return x && typeof x === "object" && Object.getPrototypeOf(x).isFraction === true || false;
}
function isUnit(x) {
  return x && x.constructor.prototype.isUnit === true || false;
}
function isString(x) {
  return typeof x === "string";
}
var isArray = Array.isArray;
function isMatrix(x) {
  return x && x.constructor.prototype.isMatrix === true || false;
}
function isCollection(x) {
  return Array.isArray(x) || isMatrix(x);
}
function isDenseMatrix(x) {
  return x && x.isDenseMatrix && x.constructor.prototype.isMatrix === true || false;
}
function isSparseMatrix(x) {
  return x && x.isSparseMatrix && x.constructor.prototype.isMatrix === true || false;
}
function isRange(x) {
  return x && x.constructor.prototype.isRange === true || false;
}
function isIndex(x) {
  return x && x.constructor.prototype.isIndex === true || false;
}
function isBoolean(x) {
  return typeof x === "boolean";
}
function isResultSet(x) {
  return x && x.constructor.prototype.isResultSet === true || false;
}
function isHelp(x) {
  return x && x.constructor.prototype.isHelp === true || false;
}
function isFunction(x) {
  return typeof x === "function";
}
function isDate(x) {
  return x instanceof Date;
}
function isRegExp(x) {
  return x instanceof RegExp;
}
function isObject(x) {
  return !!(x && typeof x === "object" && x.constructor === Object && !isComplex(x) && !isFraction(x));
}
function isNull(x) {
  return x === null;
}
function isUndefined(x) {
  return x === void 0;
}
function isAccessorNode(x) {
  return x && x.isAccessorNode === true && x.constructor.prototype.isNode === true || false;
}
function isArrayNode(x) {
  return x && x.isArrayNode === true && x.constructor.prototype.isNode === true || false;
}
function isAssignmentNode(x) {
  return x && x.isAssignmentNode === true && x.constructor.prototype.isNode === true || false;
}
function isBlockNode(x) {
  return x && x.isBlockNode === true && x.constructor.prototype.isNode === true || false;
}
function isConditionalNode(x) {
  return x && x.isConditionalNode === true && x.constructor.prototype.isNode === true || false;
}
function isConstantNode(x) {
  return x && x.isConstantNode === true && x.constructor.prototype.isNode === true || false;
}
function isFunctionAssignmentNode(x) {
  return x && x.isFunctionAssignmentNode === true && x.constructor.prototype.isNode === true || false;
}
function isFunctionNode(x) {
  return x && x.isFunctionNode === true && x.constructor.prototype.isNode === true || false;
}
function isIndexNode(x) {
  return x && x.isIndexNode === true && x.constructor.prototype.isNode === true || false;
}
function isNode(x) {
  return x && x.isNode === true && x.constructor.prototype.isNode === true || false;
}
function isObjectNode(x) {
  return x && x.isObjectNode === true && x.constructor.prototype.isNode === true || false;
}
function isOperatorNode(x) {
  return x && x.isOperatorNode === true && x.constructor.prototype.isNode === true || false;
}
function isParenthesisNode(x) {
  return x && x.isParenthesisNode === true && x.constructor.prototype.isNode === true || false;
}
function isRangeNode(x) {
  return x && x.isRangeNode === true && x.constructor.prototype.isNode === true || false;
}
function isRelationalNode(x) {
  return x && x.isRelationalNode === true && x.constructor.prototype.isNode === true || false;
}
function isSymbolNode(x) {
  return x && x.isSymbolNode === true && x.constructor.prototype.isNode === true || false;
}
function isChain(x) {
  return x && x.constructor.prototype.isChain === true || false;
}
function typeOf(x) {
  var t = typeof x;
  if (t === "object") {
    if (x === null)
      return "null";
    if (isBigNumber(x))
      return "BigNumber";
    if (x.constructor && x.constructor.name)
      return x.constructor.name;
    return "Object";
  }
  return t;
}

// node_modules/mathjs/lib/esm/utils/object.js
function clone(x) {
  var type = typeof x;
  if (type === "number" || type === "string" || type === "boolean" || x === null || x === void 0) {
    return x;
  }
  if (typeof x.clone === "function") {
    return x.clone();
  }
  if (Array.isArray(x)) {
    return x.map(function(value) {
      return clone(value);
    });
  }
  if (x instanceof Date)
    return new Date(x.valueOf());
  if (isBigNumber(x))
    return x;
  if (x instanceof RegExp)
    throw new TypeError("Cannot clone " + x);
  return mapObject(x, clone);
}
function mapObject(object, callback) {
  var clone3 = {};
  for (var key in object) {
    if (hasOwnProperty(object, key)) {
      clone3[key] = callback(object[key]);
    }
  }
  return clone3;
}
function extend(a, b) {
  for (var prop in b) {
    if (hasOwnProperty(b, prop)) {
      a[prop] = b[prop];
    }
  }
  return a;
}
function deepStrictEqual(a, b) {
  var prop, i, len;
  if (Array.isArray(a)) {
    if (!Array.isArray(b)) {
      return false;
    }
    if (a.length !== b.length) {
      return false;
    }
    for (i = 0, len = a.length; i < len; i++) {
      if (!deepStrictEqual(a[i], b[i])) {
        return false;
      }
    }
    return true;
  } else if (typeof a === "function") {
    return a === b;
  } else if (a instanceof Object) {
    if (Array.isArray(b) || !(b instanceof Object)) {
      return false;
    }
    for (prop in a) {
      if (!(prop in b) || !deepStrictEqual(a[prop], b[prop])) {
        return false;
      }
    }
    for (prop in b) {
      if (!(prop in a)) {
        return false;
      }
    }
    return true;
  } else {
    return a === b;
  }
}
function hasOwnProperty(object, property) {
  return object && Object.hasOwnProperty.call(object, property);
}
function pickShallow(object, properties) {
  var copy = {};
  for (var i = 0; i < properties.length; i++) {
    var key = properties[i];
    var value = object[key];
    if (value !== void 0) {
      copy[key] = value;
    }
  }
  return copy;
}

// node_modules/mathjs/lib/esm/core/function/config.js
var MATRIX_OPTIONS = ["Matrix", "Array"];
var NUMBER_OPTIONS = ["number", "BigNumber", "Fraction"];

// node_modules/mathjs/lib/esm/entry/configReadonly.js
var config = function config2(options) {
  if (options) {
    throw new Error("The global config is readonly. \nPlease create a mathjs instance if you want to change the default configuration. \nExample:\n\n  import { create, all } from 'mathjs';\n  const mathjs = create(all);\n  mathjs.config({ number: 'BigNumber' });\n");
  }
  return Object.freeze(DEFAULT_CONFIG);
};
_extends(config, DEFAULT_CONFIG, {
  MATRIX_OPTIONS,
  NUMBER_OPTIONS
});

// node_modules/mathjs/lib/esm/core/function/typed.js
var import_typed_function = __toESM(require_typed_function(), 1);

// node_modules/mathjs/lib/esm/utils/number.js
function isInteger(value) {
  if (typeof value === "boolean") {
    return true;
  }
  return isFinite(value) ? value === Math.round(value) : false;
}
function formatNumberToBase(n, base, size) {
  var prefixes = {
    2: "0b",
    8: "0o",
    16: "0x"
  };
  var prefix = prefixes[base];
  var suffix = "";
  if (size) {
    if (size < 1) {
      throw new Error("size must be in greater than 0");
    }
    if (!isInteger(size)) {
      throw new Error("size must be an integer");
    }
    if (n > 2 ** (size - 1) - 1 || n < -(2 ** (size - 1))) {
      throw new Error("Value must be in range [-2^".concat(size - 1, ", 2^").concat(size - 1, "-1]"));
    }
    if (!isInteger(n)) {
      throw new Error("Value must be an integer");
    }
    if (n < 0) {
      n = n + 2 ** size;
    }
    suffix = "i".concat(size);
  }
  var sign2 = "";
  if (n < 0) {
    n = -n;
    sign2 = "-";
  }
  return "".concat(sign2).concat(prefix).concat(n.toString(base)).concat(suffix);
}
function format(value, options) {
  if (typeof options === "function") {
    return options(value);
  }
  if (value === Infinity) {
    return "Infinity";
  } else if (value === -Infinity) {
    return "-Infinity";
  } else if (isNaN(value)) {
    return "NaN";
  }
  var notation = "auto";
  var precision;
  var wordSize;
  if (options) {
    if (options.notation) {
      notation = options.notation;
    }
    if (isNumber(options)) {
      precision = options;
    } else if (isNumber(options.precision)) {
      precision = options.precision;
    }
    if (options.wordSize) {
      wordSize = options.wordSize;
      if (typeof wordSize !== "number") {
        throw new Error('Option "wordSize" must be a number');
      }
    }
  }
  switch (notation) {
    case "fixed":
      return toFixed(value, precision);
    case "exponential":
      return toExponential(value, precision);
    case "engineering":
      return toEngineering(value, precision);
    case "bin":
      return formatNumberToBase(value, 2, wordSize);
    case "oct":
      return formatNumberToBase(value, 8, wordSize);
    case "hex":
      return formatNumberToBase(value, 16, wordSize);
    case "auto":
      return toPrecision(value, precision, options && options).replace(/((\.\d*?)(0+))($|e)/, function() {
        var digits2 = arguments[2];
        var e = arguments[4];
        return digits2 !== "." ? digits2 + e : e;
      });
    default:
      throw new Error('Unknown notation "' + notation + '". Choose "auto", "exponential", "fixed", "bin", "oct", or "hex.');
  }
}
function splitNumber(value) {
  var match = String(value).toLowerCase().match(/^(-?)(\d+\.?\d*)(e([+-]?\d+))?$/);
  if (!match) {
    throw new SyntaxError("Invalid number " + value);
  }
  var sign2 = match[1];
  var digits2 = match[2];
  var exponent = parseFloat(match[4] || "0");
  var dot = digits2.indexOf(".");
  exponent += dot !== -1 ? dot - 1 : digits2.length - 1;
  var coefficients = digits2.replace(".", "").replace(/^0*/, function(zeros2) {
    exponent -= zeros2.length;
    return "";
  }).replace(/0*$/, "").split("").map(function(d) {
    return parseInt(d);
  });
  if (coefficients.length === 0) {
    coefficients.push(0);
    exponent++;
  }
  return {
    sign: sign2,
    coefficients,
    exponent
  };
}
function toEngineering(value, precision) {
  if (isNaN(value) || !isFinite(value)) {
    return String(value);
  }
  var split = splitNumber(value);
  var rounded = roundDigits(split, precision);
  var e = rounded.exponent;
  var c = rounded.coefficients;
  var newExp = e % 3 === 0 ? e : e < 0 ? e - 3 - e % 3 : e - e % 3;
  if (isNumber(precision)) {
    while (precision > c.length || e - newExp + 1 > c.length) {
      c.push(0);
    }
  } else {
    var missingZeros = Math.abs(e - newExp) - (c.length - 1);
    for (var i = 0; i < missingZeros; i++) {
      c.push(0);
    }
  }
  var expDiff = Math.abs(e - newExp);
  var decimalIdx = 1;
  while (expDiff > 0) {
    decimalIdx++;
    expDiff--;
  }
  var decimals = c.slice(decimalIdx).join("");
  var decimalVal = isNumber(precision) && decimals.length || decimals.match(/[1-9]/) ? "." + decimals : "";
  var str = c.slice(0, decimalIdx).join("") + decimalVal + "e" + (e >= 0 ? "+" : "") + newExp.toString();
  return rounded.sign + str;
}
function toFixed(value, precision) {
  if (isNaN(value) || !isFinite(value)) {
    return String(value);
  }
  var splitValue = splitNumber(value);
  var rounded = typeof precision === "number" ? roundDigits(splitValue, splitValue.exponent + 1 + precision) : splitValue;
  var c = rounded.coefficients;
  var p = rounded.exponent + 1;
  var pp = p + (precision || 0);
  if (c.length < pp) {
    c = c.concat(zeros(pp - c.length));
  }
  if (p < 0) {
    c = zeros(-p + 1).concat(c);
    p = 1;
  }
  if (p < c.length) {
    c.splice(p, 0, p === 0 ? "0." : ".");
  }
  return rounded.sign + c.join("");
}
function toExponential(value, precision) {
  if (isNaN(value) || !isFinite(value)) {
    return String(value);
  }
  var split = splitNumber(value);
  var rounded = precision ? roundDigits(split, precision) : split;
  var c = rounded.coefficients;
  var e = rounded.exponent;
  if (c.length < precision) {
    c = c.concat(zeros(precision - c.length));
  }
  var first = c.shift();
  return rounded.sign + first + (c.length > 0 ? "." + c.join("") : "") + "e" + (e >= 0 ? "+" : "") + e;
}
function toPrecision(value, precision, options) {
  if (isNaN(value) || !isFinite(value)) {
    return String(value);
  }
  var lowerExp = options && options.lowerExp !== void 0 ? options.lowerExp : -3;
  var upperExp = options && options.upperExp !== void 0 ? options.upperExp : 5;
  var split = splitNumber(value);
  var rounded = precision ? roundDigits(split, precision) : split;
  if (rounded.exponent < lowerExp || rounded.exponent >= upperExp) {
    return toExponential(value, precision);
  } else {
    var c = rounded.coefficients;
    var e = rounded.exponent;
    if (c.length < precision) {
      c = c.concat(zeros(precision - c.length));
    }
    c = c.concat(zeros(e - c.length + 1 + (c.length < precision ? precision - c.length : 0)));
    c = zeros(-e).concat(c);
    var dot = e > 0 ? e : 0;
    if (dot < c.length - 1) {
      c.splice(dot + 1, 0, ".");
    }
    return rounded.sign + c.join("");
  }
}
function roundDigits(split, precision) {
  var rounded = {
    sign: split.sign,
    coefficients: split.coefficients,
    exponent: split.exponent
  };
  var c = rounded.coefficients;
  while (precision <= 0) {
    c.unshift(0);
    rounded.exponent++;
    precision++;
  }
  if (c.length > precision) {
    var removed = c.splice(precision, c.length - precision);
    if (removed[0] >= 5) {
      var i = precision - 1;
      c[i]++;
      while (c[i] === 10) {
        c.pop();
        if (i === 0) {
          c.unshift(0);
          rounded.exponent++;
          i++;
        }
        i--;
        c[i]++;
      }
    }
  }
  return rounded;
}
function zeros(length) {
  var arr = [];
  for (var i = 0; i < length; i++) {
    arr.push(0);
  }
  return arr;
}
function digits(value) {
  return value.toExponential().replace(/e.*$/, "").replace(/^0\.?0*|\./, "").length;
}
var DBL_EPSILON = Number.EPSILON || 2220446049250313e-31;
function nearlyEqual(x, y, epsilon) {
  if (epsilon === null || epsilon === void 0) {
    return x === y;
  }
  if (x === y) {
    return true;
  }
  if (isNaN(x) || isNaN(y)) {
    return false;
  }
  if (isFinite(x) && isFinite(y)) {
    var diff = Math.abs(x - y);
    if (diff < DBL_EPSILON) {
      return true;
    } else {
      return diff <= Math.max(Math.abs(x), Math.abs(y)) * epsilon;
    }
  }
  return false;
}

// node_modules/mathjs/lib/esm/utils/bignumber/formatter.js
function formatBigNumberToBase(n, base, size) {
  var BigNumberCtor = n.constructor;
  var big2 = new BigNumberCtor(2);
  var suffix = "";
  if (size) {
    if (size < 1) {
      throw new Error("size must be in greater than 0");
    }
    if (!isInteger(size)) {
      throw new Error("size must be an integer");
    }
    if (n.greaterThan(big2.pow(size - 1).sub(1)) || n.lessThan(big2.pow(size - 1).mul(-1))) {
      throw new Error("Value must be in range [-2^".concat(size - 1, ", 2^").concat(size - 1, "-1]"));
    }
    if (!n.isInteger()) {
      throw new Error("Value must be an integer");
    }
    if (n.lessThan(0)) {
      n = n.add(big2.pow(size));
    }
    suffix = "i".concat(size);
  }
  switch (base) {
    case 2:
      return "".concat(n.toBinary()).concat(suffix);
    case 8:
      return "".concat(n.toOctal()).concat(suffix);
    case 16:
      return "".concat(n.toHexadecimal()).concat(suffix);
    default:
      throw new Error("Base ".concat(base, " not supported "));
  }
}
function format2(value, options) {
  if (typeof options === "function") {
    return options(value);
  }
  if (!value.isFinite()) {
    return value.isNaN() ? "NaN" : value.gt(0) ? "Infinity" : "-Infinity";
  }
  var notation = "auto";
  var precision;
  var wordSize;
  if (options !== void 0) {
    if (options.notation) {
      notation = options.notation;
    }
    if (typeof options === "number") {
      precision = options;
    } else if (options.precision) {
      precision = options.precision;
    }
    if (options.wordSize) {
      wordSize = options.wordSize;
      if (typeof wordSize !== "number") {
        throw new Error('Option "wordSize" must be a number');
      }
    }
  }
  switch (notation) {
    case "fixed":
      return toFixed2(value, precision);
    case "exponential":
      return toExponential2(value, precision);
    case "engineering":
      return toEngineering2(value, precision);
    case "bin":
      return formatBigNumberToBase(value, 2, wordSize);
    case "oct":
      return formatBigNumberToBase(value, 8, wordSize);
    case "hex":
      return formatBigNumberToBase(value, 16, wordSize);
    case "auto": {
      var lowerExp = options && options.lowerExp !== void 0 ? options.lowerExp : -3;
      var upperExp = options && options.upperExp !== void 0 ? options.upperExp : 5;
      if (value.isZero())
        return "0";
      var str;
      var rounded = value.toSignificantDigits(precision);
      var exp2 = rounded.e;
      if (exp2 >= lowerExp && exp2 < upperExp) {
        str = rounded.toFixed();
      } else {
        str = toExponential2(value, precision);
      }
      return str.replace(/((\.\d*?)(0+))($|e)/, function() {
        var digits2 = arguments[2];
        var e = arguments[4];
        return digits2 !== "." ? digits2 + e : e;
      });
    }
    default:
      throw new Error('Unknown notation "' + notation + '". Choose "auto", "exponential", "fixed", "bin", "oct", or "hex.');
  }
}
function toEngineering2(value, precision) {
  var e = value.e;
  var newExp = e % 3 === 0 ? e : e < 0 ? e - 3 - e % 3 : e - e % 3;
  var valueWithoutExp = value.mul(Math.pow(10, -newExp));
  var valueStr = valueWithoutExp.toPrecision(precision);
  if (valueStr.indexOf("e") !== -1) {
    valueStr = valueWithoutExp.toString();
  }
  return valueStr + "e" + (e >= 0 ? "+" : "") + newExp.toString();
}
function toExponential2(value, precision) {
  if (precision !== void 0) {
    return value.toExponential(precision - 1);
  } else {
    return value.toExponential();
  }
}
function toFixed2(value, precision) {
  return value.toFixed(precision);
}

// node_modules/mathjs/lib/esm/utils/string.js
function format3(value, options) {
  var result = _format(value, options);
  if (options && typeof options === "object" && "truncate" in options && result.length > options.truncate) {
    return result.substring(0, options.truncate - 3) + "...";
  }
  return result;
}
function _format(value, options) {
  if (typeof value === "number") {
    return format(value, options);
  }
  if (isBigNumber(value)) {
    return format2(value, options);
  }
  if (looksLikeFraction(value)) {
    if (!options || options.fraction !== "decimal") {
      return value.s * value.n + "/" + value.d;
    } else {
      return value.toString();
    }
  }
  if (Array.isArray(value)) {
    return formatArray(value, options);
  }
  if (isString(value)) {
    return '"' + value + '"';
  }
  if (typeof value === "function") {
    return value.syntax ? String(value.syntax) : "function";
  }
  if (value && typeof value === "object") {
    if (typeof value.format === "function") {
      return value.format(options);
    } else if (value && value.toString(options) !== {}.toString()) {
      return value.toString(options);
    } else {
      var entries = Object.keys(value).map((key) => {
        return '"' + key + '": ' + format3(value[key], options);
      });
      return "{" + entries.join(", ") + "}";
    }
  }
  return String(value);
}
function formatArray(array, options) {
  if (Array.isArray(array)) {
    var str = "[";
    var len = array.length;
    for (var i = 0; i < len; i++) {
      if (i !== 0) {
        str += ", ";
      }
      str += formatArray(array[i], options);
    }
    str += "]";
    return str;
  } else {
    return format3(array, options);
  }
}
function looksLikeFraction(value) {
  return value && typeof value === "object" && typeof value.s === "number" && typeof value.n === "number" && typeof value.d === "number" || false;
}

// node_modules/mathjs/lib/esm/error/DimensionError.js
function DimensionError(actual, expected, relation) {
  if (!(this instanceof DimensionError)) {
    throw new SyntaxError("Constructor must be called with the new operator");
  }
  this.actual = actual;
  this.expected = expected;
  this.relation = relation;
  this.message = "Dimension mismatch (" + (Array.isArray(actual) ? "[" + actual.join(", ") + "]" : actual) + " " + (this.relation || "!=") + " " + (Array.isArray(expected) ? "[" + expected.join(", ") + "]" : expected) + ")";
  this.stack = new Error().stack;
}
DimensionError.prototype = new RangeError();
DimensionError.prototype.constructor = RangeError;
DimensionError.prototype.name = "DimensionError";
DimensionError.prototype.isDimensionError = true;

// node_modules/mathjs/lib/esm/error/IndexError.js
function IndexError(index, min2, max2) {
  if (!(this instanceof IndexError)) {
    throw new SyntaxError("Constructor must be called with the new operator");
  }
  this.index = index;
  if (arguments.length < 3) {
    this.min = 0;
    this.max = min2;
  } else {
    this.min = min2;
    this.max = max2;
  }
  if (this.min !== void 0 && this.index < this.min) {
    this.message = "Index out of range (" + this.index + " < " + this.min + ")";
  } else if (this.max !== void 0 && this.index >= this.max) {
    this.message = "Index out of range (" + this.index + " > " + (this.max - 1) + ")";
  } else {
    this.message = "Index out of range (" + this.index + ")";
  }
  this.stack = new Error().stack;
}
IndexError.prototype = new RangeError();
IndexError.prototype.constructor = RangeError;
IndexError.prototype.name = "IndexError";
IndexError.prototype.isIndexError = true;

// node_modules/mathjs/lib/esm/utils/array.js
function arraySize(x) {
  var s = [];
  while (Array.isArray(x)) {
    s.push(x.length);
    x = x[0];
  }
  return s;
}
function _validate(array, size, dim) {
  var i;
  var len = array.length;
  if (len !== size[dim]) {
    throw new DimensionError(len, size[dim]);
  }
  if (dim < size.length - 1) {
    var dimNext = dim + 1;
    for (i = 0; i < len; i++) {
      var child = array[i];
      if (!Array.isArray(child)) {
        throw new DimensionError(size.length - 1, size.length, "<");
      }
      _validate(array[i], size, dimNext);
    }
  } else {
    for (i = 0; i < len; i++) {
      if (Array.isArray(array[i])) {
        throw new DimensionError(size.length + 1, size.length, ">");
      }
    }
  }
}
function validate(array, size) {
  var isScalar = size.length === 0;
  if (isScalar) {
    if (Array.isArray(array)) {
      throw new DimensionError(array.length, 0);
    }
  } else {
    _validate(array, size, 0);
  }
}
function validateIndex(index, length) {
  if (!isNumber(index) || !isInteger(index)) {
    throw new TypeError("Index must be an integer (value: " + index + ")");
  }
  if (index < 0 || typeof length === "number" && index >= length) {
    throw new IndexError(index, length);
  }
}
function resize(array, size, defaultValue) {
  if (!Array.isArray(array) || !Array.isArray(size)) {
    throw new TypeError("Array expected");
  }
  if (size.length === 0) {
    throw new Error("Resizing to scalar is not supported");
  }
  size.forEach(function(value) {
    if (!isNumber(value) || !isInteger(value) || value < 0) {
      throw new TypeError("Invalid size, must contain positive integers (size: " + format3(size) + ")");
    }
  });
  var _defaultValue = defaultValue !== void 0 ? defaultValue : 0;
  _resize(array, size, 0, _defaultValue);
  return array;
}
function _resize(array, size, dim, defaultValue) {
  var i;
  var elem;
  var oldLen = array.length;
  var newLen = size[dim];
  var minLen = Math.min(oldLen, newLen);
  array.length = newLen;
  if (dim < size.length - 1) {
    var dimNext = dim + 1;
    for (i = 0; i < minLen; i++) {
      elem = array[i];
      if (!Array.isArray(elem)) {
        elem = [elem];
        array[i] = elem;
      }
      _resize(elem, size, dimNext, defaultValue);
    }
    for (i = minLen; i < newLen; i++) {
      elem = [];
      array[i] = elem;
      _resize(elem, size, dimNext, defaultValue);
    }
  } else {
    for (i = 0; i < minLen; i++) {
      while (Array.isArray(array[i])) {
        array[i] = array[i][0];
      }
    }
    for (i = minLen; i < newLen; i++) {
      array[i] = defaultValue;
    }
  }
}
function reshape(array, sizes) {
  var flatArray = flatten(array);
  var currentLength = flatArray.length;
  if (!Array.isArray(array) || !Array.isArray(sizes)) {
    throw new TypeError("Array expected");
  }
  if (sizes.length === 0) {
    throw new DimensionError(0, currentLength, "!=");
  }
  sizes = processSizesWildcard(sizes, currentLength);
  var newLength = product(sizes);
  if (currentLength !== newLength) {
    throw new DimensionError(newLength, currentLength, "!=");
  }
  try {
    return _reshape(flatArray, sizes);
  } catch (e) {
    if (e instanceof DimensionError) {
      throw new DimensionError(newLength, currentLength, "!=");
    }
    throw e;
  }
}
function processSizesWildcard(sizes, currentLength) {
  var newLength = product(sizes);
  var processedSizes = sizes.slice();
  var WILDCARD = -1;
  var wildCardIndex = sizes.indexOf(WILDCARD);
  var isMoreThanOneWildcard = sizes.indexOf(WILDCARD, wildCardIndex + 1) >= 0;
  if (isMoreThanOneWildcard) {
    throw new Error("More than one wildcard in sizes");
  }
  var hasWildcard = wildCardIndex >= 0;
  var canReplaceWildcard = currentLength % newLength === 0;
  if (hasWildcard) {
    if (canReplaceWildcard) {
      processedSizes[wildCardIndex] = -currentLength / newLength;
    } else {
      throw new Error("Could not replace wildcard, since " + currentLength + " is no multiple of " + -newLength);
    }
  }
  return processedSizes;
}
function product(array) {
  return array.reduce((prev, curr) => prev * curr, 1);
}
function _reshape(array, sizes) {
  var tmpArray = array;
  var tmpArray2;
  for (var sizeIndex = sizes.length - 1; sizeIndex > 0; sizeIndex--) {
    var size = sizes[sizeIndex];
    tmpArray2 = [];
    var length = tmpArray.length / size;
    for (var i = 0; i < length; i++) {
      tmpArray2.push(tmpArray.slice(i * size, (i + 1) * size));
    }
    tmpArray = tmpArray2;
  }
  return tmpArray;
}
function unsqueeze(array, dims, outer, size) {
  var s = size || arraySize(array);
  if (outer) {
    for (var i = 0; i < outer; i++) {
      array = [array];
      s.unshift(1);
    }
  }
  array = _unsqueeze(array, dims, 0);
  while (s.length < dims) {
    s.push(1);
  }
  return array;
}
function _unsqueeze(array, dims, dim) {
  var i, ii;
  if (Array.isArray(array)) {
    var next = dim + 1;
    for (i = 0, ii = array.length; i < ii; i++) {
      array[i] = _unsqueeze(array[i], dims, next);
    }
  } else {
    for (var d = dim; d < dims; d++) {
      array = [array];
    }
  }
  return array;
}
function flatten(array) {
  if (!Array.isArray(array)) {
    return array;
  }
  var flat = [];
  array.forEach(function callback(value) {
    if (Array.isArray(value)) {
      value.forEach(callback);
    } else {
      flat.push(value);
    }
  });
  return flat;
}
function getArrayDataType(array, typeOf2) {
  var type;
  var length = 0;
  for (var i = 0; i < array.length; i++) {
    var item = array[i];
    var isArray2 = Array.isArray(item);
    if (i === 0 && isArray2) {
      length = item.length;
    }
    if (isArray2 && item.length !== length) {
      return void 0;
    }
    var itemType = isArray2 ? getArrayDataType(item, typeOf2) : typeOf2(item);
    if (type === void 0) {
      type = itemType;
    } else if (type !== itemType) {
      return "mixed";
    } else {
    }
  }
  return type;
}

// node_modules/mathjs/lib/esm/utils/factory.js
function factory(name21, dependencies21, create, meta) {
  function assertAndCreate(scope) {
    var deps = pickShallow(scope, dependencies21.map(stripOptionalNotation));
    assertDependencies(name21, dependencies21, scope);
    return create(deps);
  }
  assertAndCreate.isFactory = true;
  assertAndCreate.fn = name21;
  assertAndCreate.dependencies = dependencies21.slice().sort();
  if (meta) {
    assertAndCreate.meta = meta;
  }
  return assertAndCreate;
}
function assertDependencies(name21, dependencies21, scope) {
  var allDefined = dependencies21.filter((dependency) => !isOptionalDependency(dependency)).every((dependency) => scope[dependency] !== void 0);
  if (!allDefined) {
    var missingDependencies = dependencies21.filter((dependency) => scope[dependency] === void 0);
    throw new Error('Cannot create function "'.concat(name21, '", ') + "some dependencies are missing: ".concat(missingDependencies.map((d) => '"'.concat(d, '"')).join(", "), "."));
  }
}
function isOptionalDependency(dependency) {
  return dependency && dependency[0] === "?";
}
function stripOptionalNotation(dependency) {
  return dependency && dependency[0] === "?" ? dependency.slice(1) : dependency;
}

// node_modules/mathjs/lib/esm/utils/customs.js
function getSafeProperty(object, prop) {
  if (isPlainObject(object) && isSafeProperty(object, prop)) {
    return object[prop];
  }
  if (typeof object[prop] === "function" && isSafeMethod(object, prop)) {
    throw new Error('Cannot access method "' + prop + '" as a property');
  }
  throw new Error('No access to property "' + prop + '"');
}
function setSafeProperty(object, prop, value) {
  if (isPlainObject(object) && isSafeProperty(object, prop)) {
    object[prop] = value;
    return value;
  }
  throw new Error('No access to property "' + prop + '"');
}
function hasSafeProperty(object, prop) {
  return prop in object;
}
function isSafeProperty(object, prop) {
  if (!object || typeof object !== "object") {
    return false;
  }
  if (hasOwnProperty(safeNativeProperties, prop)) {
    return true;
  }
  if (prop in Object.prototype) {
    return false;
  }
  if (prop in Function.prototype) {
    return false;
  }
  return true;
}
function isSafeMethod(object, method) {
  if (object === null || object === void 0 || typeof object[method] !== "function") {
    return false;
  }
  if (hasOwnProperty(object, method) && Object.getPrototypeOf && method in Object.getPrototypeOf(object)) {
    return false;
  }
  if (hasOwnProperty(safeNativeMethods, method)) {
    return true;
  }
  if (method in Object.prototype) {
    return false;
  }
  if (method in Function.prototype) {
    return false;
  }
  return true;
}
function isPlainObject(object) {
  return typeof object === "object" && object && object.constructor === Object;
}
var safeNativeProperties = {
  length: true,
  name: true
};
var safeNativeMethods = {
  toString: true,
  valueOf: true,
  toLocaleString: true
};

// node_modules/mathjs/lib/esm/utils/map.js
var ObjectWrappingMap = class {
  constructor(object) {
    this.wrappedObject = object;
  }
  keys() {
    return Object.keys(this.wrappedObject);
  }
  get(key) {
    return getSafeProperty(this.wrappedObject, key);
  }
  set(key, value) {
    setSafeProperty(this.wrappedObject, key, value);
    return this;
  }
  has(key) {
    return hasSafeProperty(this.wrappedObject, key);
  }
};
function isMap(object) {
  if (!object) {
    return false;
  }
  return object instanceof Map || object instanceof ObjectWrappingMap || typeof object.set === "function" && typeof object.get === "function" && typeof object.keys === "function" && typeof object.has === "function";
}

// node_modules/mathjs/lib/esm/core/function/typed.js
var _createTyped2 = function _createTyped() {
  _createTyped2 = import_typed_function.default.create;
  return import_typed_function.default;
};
var dependencies = ["?BigNumber", "?Complex", "?DenseMatrix", "?Fraction"];
var createTyped = /* @__PURE__ */ factory("typed", dependencies, function createTyped2(_ref) {
  var {
    BigNumber: BigNumber2,
    Complex: Complex3,
    DenseMatrix: DenseMatrix2,
    Fraction: Fraction3
  } = _ref;
  var typed2 = _createTyped2();
  typed2.clear();
  typed2.addTypes([
    {
      name: "number",
      test: isNumber
    },
    {
      name: "Complex",
      test: isComplex
    },
    {
      name: "BigNumber",
      test: isBigNumber
    },
    {
      name: "Fraction",
      test: isFraction
    },
    {
      name: "Unit",
      test: isUnit
    },
    {
      name: "identifier",
      test: (s) => isString && /^(?:[A-Za-z\xAA\xB5\xBA\xC0-\xD6\xD8-\xF6\xF8-\u02C1\u02C6-\u02D1\u02E0-\u02E4\u02EC\u02EE\u0370-\u0374\u0376\u0377\u037A-\u037D\u037F\u0386\u0388-\u038A\u038C\u038E-\u03A1\u03A3-\u03F5\u03F7-\u0481\u048A-\u052F\u0531-\u0556\u0559\u0560-\u0588\u05D0-\u05EA\u05EF-\u05F2\u0620-\u064A\u066E\u066F\u0671-\u06D3\u06D5\u06E5\u06E6\u06EE\u06EF\u06FA-\u06FC\u06FF\u0710\u0712-\u072F\u074D-\u07A5\u07B1\u07CA-\u07EA\u07F4\u07F5\u07FA\u0800-\u0815\u081A\u0824\u0828\u0840-\u0858\u0860-\u086A\u0870-\u0887\u0889-\u088E\u08A0-\u08C9\u0904-\u0939\u093D\u0950\u0958-\u0961\u0971-\u0980\u0985-\u098C\u098F\u0990\u0993-\u09A8\u09AA-\u09B0\u09B2\u09B6-\u09B9\u09BD\u09CE\u09DC\u09DD\u09DF-\u09E1\u09F0\u09F1\u09FC\u0A05-\u0A0A\u0A0F\u0A10\u0A13-\u0A28\u0A2A-\u0A30\u0A32\u0A33\u0A35\u0A36\u0A38\u0A39\u0A59-\u0A5C\u0A5E\u0A72-\u0A74\u0A85-\u0A8D\u0A8F-\u0A91\u0A93-\u0AA8\u0AAA-\u0AB0\u0AB2\u0AB3\u0AB5-\u0AB9\u0ABD\u0AD0\u0AE0\u0AE1\u0AF9\u0B05-\u0B0C\u0B0F\u0B10\u0B13-\u0B28\u0B2A-\u0B30\u0B32\u0B33\u0B35-\u0B39\u0B3D\u0B5C\u0B5D\u0B5F-\u0B61\u0B71\u0B83\u0B85-\u0B8A\u0B8E-\u0B90\u0B92-\u0B95\u0B99\u0B9A\u0B9C\u0B9E\u0B9F\u0BA3\u0BA4\u0BA8-\u0BAA\u0BAE-\u0BB9\u0BD0\u0C05-\u0C0C\u0C0E-\u0C10\u0C12-\u0C28\u0C2A-\u0C39\u0C3D\u0C58-\u0C5A\u0C5D\u0C60\u0C61\u0C80\u0C85-\u0C8C\u0C8E-\u0C90\u0C92-\u0CA8\u0CAA-\u0CB3\u0CB5-\u0CB9\u0CBD\u0CDD\u0CDE\u0CE0\u0CE1\u0CF1\u0CF2\u0D04-\u0D0C\u0D0E-\u0D10\u0D12-\u0D3A\u0D3D\u0D4E\u0D54-\u0D56\u0D5F-\u0D61\u0D7A-\u0D7F\u0D85-\u0D96\u0D9A-\u0DB1\u0DB3-\u0DBB\u0DBD\u0DC0-\u0DC6\u0E01-\u0E30\u0E32\u0E33\u0E40-\u0E46\u0E81\u0E82\u0E84\u0E86-\u0E8A\u0E8C-\u0EA3\u0EA5\u0EA7-\u0EB0\u0EB2\u0EB3\u0EBD\u0EC0-\u0EC4\u0EC6\u0EDC-\u0EDF\u0F00\u0F40-\u0F47\u0F49-\u0F6C\u0F88-\u0F8C\u1000-\u102A\u103F\u1050-\u1055\u105A-\u105D\u1061\u1065\u1066\u106E-\u1070\u1075-\u1081\u108E\u10A0-\u10C5\u10C7\u10CD\u10D0-\u10FA\u10FC-\u1248\u124A-\u124D\u1250-\u1256\u1258\u125A-\u125D\u1260-\u1288\u128A-\u128D\u1290-\u12B0\u12B2-\u12B5\u12B8-\u12BE\u12C0\u12C2-\u12C5\u12C8-\u12D6\u12D8-\u1310\u1312-\u1315\u1318-\u135A\u1380-\u138F\u13A0-\u13F5\u13F8-\u13FD\u1401-\u166C\u166F-\u167F\u1681-\u169A\u16A0-\u16EA\u16F1-\u16F8\u1700-\u1711\u171F-\u1731\u1740-\u1751\u1760-\u176C\u176E-\u1770\u1780-\u17B3\u17D7\u17DC\u1820-\u1878\u1880-\u1884\u1887-\u18A8\u18AA\u18B0-\u18F5\u1900-\u191E\u1950-\u196D\u1970-\u1974\u1980-\u19AB\u19B0-\u19C9\u1A00-\u1A16\u1A20-\u1A54\u1AA7\u1B05-\u1B33\u1B45-\u1B4C\u1B83-\u1BA0\u1BAE\u1BAF\u1BBA-\u1BE5\u1C00-\u1C23\u1C4D-\u1C4F\u1C5A-\u1C7D\u1C80-\u1C88\u1C90-\u1CBA\u1CBD-\u1CBF\u1CE9-\u1CEC\u1CEE-\u1CF3\u1CF5\u1CF6\u1CFA\u1D00-\u1DBF\u1E00-\u1F15\u1F18-\u1F1D\u1F20-\u1F45\u1F48-\u1F4D\u1F50-\u1F57\u1F59\u1F5B\u1F5D\u1F5F-\u1F7D\u1F80-\u1FB4\u1FB6-\u1FBC\u1FBE\u1FC2-\u1FC4\u1FC6-\u1FCC\u1FD0-\u1FD3\u1FD6-\u1FDB\u1FE0-\u1FEC\u1FF2-\u1FF4\u1FF6-\u1FFC\u2071\u207F\u2090-\u209C\u2102\u2107\u210A-\u2113\u2115\u2119-\u211D\u2124\u2126\u2128\u212A-\u212D\u212F-\u2139\u213C-\u213F\u2145-\u2149\u214E\u2183\u2184\u2C00-\u2CE4\u2CEB-\u2CEE\u2CF2\u2CF3\u2D00-\u2D25\u2D27\u2D2D\u2D30-\u2D67\u2D6F\u2D80-\u2D96\u2DA0-\u2DA6\u2DA8-\u2DAE\u2DB0-\u2DB6\u2DB8-\u2DBE\u2DC0-\u2DC6\u2DC8-\u2DCE\u2DD0-\u2DD6\u2DD8-\u2DDE\u2E2F\u3005\u3006\u3031-\u3035\u303B\u303C\u3041-\u3096\u309D-\u309F\u30A1-\u30FA\u30FC-\u30FF\u3105-\u312F\u3131-\u318E\u31A0-\u31BF\u31F0-\u31FF\u3400-\u4DBF\u4E00-\uA48C\uA4D0-\uA4FD\uA500-\uA60C\uA610-\uA61F\uA62A\uA62B\uA640-\uA66E\uA67F-\uA69D\uA6A0-\uA6E5\uA717-\uA71F\uA722-\uA788\uA78B-\uA7CA\uA7D0\uA7D1\uA7D3\uA7D5-\uA7D9\uA7F2-\uA801\uA803-\uA805\uA807-\uA80A\uA80C-\uA822\uA840-\uA873\uA882-\uA8B3\uA8F2-\uA8F7\uA8FB\uA8FD\uA8FE\uA90A-\uA925\uA930-\uA946\uA960-\uA97C\uA984-\uA9B2\uA9CF\uA9E0-\uA9E4\uA9E6-\uA9EF\uA9FA-\uA9FE\uAA00-\uAA28\uAA40-\uAA42\uAA44-\uAA4B\uAA60-\uAA76\uAA7A\uAA7E-\uAAAF\uAAB1\uAAB5\uAAB6\uAAB9-\uAABD\uAAC0\uAAC2\uAADB-\uAADD\uAAE0-\uAAEA\uAAF2-\uAAF4\uAB01-\uAB06\uAB09-\uAB0E\uAB11-\uAB16\uAB20-\uAB26\uAB28-\uAB2E\uAB30-\uAB5A\uAB5C-\uAB69\uAB70-\uABE2\uAC00-\uD7A3\uD7B0-\uD7C6\uD7CB-\uD7FB\uF900-\uFA6D\uFA70-\uFAD9\uFB00-\uFB06\uFB13-\uFB17\uFB1D\uFB1F-\uFB28\uFB2A-\uFB36\uFB38-\uFB3C\uFB3E\uFB40\uFB41\uFB43\uFB44\uFB46-\uFBB1\uFBD3-\uFD3D\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFB\uFE70-\uFE74\uFE76-\uFEFC\uFF21-\uFF3A\uFF41-\uFF5A\uFF66-\uFFBE\uFFC2-\uFFC7\uFFCA-\uFFCF\uFFD2-\uFFD7\uFFDA-\uFFDC]|\uD800[\uDC00-\uDC0B\uDC0D-\uDC26\uDC28-\uDC3A\uDC3C\uDC3D\uDC3F-\uDC4D\uDC50-\uDC5D\uDC80-\uDCFA\uDE80-\uDE9C\uDEA0-\uDED0\uDF00-\uDF1F\uDF2D-\uDF40\uDF42-\uDF49\uDF50-\uDF75\uDF80-\uDF9D\uDFA0-\uDFC3\uDFC8-\uDFCF]|\uD801[\uDC00-\uDC9D\uDCB0-\uDCD3\uDCD8-\uDCFB\uDD00-\uDD27\uDD30-\uDD63\uDD70-\uDD7A\uDD7C-\uDD8A\uDD8C-\uDD92\uDD94\uDD95\uDD97-\uDDA1\uDDA3-\uDDB1\uDDB3-\uDDB9\uDDBB\uDDBC\uDE00-\uDF36\uDF40-\uDF55\uDF60-\uDF67\uDF80-\uDF85\uDF87-\uDFB0\uDFB2-\uDFBA]|\uD802[\uDC00-\uDC05\uDC08\uDC0A-\uDC35\uDC37\uDC38\uDC3C\uDC3F-\uDC55\uDC60-\uDC76\uDC80-\uDC9E\uDCE0-\uDCF2\uDCF4\uDCF5\uDD00-\uDD15\uDD20-\uDD39\uDD80-\uDDB7\uDDBE\uDDBF\uDE00\uDE10-\uDE13\uDE15-\uDE17\uDE19-\uDE35\uDE60-\uDE7C\uDE80-\uDE9C\uDEC0-\uDEC7\uDEC9-\uDEE4\uDF00-\uDF35\uDF40-\uDF55\uDF60-\uDF72\uDF80-\uDF91]|\uD803[\uDC00-\uDC48\uDC80-\uDCB2\uDCC0-\uDCF2\uDD00-\uDD23\uDE80-\uDEA9\uDEB0\uDEB1\uDF00-\uDF1C\uDF27\uDF30-\uDF45\uDF70-\uDF81\uDFB0-\uDFC4\uDFE0-\uDFF6]|\uD804[\uDC03-\uDC37\uDC71\uDC72\uDC75\uDC83-\uDCAF\uDCD0-\uDCE8\uDD03-\uDD26\uDD44\uDD47\uDD50-\uDD72\uDD76\uDD83-\uDDB2\uDDC1-\uDDC4\uDDDA\uDDDC\uDE00-\uDE11\uDE13-\uDE2B\uDE80-\uDE86\uDE88\uDE8A-\uDE8D\uDE8F-\uDE9D\uDE9F-\uDEA8\uDEB0-\uDEDE\uDF05-\uDF0C\uDF0F\uDF10\uDF13-\uDF28\uDF2A-\uDF30\uDF32\uDF33\uDF35-\uDF39\uDF3D\uDF50\uDF5D-\uDF61]|\uD805[\uDC00-\uDC34\uDC47-\uDC4A\uDC5F-\uDC61\uDC80-\uDCAF\uDCC4\uDCC5\uDCC7\uDD80-\uDDAE\uDDD8-\uDDDB\uDE00-\uDE2F\uDE44\uDE80-\uDEAA\uDEB8\uDF00-\uDF1A\uDF40-\uDF46]|\uD806[\uDC00-\uDC2B\uDCA0-\uDCDF\uDCFF-\uDD06\uDD09\uDD0C-\uDD13\uDD15\uDD16\uDD18-\uDD2F\uDD3F\uDD41\uDDA0-\uDDA7\uDDAA-\uDDD0\uDDE1\uDDE3\uDE00\uDE0B-\uDE32\uDE3A\uDE50\uDE5C-\uDE89\uDE9D\uDEB0-\uDEF8]|\uD807[\uDC00-\uDC08\uDC0A-\uDC2E\uDC40\uDC72-\uDC8F\uDD00-\uDD06\uDD08\uDD09\uDD0B-\uDD30\uDD46\uDD60-\uDD65\uDD67\uDD68\uDD6A-\uDD89\uDD98\uDEE0-\uDEF2\uDFB0]|\uD808[\uDC00-\uDF99]|\uD809[\uDC80-\uDD43]|\uD80B[\uDF90-\uDFF0]|[\uD80C\uD81C-\uD820\uD822\uD840-\uD868\uD86A-\uD86C\uD86F-\uD872\uD874-\uD879\uD880-\uD883][\uDC00-\uDFFF]|\uD80D[\uDC00-\uDC2E]|\uD811[\uDC00-\uDE46]|\uD81A[\uDC00-\uDE38\uDE40-\uDE5E\uDE70-\uDEBE\uDED0-\uDEED\uDF00-\uDF2F\uDF40-\uDF43\uDF63-\uDF77\uDF7D-\uDF8F]|\uD81B[\uDE40-\uDE7F\uDF00-\uDF4A\uDF50\uDF93-\uDF9F\uDFE0\uDFE1\uDFE3]|\uD821[\uDC00-\uDFF7]|\uD823[\uDC00-\uDCD5\uDD00-\uDD08]|\uD82B[\uDFF0-\uDFF3\uDFF5-\uDFFB\uDFFD\uDFFE]|\uD82C[\uDC00-\uDD22\uDD50-\uDD52\uDD64-\uDD67\uDD70-\uDEFB]|\uD82F[\uDC00-\uDC6A\uDC70-\uDC7C\uDC80-\uDC88\uDC90-\uDC99]|\uD835[\uDC00-\uDC54\uDC56-\uDC9C\uDC9E\uDC9F\uDCA2\uDCA5\uDCA6\uDCA9-\uDCAC\uDCAE-\uDCB9\uDCBB\uDCBD-\uDCC3\uDCC5-\uDD05\uDD07-\uDD0A\uDD0D-\uDD14\uDD16-\uDD1C\uDD1E-\uDD39\uDD3B-\uDD3E\uDD40-\uDD44\uDD46\uDD4A-\uDD50\uDD52-\uDEA5\uDEA8-\uDEC0\uDEC2-\uDEDA\uDEDC-\uDEFA\uDEFC-\uDF14\uDF16-\uDF34\uDF36-\uDF4E\uDF50-\uDF6E\uDF70-\uDF88\uDF8A-\uDFA8\uDFAA-\uDFC2\uDFC4-\uDFCB]|\uD837[\uDF00-\uDF1E]|\uD838[\uDD00-\uDD2C\uDD37-\uDD3D\uDD4E\uDE90-\uDEAD\uDEC0-\uDEEB]|\uD839[\uDFE0-\uDFE6\uDFE8-\uDFEB\uDFED\uDFEE\uDFF0-\uDFFE]|\uD83A[\uDC00-\uDCC4\uDD00-\uDD43\uDD4B]|\uD83B[\uDE00-\uDE03\uDE05-\uDE1F\uDE21\uDE22\uDE24\uDE27\uDE29-\uDE32\uDE34-\uDE37\uDE39\uDE3B\uDE42\uDE47\uDE49\uDE4B\uDE4D-\uDE4F\uDE51\uDE52\uDE54\uDE57\uDE59\uDE5B\uDE5D\uDE5F\uDE61\uDE62\uDE64\uDE67-\uDE6A\uDE6C-\uDE72\uDE74-\uDE77\uDE79-\uDE7C\uDE7E\uDE80-\uDE89\uDE8B-\uDE9B\uDEA1-\uDEA3\uDEA5-\uDEA9\uDEAB-\uDEBB]|\uD869[\uDC00-\uDEDF\uDF00-\uDFFF]|\uD86D[\uDC00-\uDF38\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1D\uDC20-\uDFFF]|\uD873[\uDC00-\uDEA1\uDEB0-\uDFFF]|\uD87A[\uDC00-\uDFE0]|\uD87E[\uDC00-\uDE1D]|\uD884[\uDC00-\uDF4A])(?:[0-9A-Za-z\xAA\xB5\xBA\xC0-\xD6\xD8-\xF6\xF8-\u02C1\u02C6-\u02D1\u02E0-\u02E4\u02EC\u02EE\u0370-\u0374\u0376\u0377\u037A-\u037D\u037F\u0386\u0388-\u038A\u038C\u038E-\u03A1\u03A3-\u03F5\u03F7-\u0481\u048A-\u052F\u0531-\u0556\u0559\u0560-\u0588\u05D0-\u05EA\u05EF-\u05F2\u0620-\u064A\u066E\u066F\u0671-\u06D3\u06D5\u06E5\u06E6\u06EE\u06EF\u06FA-\u06FC\u06FF\u0710\u0712-\u072F\u074D-\u07A5\u07B1\u07CA-\u07EA\u07F4\u07F5\u07FA\u0800-\u0815\u081A\u0824\u0828\u0840-\u0858\u0860-\u086A\u0870-\u0887\u0889-\u088E\u08A0-\u08C9\u0904-\u0939\u093D\u0950\u0958-\u0961\u0971-\u0980\u0985-\u098C\u098F\u0990\u0993-\u09A8\u09AA-\u09B0\u09B2\u09B6-\u09B9\u09BD\u09CE\u09DC\u09DD\u09DF-\u09E1\u09F0\u09F1\u09FC\u0A05-\u0A0A\u0A0F\u0A10\u0A13-\u0A28\u0A2A-\u0A30\u0A32\u0A33\u0A35\u0A36\u0A38\u0A39\u0A59-\u0A5C\u0A5E\u0A72-\u0A74\u0A85-\u0A8D\u0A8F-\u0A91\u0A93-\u0AA8\u0AAA-\u0AB0\u0AB2\u0AB3\u0AB5-\u0AB9\u0ABD\u0AD0\u0AE0\u0AE1\u0AF9\u0B05-\u0B0C\u0B0F\u0B10\u0B13-\u0B28\u0B2A-\u0B30\u0B32\u0B33\u0B35-\u0B39\u0B3D\u0B5C\u0B5D\u0B5F-\u0B61\u0B71\u0B83\u0B85-\u0B8A\u0B8E-\u0B90\u0B92-\u0B95\u0B99\u0B9A\u0B9C\u0B9E\u0B9F\u0BA3\u0BA4\u0BA8-\u0BAA\u0BAE-\u0BB9\u0BD0\u0C05-\u0C0C\u0C0E-\u0C10\u0C12-\u0C28\u0C2A-\u0C39\u0C3D\u0C58-\u0C5A\u0C5D\u0C60\u0C61\u0C80\u0C85-\u0C8C\u0C8E-\u0C90\u0C92-\u0CA8\u0CAA-\u0CB3\u0CB5-\u0CB9\u0CBD\u0CDD\u0CDE\u0CE0\u0CE1\u0CF1\u0CF2\u0D04-\u0D0C\u0D0E-\u0D10\u0D12-\u0D3A\u0D3D\u0D4E\u0D54-\u0D56\u0D5F-\u0D61\u0D7A-\u0D7F\u0D85-\u0D96\u0D9A-\u0DB1\u0DB3-\u0DBB\u0DBD\u0DC0-\u0DC6\u0E01-\u0E30\u0E32\u0E33\u0E40-\u0E46\u0E81\u0E82\u0E84\u0E86-\u0E8A\u0E8C-\u0EA3\u0EA5\u0EA7-\u0EB0\u0EB2\u0EB3\u0EBD\u0EC0-\u0EC4\u0EC6\u0EDC-\u0EDF\u0F00\u0F40-\u0F47\u0F49-\u0F6C\u0F88-\u0F8C\u1000-\u102A\u103F\u1050-\u1055\u105A-\u105D\u1061\u1065\u1066\u106E-\u1070\u1075-\u1081\u108E\u10A0-\u10C5\u10C7\u10CD\u10D0-\u10FA\u10FC-\u1248\u124A-\u124D\u1250-\u1256\u1258\u125A-\u125D\u1260-\u1288\u128A-\u128D\u1290-\u12B0\u12B2-\u12B5\u12B8-\u12BE\u12C0\u12C2-\u12C5\u12C8-\u12D6\u12D8-\u1310\u1312-\u1315\u1318-\u135A\u1380-\u138F\u13A0-\u13F5\u13F8-\u13FD\u1401-\u166C\u166F-\u167F\u1681-\u169A\u16A0-\u16EA\u16F1-\u16F8\u1700-\u1711\u171F-\u1731\u1740-\u1751\u1760-\u176C\u176E-\u1770\u1780-\u17B3\u17D7\u17DC\u1820-\u1878\u1880-\u1884\u1887-\u18A8\u18AA\u18B0-\u18F5\u1900-\u191E\u1950-\u196D\u1970-\u1974\u1980-\u19AB\u19B0-\u19C9\u1A00-\u1A16\u1A20-\u1A54\u1AA7\u1B05-\u1B33\u1B45-\u1B4C\u1B83-\u1BA0\u1BAE\u1BAF\u1BBA-\u1BE5\u1C00-\u1C23\u1C4D-\u1C4F\u1C5A-\u1C7D\u1C80-\u1C88\u1C90-\u1CBA\u1CBD-\u1CBF\u1CE9-\u1CEC\u1CEE-\u1CF3\u1CF5\u1CF6\u1CFA\u1D00-\u1DBF\u1E00-\u1F15\u1F18-\u1F1D\u1F20-\u1F45\u1F48-\u1F4D\u1F50-\u1F57\u1F59\u1F5B\u1F5D\u1F5F-\u1F7D\u1F80-\u1FB4\u1FB6-\u1FBC\u1FBE\u1FC2-\u1FC4\u1FC6-\u1FCC\u1FD0-\u1FD3\u1FD6-\u1FDB\u1FE0-\u1FEC\u1FF2-\u1FF4\u1FF6-\u1FFC\u2071\u207F\u2090-\u209C\u2102\u2107\u210A-\u2113\u2115\u2119-\u211D\u2124\u2126\u2128\u212A-\u212D\u212F-\u2139\u213C-\u213F\u2145-\u2149\u214E\u2183\u2184\u2C00-\u2CE4\u2CEB-\u2CEE\u2CF2\u2CF3\u2D00-\u2D25\u2D27\u2D2D\u2D30-\u2D67\u2D6F\u2D80-\u2D96\u2DA0-\u2DA6\u2DA8-\u2DAE\u2DB0-\u2DB6\u2DB8-\u2DBE\u2DC0-\u2DC6\u2DC8-\u2DCE\u2DD0-\u2DD6\u2DD8-\u2DDE\u2E2F\u3005\u3006\u3031-\u3035\u303B\u303C\u3041-\u3096\u309D-\u309F\u30A1-\u30FA\u30FC-\u30FF\u3105-\u312F\u3131-\u318E\u31A0-\u31BF\u31F0-\u31FF\u3400-\u4DBF\u4E00-\uA48C\uA4D0-\uA4FD\uA500-\uA60C\uA610-\uA61F\uA62A\uA62B\uA640-\uA66E\uA67F-\uA69D\uA6A0-\uA6E5\uA717-\uA71F\uA722-\uA788\uA78B-\uA7CA\uA7D0\uA7D1\uA7D3\uA7D5-\uA7D9\uA7F2-\uA801\uA803-\uA805\uA807-\uA80A\uA80C-\uA822\uA840-\uA873\uA882-\uA8B3\uA8F2-\uA8F7\uA8FB\uA8FD\uA8FE\uA90A-\uA925\uA930-\uA946\uA960-\uA97C\uA984-\uA9B2\uA9CF\uA9E0-\uA9E4\uA9E6-\uA9EF\uA9FA-\uA9FE\uAA00-\uAA28\uAA40-\uAA42\uAA44-\uAA4B\uAA60-\uAA76\uAA7A\uAA7E-\uAAAF\uAAB1\uAAB5\uAAB6\uAAB9-\uAABD\uAAC0\uAAC2\uAADB-\uAADD\uAAE0-\uAAEA\uAAF2-\uAAF4\uAB01-\uAB06\uAB09-\uAB0E\uAB11-\uAB16\uAB20-\uAB26\uAB28-\uAB2E\uAB30-\uAB5A\uAB5C-\uAB69\uAB70-\uABE2\uAC00-\uD7A3\uD7B0-\uD7C6\uD7CB-\uD7FB\uF900-\uFA6D\uFA70-\uFAD9\uFB00-\uFB06\uFB13-\uFB17\uFB1D\uFB1F-\uFB28\uFB2A-\uFB36\uFB38-\uFB3C\uFB3E\uFB40\uFB41\uFB43\uFB44\uFB46-\uFBB1\uFBD3-\uFD3D\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFB\uFE70-\uFE74\uFE76-\uFEFC\uFF21-\uFF3A\uFF41-\uFF5A\uFF66-\uFFBE\uFFC2-\uFFC7\uFFCA-\uFFCF\uFFD2-\uFFD7\uFFDA-\uFFDC]|\uD800[\uDC00-\uDC0B\uDC0D-\uDC26\uDC28-\uDC3A\uDC3C\uDC3D\uDC3F-\uDC4D\uDC50-\uDC5D\uDC80-\uDCFA\uDE80-\uDE9C\uDEA0-\uDED0\uDF00-\uDF1F\uDF2D-\uDF40\uDF42-\uDF49\uDF50-\uDF75\uDF80-\uDF9D\uDFA0-\uDFC3\uDFC8-\uDFCF]|\uD801[\uDC00-\uDC9D\uDCB0-\uDCD3\uDCD8-\uDCFB\uDD00-\uDD27\uDD30-\uDD63\uDD70-\uDD7A\uDD7C-\uDD8A\uDD8C-\uDD92\uDD94\uDD95\uDD97-\uDDA1\uDDA3-\uDDB1\uDDB3-\uDDB9\uDDBB\uDDBC\uDE00-\uDF36\uDF40-\uDF55\uDF60-\uDF67\uDF80-\uDF85\uDF87-\uDFB0\uDFB2-\uDFBA]|\uD802[\uDC00-\uDC05\uDC08\uDC0A-\uDC35\uDC37\uDC38\uDC3C\uDC3F-\uDC55\uDC60-\uDC76\uDC80-\uDC9E\uDCE0-\uDCF2\uDCF4\uDCF5\uDD00-\uDD15\uDD20-\uDD39\uDD80-\uDDB7\uDDBE\uDDBF\uDE00\uDE10-\uDE13\uDE15-\uDE17\uDE19-\uDE35\uDE60-\uDE7C\uDE80-\uDE9C\uDEC0-\uDEC7\uDEC9-\uDEE4\uDF00-\uDF35\uDF40-\uDF55\uDF60-\uDF72\uDF80-\uDF91]|\uD803[\uDC00-\uDC48\uDC80-\uDCB2\uDCC0-\uDCF2\uDD00-\uDD23\uDE80-\uDEA9\uDEB0\uDEB1\uDF00-\uDF1C\uDF27\uDF30-\uDF45\uDF70-\uDF81\uDFB0-\uDFC4\uDFE0-\uDFF6]|\uD804[\uDC03-\uDC37\uDC71\uDC72\uDC75\uDC83-\uDCAF\uDCD0-\uDCE8\uDD03-\uDD26\uDD44\uDD47\uDD50-\uDD72\uDD76\uDD83-\uDDB2\uDDC1-\uDDC4\uDDDA\uDDDC\uDE00-\uDE11\uDE13-\uDE2B\uDE80-\uDE86\uDE88\uDE8A-\uDE8D\uDE8F-\uDE9D\uDE9F-\uDEA8\uDEB0-\uDEDE\uDF05-\uDF0C\uDF0F\uDF10\uDF13-\uDF28\uDF2A-\uDF30\uDF32\uDF33\uDF35-\uDF39\uDF3D\uDF50\uDF5D-\uDF61]|\uD805[\uDC00-\uDC34\uDC47-\uDC4A\uDC5F-\uDC61\uDC80-\uDCAF\uDCC4\uDCC5\uDCC7\uDD80-\uDDAE\uDDD8-\uDDDB\uDE00-\uDE2F\uDE44\uDE80-\uDEAA\uDEB8\uDF00-\uDF1A\uDF40-\uDF46]|\uD806[\uDC00-\uDC2B\uDCA0-\uDCDF\uDCFF-\uDD06\uDD09\uDD0C-\uDD13\uDD15\uDD16\uDD18-\uDD2F\uDD3F\uDD41\uDDA0-\uDDA7\uDDAA-\uDDD0\uDDE1\uDDE3\uDE00\uDE0B-\uDE32\uDE3A\uDE50\uDE5C-\uDE89\uDE9D\uDEB0-\uDEF8]|\uD807[\uDC00-\uDC08\uDC0A-\uDC2E\uDC40\uDC72-\uDC8F\uDD00-\uDD06\uDD08\uDD09\uDD0B-\uDD30\uDD46\uDD60-\uDD65\uDD67\uDD68\uDD6A-\uDD89\uDD98\uDEE0-\uDEF2\uDFB0]|\uD808[\uDC00-\uDF99]|\uD809[\uDC80-\uDD43]|\uD80B[\uDF90-\uDFF0]|[\uD80C\uD81C-\uD820\uD822\uD840-\uD868\uD86A-\uD86C\uD86F-\uD872\uD874-\uD879\uD880-\uD883][\uDC00-\uDFFF]|\uD80D[\uDC00-\uDC2E]|\uD811[\uDC00-\uDE46]|\uD81A[\uDC00-\uDE38\uDE40-\uDE5E\uDE70-\uDEBE\uDED0-\uDEED\uDF00-\uDF2F\uDF40-\uDF43\uDF63-\uDF77\uDF7D-\uDF8F]|\uD81B[\uDE40-\uDE7F\uDF00-\uDF4A\uDF50\uDF93-\uDF9F\uDFE0\uDFE1\uDFE3]|\uD821[\uDC00-\uDFF7]|\uD823[\uDC00-\uDCD5\uDD00-\uDD08]|\uD82B[\uDFF0-\uDFF3\uDFF5-\uDFFB\uDFFD\uDFFE]|\uD82C[\uDC00-\uDD22\uDD50-\uDD52\uDD64-\uDD67\uDD70-\uDEFB]|\uD82F[\uDC00-\uDC6A\uDC70-\uDC7C\uDC80-\uDC88\uDC90-\uDC99]|\uD835[\uDC00-\uDC54\uDC56-\uDC9C\uDC9E\uDC9F\uDCA2\uDCA5\uDCA6\uDCA9-\uDCAC\uDCAE-\uDCB9\uDCBB\uDCBD-\uDCC3\uDCC5-\uDD05\uDD07-\uDD0A\uDD0D-\uDD14\uDD16-\uDD1C\uDD1E-\uDD39\uDD3B-\uDD3E\uDD40-\uDD44\uDD46\uDD4A-\uDD50\uDD52-\uDEA5\uDEA8-\uDEC0\uDEC2-\uDEDA\uDEDC-\uDEFA\uDEFC-\uDF14\uDF16-\uDF34\uDF36-\uDF4E\uDF50-\uDF6E\uDF70-\uDF88\uDF8A-\uDFA8\uDFAA-\uDFC2\uDFC4-\uDFCB]|\uD837[\uDF00-\uDF1E]|\uD838[\uDD00-\uDD2C\uDD37-\uDD3D\uDD4E\uDE90-\uDEAD\uDEC0-\uDEEB]|\uD839[\uDFE0-\uDFE6\uDFE8-\uDFEB\uDFED\uDFEE\uDFF0-\uDFFE]|\uD83A[\uDC00-\uDCC4\uDD00-\uDD43\uDD4B]|\uD83B[\uDE00-\uDE03\uDE05-\uDE1F\uDE21\uDE22\uDE24\uDE27\uDE29-\uDE32\uDE34-\uDE37\uDE39\uDE3B\uDE42\uDE47\uDE49\uDE4B\uDE4D-\uDE4F\uDE51\uDE52\uDE54\uDE57\uDE59\uDE5B\uDE5D\uDE5F\uDE61\uDE62\uDE64\uDE67-\uDE6A\uDE6C-\uDE72\uDE74-\uDE77\uDE79-\uDE7C\uDE7E\uDE80-\uDE89\uDE8B-\uDE9B\uDEA1-\uDEA3\uDEA5-\uDEA9\uDEAB-\uDEBB]|\uD869[\uDC00-\uDEDF\uDF00-\uDFFF]|\uD86D[\uDC00-\uDF38\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1D\uDC20-\uDFFF]|\uD873[\uDC00-\uDEA1\uDEB0-\uDFFF]|\uD87A[\uDC00-\uDFE0]|\uD87E[\uDC00-\uDE1D]|\uD884[\uDC00-\uDF4A])*$/.test(s)
    },
    {
      name: "string",
      test: isString
    },
    {
      name: "Chain",
      test: isChain
    },
    {
      name: "Array",
      test: isArray
    },
    {
      name: "Matrix",
      test: isMatrix
    },
    {
      name: "DenseMatrix",
      test: isDenseMatrix
    },
    {
      name: "SparseMatrix",
      test: isSparseMatrix
    },
    {
      name: "Range",
      test: isRange
    },
    {
      name: "Index",
      test: isIndex
    },
    {
      name: "boolean",
      test: isBoolean
    },
    {
      name: "ResultSet",
      test: isResultSet
    },
    {
      name: "Help",
      test: isHelp
    },
    {
      name: "function",
      test: isFunction
    },
    {
      name: "Date",
      test: isDate
    },
    {
      name: "RegExp",
      test: isRegExp
    },
    {
      name: "null",
      test: isNull
    },
    {
      name: "undefined",
      test: isUndefined
    },
    {
      name: "AccessorNode",
      test: isAccessorNode
    },
    {
      name: "ArrayNode",
      test: isArrayNode
    },
    {
      name: "AssignmentNode",
      test: isAssignmentNode
    },
    {
      name: "BlockNode",
      test: isBlockNode
    },
    {
      name: "ConditionalNode",
      test: isConditionalNode
    },
    {
      name: "ConstantNode",
      test: isConstantNode
    },
    {
      name: "FunctionNode",
      test: isFunctionNode
    },
    {
      name: "FunctionAssignmentNode",
      test: isFunctionAssignmentNode
    },
    {
      name: "IndexNode",
      test: isIndexNode
    },
    {
      name: "Node",
      test: isNode
    },
    {
      name: "ObjectNode",
      test: isObjectNode
    },
    {
      name: "OperatorNode",
      test: isOperatorNode
    },
    {
      name: "ParenthesisNode",
      test: isParenthesisNode
    },
    {
      name: "RangeNode",
      test: isRangeNode
    },
    {
      name: "RelationalNode",
      test: isRelationalNode
    },
    {
      name: "SymbolNode",
      test: isSymbolNode
    },
    {
      name: "Map",
      test: isMap
    },
    {
      name: "Object",
      test: isObject
    }
  ]);
  typed2.addConversions([{
    from: "number",
    to: "BigNumber",
    convert: function convert(x) {
      if (!BigNumber2) {
        throwNoBignumber(x);
      }
      if (digits(x) > 15) {
        throw new TypeError("Cannot implicitly convert a number with >15 significant digits to BigNumber (value: " + x + "). Use function bignumber(x) to convert to BigNumber.");
      }
      return new BigNumber2(x);
    }
  }, {
    from: "number",
    to: "Complex",
    convert: function convert(x) {
      if (!Complex3) {
        throwNoComplex(x);
      }
      return new Complex3(x, 0);
    }
  }, {
    from: "BigNumber",
    to: "Complex",
    convert: function convert(x) {
      if (!Complex3) {
        throwNoComplex(x);
      }
      return new Complex3(x.toNumber(), 0);
    }
  }, {
    from: "Fraction",
    to: "BigNumber",
    convert: function convert(x) {
      throw new TypeError("Cannot implicitly convert a Fraction to BigNumber or vice versa. Use function bignumber(x) to convert to BigNumber or fraction(x) to convert to Fraction.");
    }
  }, {
    from: "Fraction",
    to: "Complex",
    convert: function convert(x) {
      if (!Complex3) {
        throwNoComplex(x);
      }
      return new Complex3(x.valueOf(), 0);
    }
  }, {
    from: "number",
    to: "Fraction",
    convert: function convert(x) {
      if (!Fraction3) {
        throwNoFraction(x);
      }
      var f = new Fraction3(x);
      if (f.valueOf() !== x) {
        throw new TypeError("Cannot implicitly convert a number to a Fraction when there will be a loss of precision (value: " + x + "). Use function fraction(x) to convert to Fraction.");
      }
      return f;
    }
  }, {
    from: "string",
    to: "number",
    convert: function convert(x) {
      var n = Number(x);
      if (isNaN(n)) {
        throw new Error('Cannot convert "' + x + '" to a number');
      }
      return n;
    }
  }, {
    from: "string",
    to: "BigNumber",
    convert: function convert(x) {
      if (!BigNumber2) {
        throwNoBignumber(x);
      }
      try {
        return new BigNumber2(x);
      } catch (err) {
        throw new Error('Cannot convert "' + x + '" to BigNumber');
      }
    }
  }, {
    from: "string",
    to: "Fraction",
    convert: function convert(x) {
      if (!Fraction3) {
        throwNoFraction(x);
      }
      try {
        return new Fraction3(x);
      } catch (err) {
        throw new Error('Cannot convert "' + x + '" to Fraction');
      }
    }
  }, {
    from: "string",
    to: "Complex",
    convert: function convert(x) {
      if (!Complex3) {
        throwNoComplex(x);
      }
      try {
        return new Complex3(x);
      } catch (err) {
        throw new Error('Cannot convert "' + x + '" to Complex');
      }
    }
  }, {
    from: "boolean",
    to: "number",
    convert: function convert(x) {
      return +x;
    }
  }, {
    from: "boolean",
    to: "BigNumber",
    convert: function convert(x) {
      if (!BigNumber2) {
        throwNoBignumber(x);
      }
      return new BigNumber2(+x);
    }
  }, {
    from: "boolean",
    to: "Fraction",
    convert: function convert(x) {
      if (!Fraction3) {
        throwNoFraction(x);
      }
      return new Fraction3(+x);
    }
  }, {
    from: "boolean",
    to: "string",
    convert: function convert(x) {
      return String(x);
    }
  }, {
    from: "Array",
    to: "Matrix",
    convert: function convert(array) {
      if (!DenseMatrix2) {
        throwNoMatrix();
      }
      return new DenseMatrix2(array);
    }
  }, {
    from: "Matrix",
    to: "Array",
    convert: function convert(matrix2) {
      return matrix2.valueOf();
    }
  }]);
  typed2.onMismatch = (name21, args, signatures) => {
    var usualError = typed2.createError(name21, args, signatures);
    if (["wrongType", "mismatch"].includes(usualError.data.category) && args.length === 1 && isCollection(args[0]) && signatures.some((sig) => !sig.params.includes(","))) {
      var err = new TypeError("Function '".concat(name21, "' doesn't apply to matrices. To call it ") + "elementwise on a matrix 'M', try 'map(M, ".concat(name21, ")'."));
      err.data = usualError.data;
      throw err;
    }
    throw usualError;
  };
  typed2.onMismatch = (name21, args, signatures) => {
    var usualError = typed2.createError(name21, args, signatures);
    if (["wrongType", "mismatch"].includes(usualError.data.category) && args.length === 1 && isCollection(args[0]) && signatures.some((sig) => !sig.params.includes(","))) {
      var err = new TypeError("Function '".concat(name21, "' doesn't apply to matrices. To call it ") + "elementwise on a matrix 'M', try 'map(M, ".concat(name21, ")'."));
      err.data = usualError.data;
      throw err;
    }
    throw usualError;
  };
  return typed2;
});
function throwNoBignumber(x) {
  throw new Error("Cannot convert value ".concat(x, " into a BigNumber: no class 'BigNumber' provided"));
}
function throwNoComplex(x) {
  throw new Error("Cannot convert value ".concat(x, " into a Complex number: no class 'Complex' provided"));
}
function throwNoMatrix() {
  throw new Error("Cannot convert array into a Matrix: no class 'DenseMatrix' provided");
}
function throwNoFraction(x) {
  throw new Error("Cannot convert value ".concat(x, " into a Fraction, no class 'Fraction' provided."));
}

// node_modules/decimal.js/decimal.mjs
var EXP_LIMIT = 9e15;
var MAX_DIGITS = 1e9;
var NUMERALS = "0123456789abcdef";
var LN10 = "2.3025850929940456840179914546843642076011014886287729760333279009675726096773524802359972050895982983419677840422862486334095254650828067566662873690987816894829072083255546808437998948262331985283935053089653777326288461633662222876982198867465436674744042432743651550489343149393914796194044002221051017141748003688084012647080685567743216228355220114804663715659121373450747856947683463616792101806445070648000277502684916746550586856935673420670581136429224554405758925724208241314695689016758940256776311356919292033376587141660230105703089634572075440370847469940168269282808481184289314848524948644871927809676271275775397027668605952496716674183485704422507197965004714951050492214776567636938662976979522110718264549734772662425709429322582798502585509785265383207606726317164309505995087807523710333101197857547331541421808427543863591778117054309827482385045648019095610299291824318237525357709750539565187697510374970888692180205189339507238539205144634197265287286965110862571492198849978748873771345686209167058";
var PI = "3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989380952572010654858632789";
var DEFAULTS = {
  precision: 20,
  rounding: 4,
  modulo: 1,
  toExpNeg: -7,
  toExpPos: 21,
  minE: -EXP_LIMIT,
  maxE: EXP_LIMIT,
  crypto: false
};
var inexact;
var quadrant;
var external = true;
var decimalError = "[DecimalError] ";
var invalidArgument = decimalError + "Invalid argument: ";
var precisionLimitExceeded = decimalError + "Precision limit exceeded";
var cryptoUnavailable = decimalError + "crypto unavailable";
var tag = "[object Decimal]";
var mathfloor = Math.floor;
var mathpow = Math.pow;
var isBinary = /^0b([01]+(\.[01]*)?|\.[01]+)(p[+-]?\d+)?$/i;
var isHex = /^0x([0-9a-f]+(\.[0-9a-f]*)?|\.[0-9a-f]+)(p[+-]?\d+)?$/i;
var isOctal = /^0o([0-7]+(\.[0-7]*)?|\.[0-7]+)(p[+-]?\d+)?$/i;
var isDecimal = /^(\d+(\.\d*)?|\.\d+)(e[+-]?\d+)?$/i;
var BASE = 1e7;
var LOG_BASE = 7;
var MAX_SAFE_INTEGER = 9007199254740991;
var LN10_PRECISION = LN10.length - 1;
var PI_PRECISION = PI.length - 1;
var P = { toStringTag: tag };
P.absoluteValue = P.abs = function() {
  var x = new this.constructor(this);
  if (x.s < 0)
    x.s = 1;
  return finalise(x);
};
P.ceil = function() {
  return finalise(new this.constructor(this), this.e + 1, 2);
};
P.clampedTo = P.clamp = function(min2, max2) {
  var k, x = this, Ctor = x.constructor;
  min2 = new Ctor(min2);
  max2 = new Ctor(max2);
  if (!min2.s || !max2.s)
    return new Ctor(NaN);
  if (min2.gt(max2))
    throw Error(invalidArgument + max2);
  k = x.cmp(min2);
  return k < 0 ? min2 : x.cmp(max2) > 0 ? max2 : new Ctor(x);
};
P.comparedTo = P.cmp = function(y) {
  var i, j, xdL, ydL, x = this, xd = x.d, yd = (y = new x.constructor(y)).d, xs = x.s, ys = y.s;
  if (!xd || !yd) {
    return !xs || !ys ? NaN : xs !== ys ? xs : xd === yd ? 0 : !xd ^ xs < 0 ? 1 : -1;
  }
  if (!xd[0] || !yd[0])
    return xd[0] ? xs : yd[0] ? -ys : 0;
  if (xs !== ys)
    return xs;
  if (x.e !== y.e)
    return x.e > y.e ^ xs < 0 ? 1 : -1;
  xdL = xd.length;
  ydL = yd.length;
  for (i = 0, j = xdL < ydL ? xdL : ydL; i < j; ++i) {
    if (xd[i] !== yd[i])
      return xd[i] > yd[i] ^ xs < 0 ? 1 : -1;
  }
  return xdL === ydL ? 0 : xdL > ydL ^ xs < 0 ? 1 : -1;
};
P.cosine = P.cos = function() {
  var pr, rm, x = this, Ctor = x.constructor;
  if (!x.d)
    return new Ctor(NaN);
  if (!x.d[0])
    return new Ctor(1);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  Ctor.precision = pr + Math.max(x.e, x.sd()) + LOG_BASE;
  Ctor.rounding = 1;
  x = cosine(Ctor, toLessThanHalfPi(Ctor, x));
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return finalise(quadrant == 2 || quadrant == 3 ? x.neg() : x, pr, rm, true);
};
P.cubeRoot = P.cbrt = function() {
  var e, m, n, r, rep, s, sd, t, t3, t3plusx, x = this, Ctor = x.constructor;
  if (!x.isFinite() || x.isZero())
    return new Ctor(x);
  external = false;
  s = x.s * mathpow(x.s * x, 1 / 3);
  if (!s || Math.abs(s) == 1 / 0) {
    n = digitsToString(x.d);
    e = x.e;
    if (s = (e - n.length + 1) % 3)
      n += s == 1 || s == -2 ? "0" : "00";
    s = mathpow(n, 1 / 3);
    e = mathfloor((e + 1) / 3) - (e % 3 == (e < 0 ? -1 : 2));
    if (s == 1 / 0) {
      n = "5e" + e;
    } else {
      n = s.toExponential();
      n = n.slice(0, n.indexOf("e") + 1) + e;
    }
    r = new Ctor(n);
    r.s = x.s;
  } else {
    r = new Ctor(s.toString());
  }
  sd = (e = Ctor.precision) + 3;
  for (; ; ) {
    t = r;
    t3 = t.times(t).times(t);
    t3plusx = t3.plus(x);
    r = divide(t3plusx.plus(x).times(t), t3plusx.plus(t3), sd + 2, 1);
    if (digitsToString(t.d).slice(0, sd) === (n = digitsToString(r.d)).slice(0, sd)) {
      n = n.slice(sd - 3, sd + 1);
      if (n == "9999" || !rep && n == "4999") {
        if (!rep) {
          finalise(t, e + 1, 0);
          if (t.times(t).times(t).eq(x)) {
            r = t;
            break;
          }
        }
        sd += 4;
        rep = 1;
      } else {
        if (!+n || !+n.slice(1) && n.charAt(0) == "5") {
          finalise(r, e + 1, 1);
          m = !r.times(r).times(r).eq(x);
        }
        break;
      }
    }
  }
  external = true;
  return finalise(r, e, Ctor.rounding, m);
};
P.decimalPlaces = P.dp = function() {
  var w, d = this.d, n = NaN;
  if (d) {
    w = d.length - 1;
    n = (w - mathfloor(this.e / LOG_BASE)) * LOG_BASE;
    w = d[w];
    if (w)
      for (; w % 10 == 0; w /= 10)
        n--;
    if (n < 0)
      n = 0;
  }
  return n;
};
P.dividedBy = P.div = function(y) {
  return divide(this, new this.constructor(y));
};
P.dividedToIntegerBy = P.divToInt = function(y) {
  var x = this, Ctor = x.constructor;
  return finalise(divide(x, new Ctor(y), 0, 1, 1), Ctor.precision, Ctor.rounding);
};
P.equals = P.eq = function(y) {
  return this.cmp(y) === 0;
};
P.floor = function() {
  return finalise(new this.constructor(this), this.e + 1, 3);
};
P.greaterThan = P.gt = function(y) {
  return this.cmp(y) > 0;
};
P.greaterThanOrEqualTo = P.gte = function(y) {
  var k = this.cmp(y);
  return k == 1 || k === 0;
};
P.hyperbolicCosine = P.cosh = function() {
  var k, n, pr, rm, len, x = this, Ctor = x.constructor, one = new Ctor(1);
  if (!x.isFinite())
    return new Ctor(x.s ? 1 / 0 : NaN);
  if (x.isZero())
    return one;
  pr = Ctor.precision;
  rm = Ctor.rounding;
  Ctor.precision = pr + Math.max(x.e, x.sd()) + 4;
  Ctor.rounding = 1;
  len = x.d.length;
  if (len < 32) {
    k = Math.ceil(len / 3);
    n = (1 / tinyPow(4, k)).toString();
  } else {
    k = 16;
    n = "2.3283064365386962890625e-10";
  }
  x = taylorSeries(Ctor, 1, x.times(n), new Ctor(1), true);
  var cosh2_x, i = k, d8 = new Ctor(8);
  for (; i--; ) {
    cosh2_x = x.times(x);
    x = one.minus(cosh2_x.times(d8.minus(cosh2_x.times(d8))));
  }
  return finalise(x, Ctor.precision = pr, Ctor.rounding = rm, true);
};
P.hyperbolicSine = P.sinh = function() {
  var k, pr, rm, len, x = this, Ctor = x.constructor;
  if (!x.isFinite() || x.isZero())
    return new Ctor(x);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  Ctor.precision = pr + Math.max(x.e, x.sd()) + 4;
  Ctor.rounding = 1;
  len = x.d.length;
  if (len < 3) {
    x = taylorSeries(Ctor, 2, x, x, true);
  } else {
    k = 1.4 * Math.sqrt(len);
    k = k > 16 ? 16 : k | 0;
    x = x.times(1 / tinyPow(5, k));
    x = taylorSeries(Ctor, 2, x, x, true);
    var sinh2_x, d5 = new Ctor(5), d16 = new Ctor(16), d20 = new Ctor(20);
    for (; k--; ) {
      sinh2_x = x.times(x);
      x = x.times(d5.plus(sinh2_x.times(d16.times(sinh2_x).plus(d20))));
    }
  }
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return finalise(x, pr, rm, true);
};
P.hyperbolicTangent = P.tanh = function() {
  var pr, rm, x = this, Ctor = x.constructor;
  if (!x.isFinite())
    return new Ctor(x.s);
  if (x.isZero())
    return new Ctor(x);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  Ctor.precision = pr + 7;
  Ctor.rounding = 1;
  return divide(x.sinh(), x.cosh(), Ctor.precision = pr, Ctor.rounding = rm);
};
P.inverseCosine = P.acos = function() {
  var x = this, Ctor = x.constructor, k = x.abs().cmp(1), pr = Ctor.precision, rm = Ctor.rounding;
  if (k !== -1) {
    return k === 0 ? x.isNeg() ? getPi(Ctor, pr, rm) : new Ctor(0) : new Ctor(NaN);
  }
  if (x.isZero())
    return getPi(Ctor, pr + 4, rm).times(0.5);
  Ctor.precision = pr + 6;
  Ctor.rounding = 1;
  x = new Ctor(1).minus(x).div(x.plus(1)).sqrt().atan();
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return x.times(2);
};
P.inverseHyperbolicCosine = P.acosh = function() {
  var pr, rm, x = this, Ctor = x.constructor;
  if (x.lte(1))
    return new Ctor(x.eq(1) ? 0 : NaN);
  if (!x.isFinite())
    return new Ctor(x);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  Ctor.precision = pr + Math.max(Math.abs(x.e), x.sd()) + 4;
  Ctor.rounding = 1;
  external = false;
  x = x.times(x).minus(1).sqrt().plus(x);
  external = true;
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return x.ln();
};
P.inverseHyperbolicSine = P.asinh = function() {
  var pr, rm, x = this, Ctor = x.constructor;
  if (!x.isFinite() || x.isZero())
    return new Ctor(x);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  Ctor.precision = pr + 2 * Math.max(Math.abs(x.e), x.sd()) + 6;
  Ctor.rounding = 1;
  external = false;
  x = x.times(x).plus(1).sqrt().plus(x);
  external = true;
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return x.ln();
};
P.inverseHyperbolicTangent = P.atanh = function() {
  var pr, rm, wpr, xsd, x = this, Ctor = x.constructor;
  if (!x.isFinite())
    return new Ctor(NaN);
  if (x.e >= 0)
    return new Ctor(x.abs().eq(1) ? x.s / 0 : x.isZero() ? x : NaN);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  xsd = x.sd();
  if (Math.max(xsd, pr) < 2 * -x.e - 1)
    return finalise(new Ctor(x), pr, rm, true);
  Ctor.precision = wpr = xsd - x.e;
  x = divide(x.plus(1), new Ctor(1).minus(x), wpr + pr, 1);
  Ctor.precision = pr + 4;
  Ctor.rounding = 1;
  x = x.ln();
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return x.times(0.5);
};
P.inverseSine = P.asin = function() {
  var halfPi, k, pr, rm, x = this, Ctor = x.constructor;
  if (x.isZero())
    return new Ctor(x);
  k = x.abs().cmp(1);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  if (k !== -1) {
    if (k === 0) {
      halfPi = getPi(Ctor, pr + 4, rm).times(0.5);
      halfPi.s = x.s;
      return halfPi;
    }
    return new Ctor(NaN);
  }
  Ctor.precision = pr + 6;
  Ctor.rounding = 1;
  x = x.div(new Ctor(1).minus(x.times(x)).sqrt().plus(1)).atan();
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return x.times(2);
};
P.inverseTangent = P.atan = function() {
  var i, j, k, n, px, t, r, wpr, x2, x = this, Ctor = x.constructor, pr = Ctor.precision, rm = Ctor.rounding;
  if (!x.isFinite()) {
    if (!x.s)
      return new Ctor(NaN);
    if (pr + 4 <= PI_PRECISION) {
      r = getPi(Ctor, pr + 4, rm).times(0.5);
      r.s = x.s;
      return r;
    }
  } else if (x.isZero()) {
    return new Ctor(x);
  } else if (x.abs().eq(1) && pr + 4 <= PI_PRECISION) {
    r = getPi(Ctor, pr + 4, rm).times(0.25);
    r.s = x.s;
    return r;
  }
  Ctor.precision = wpr = pr + 10;
  Ctor.rounding = 1;
  k = Math.min(28, wpr / LOG_BASE + 2 | 0);
  for (i = k; i; --i)
    x = x.div(x.times(x).plus(1).sqrt().plus(1));
  external = false;
  j = Math.ceil(wpr / LOG_BASE);
  n = 1;
  x2 = x.times(x);
  r = new Ctor(x);
  px = x;
  for (; i !== -1; ) {
    px = px.times(x2);
    t = r.minus(px.div(n += 2));
    px = px.times(x2);
    r = t.plus(px.div(n += 2));
    if (r.d[j] !== void 0)
      for (i = j; r.d[i] === t.d[i] && i--; )
        ;
  }
  if (k)
    r = r.times(2 << k - 1);
  external = true;
  return finalise(r, Ctor.precision = pr, Ctor.rounding = rm, true);
};
P.isFinite = function() {
  return !!this.d;
};
P.isInteger = P.isInt = function() {
  return !!this.d && mathfloor(this.e / LOG_BASE) > this.d.length - 2;
};
P.isNaN = function() {
  return !this.s;
};
P.isNegative = P.isNeg = function() {
  return this.s < 0;
};
P.isPositive = P.isPos = function() {
  return this.s > 0;
};
P.isZero = function() {
  return !!this.d && this.d[0] === 0;
};
P.lessThan = P.lt = function(y) {
  return this.cmp(y) < 0;
};
P.lessThanOrEqualTo = P.lte = function(y) {
  return this.cmp(y) < 1;
};
P.logarithm = P.log = function(base) {
  var isBase10, d, denominator, k, inf, num, sd, r, arg = this, Ctor = arg.constructor, pr = Ctor.precision, rm = Ctor.rounding, guard = 5;
  if (base == null) {
    base = new Ctor(10);
    isBase10 = true;
  } else {
    base = new Ctor(base);
    d = base.d;
    if (base.s < 0 || !d || !d[0] || base.eq(1))
      return new Ctor(NaN);
    isBase10 = base.eq(10);
  }
  d = arg.d;
  if (arg.s < 0 || !d || !d[0] || arg.eq(1)) {
    return new Ctor(d && !d[0] ? -1 / 0 : arg.s != 1 ? NaN : d ? 0 : 1 / 0);
  }
  if (isBase10) {
    if (d.length > 1) {
      inf = true;
    } else {
      for (k = d[0]; k % 10 === 0; )
        k /= 10;
      inf = k !== 1;
    }
  }
  external = false;
  sd = pr + guard;
  num = naturalLogarithm(arg, sd);
  denominator = isBase10 ? getLn10(Ctor, sd + 10) : naturalLogarithm(base, sd);
  r = divide(num, denominator, sd, 1);
  if (checkRoundingDigits(r.d, k = pr, rm)) {
    do {
      sd += 10;
      num = naturalLogarithm(arg, sd);
      denominator = isBase10 ? getLn10(Ctor, sd + 10) : naturalLogarithm(base, sd);
      r = divide(num, denominator, sd, 1);
      if (!inf) {
        if (+digitsToString(r.d).slice(k + 1, k + 15) + 1 == 1e14) {
          r = finalise(r, pr + 1, 0);
        }
        break;
      }
    } while (checkRoundingDigits(r.d, k += 10, rm));
  }
  external = true;
  return finalise(r, pr, rm);
};
P.minus = P.sub = function(y) {
  var d, e, i, j, k, len, pr, rm, xd, xe, xLTy, yd, x = this, Ctor = x.constructor;
  y = new Ctor(y);
  if (!x.d || !y.d) {
    if (!x.s || !y.s)
      y = new Ctor(NaN);
    else if (x.d)
      y.s = -y.s;
    else
      y = new Ctor(y.d || x.s !== y.s ? x : NaN);
    return y;
  }
  if (x.s != y.s) {
    y.s = -y.s;
    return x.plus(y);
  }
  xd = x.d;
  yd = y.d;
  pr = Ctor.precision;
  rm = Ctor.rounding;
  if (!xd[0] || !yd[0]) {
    if (yd[0])
      y.s = -y.s;
    else if (xd[0])
      y = new Ctor(x);
    else
      return new Ctor(rm === 3 ? -0 : 0);
    return external ? finalise(y, pr, rm) : y;
  }
  e = mathfloor(y.e / LOG_BASE);
  xe = mathfloor(x.e / LOG_BASE);
  xd = xd.slice();
  k = xe - e;
  if (k) {
    xLTy = k < 0;
    if (xLTy) {
      d = xd;
      k = -k;
      len = yd.length;
    } else {
      d = yd;
      e = xe;
      len = xd.length;
    }
    i = Math.max(Math.ceil(pr / LOG_BASE), len) + 2;
    if (k > i) {
      k = i;
      d.length = 1;
    }
    d.reverse();
    for (i = k; i--; )
      d.push(0);
    d.reverse();
  } else {
    i = xd.length;
    len = yd.length;
    xLTy = i < len;
    if (xLTy)
      len = i;
    for (i = 0; i < len; i++) {
      if (xd[i] != yd[i]) {
        xLTy = xd[i] < yd[i];
        break;
      }
    }
    k = 0;
  }
  if (xLTy) {
    d = xd;
    xd = yd;
    yd = d;
    y.s = -y.s;
  }
  len = xd.length;
  for (i = yd.length - len; i > 0; --i)
    xd[len++] = 0;
  for (i = yd.length; i > k; ) {
    if (xd[--i] < yd[i]) {
      for (j = i; j && xd[--j] === 0; )
        xd[j] = BASE - 1;
      --xd[j];
      xd[i] += BASE;
    }
    xd[i] -= yd[i];
  }
  for (; xd[--len] === 0; )
    xd.pop();
  for (; xd[0] === 0; xd.shift())
    --e;
  if (!xd[0])
    return new Ctor(rm === 3 ? -0 : 0);
  y.d = xd;
  y.e = getBase10Exponent(xd, e);
  return external ? finalise(y, pr, rm) : y;
};
P.modulo = P.mod = function(y) {
  var q, x = this, Ctor = x.constructor;
  y = new Ctor(y);
  if (!x.d || !y.s || y.d && !y.d[0])
    return new Ctor(NaN);
  if (!y.d || x.d && !x.d[0]) {
    return finalise(new Ctor(x), Ctor.precision, Ctor.rounding);
  }
  external = false;
  if (Ctor.modulo == 9) {
    q = divide(x, y.abs(), 0, 3, 1);
    q.s *= y.s;
  } else {
    q = divide(x, y, 0, Ctor.modulo, 1);
  }
  q = q.times(y);
  external = true;
  return x.minus(q);
};
P.naturalExponential = P.exp = function() {
  return naturalExponential(this);
};
P.naturalLogarithm = P.ln = function() {
  return naturalLogarithm(this);
};
P.negated = P.neg = function() {
  var x = new this.constructor(this);
  x.s = -x.s;
  return finalise(x);
};
P.plus = P.add = function(y) {
  var carry, d, e, i, k, len, pr, rm, xd, yd, x = this, Ctor = x.constructor;
  y = new Ctor(y);
  if (!x.d || !y.d) {
    if (!x.s || !y.s)
      y = new Ctor(NaN);
    else if (!x.d)
      y = new Ctor(y.d || x.s === y.s ? x : NaN);
    return y;
  }
  if (x.s != y.s) {
    y.s = -y.s;
    return x.minus(y);
  }
  xd = x.d;
  yd = y.d;
  pr = Ctor.precision;
  rm = Ctor.rounding;
  if (!xd[0] || !yd[0]) {
    if (!yd[0])
      y = new Ctor(x);
    return external ? finalise(y, pr, rm) : y;
  }
  k = mathfloor(x.e / LOG_BASE);
  e = mathfloor(y.e / LOG_BASE);
  xd = xd.slice();
  i = k - e;
  if (i) {
    if (i < 0) {
      d = xd;
      i = -i;
      len = yd.length;
    } else {
      d = yd;
      e = k;
      len = xd.length;
    }
    k = Math.ceil(pr / LOG_BASE);
    len = k > len ? k + 1 : len + 1;
    if (i > len) {
      i = len;
      d.length = 1;
    }
    d.reverse();
    for (; i--; )
      d.push(0);
    d.reverse();
  }
  len = xd.length;
  i = yd.length;
  if (len - i < 0) {
    i = len;
    d = yd;
    yd = xd;
    xd = d;
  }
  for (carry = 0; i; ) {
    carry = (xd[--i] = xd[i] + yd[i] + carry) / BASE | 0;
    xd[i] %= BASE;
  }
  if (carry) {
    xd.unshift(carry);
    ++e;
  }
  for (len = xd.length; xd[--len] == 0; )
    xd.pop();
  y.d = xd;
  y.e = getBase10Exponent(xd, e);
  return external ? finalise(y, pr, rm) : y;
};
P.precision = P.sd = function(z) {
  var k, x = this;
  if (z !== void 0 && z !== !!z && z !== 1 && z !== 0)
    throw Error(invalidArgument + z);
  if (x.d) {
    k = getPrecision(x.d);
    if (z && x.e + 1 > k)
      k = x.e + 1;
  } else {
    k = NaN;
  }
  return k;
};
P.round = function() {
  var x = this, Ctor = x.constructor;
  return finalise(new Ctor(x), x.e + 1, Ctor.rounding);
};
P.sine = P.sin = function() {
  var pr, rm, x = this, Ctor = x.constructor;
  if (!x.isFinite())
    return new Ctor(NaN);
  if (x.isZero())
    return new Ctor(x);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  Ctor.precision = pr + Math.max(x.e, x.sd()) + LOG_BASE;
  Ctor.rounding = 1;
  x = sine(Ctor, toLessThanHalfPi(Ctor, x));
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return finalise(quadrant > 2 ? x.neg() : x, pr, rm, true);
};
P.squareRoot = P.sqrt = function() {
  var m, n, sd, r, rep, t, x = this, d = x.d, e = x.e, s = x.s, Ctor = x.constructor;
  if (s !== 1 || !d || !d[0]) {
    return new Ctor(!s || s < 0 && (!d || d[0]) ? NaN : d ? x : 1 / 0);
  }
  external = false;
  s = Math.sqrt(+x);
  if (s == 0 || s == 1 / 0) {
    n = digitsToString(d);
    if ((n.length + e) % 2 == 0)
      n += "0";
    s = Math.sqrt(n);
    e = mathfloor((e + 1) / 2) - (e < 0 || e % 2);
    if (s == 1 / 0) {
      n = "5e" + e;
    } else {
      n = s.toExponential();
      n = n.slice(0, n.indexOf("e") + 1) + e;
    }
    r = new Ctor(n);
  } else {
    r = new Ctor(s.toString());
  }
  sd = (e = Ctor.precision) + 3;
  for (; ; ) {
    t = r;
    r = t.plus(divide(x, t, sd + 2, 1)).times(0.5);
    if (digitsToString(t.d).slice(0, sd) === (n = digitsToString(r.d)).slice(0, sd)) {
      n = n.slice(sd - 3, sd + 1);
      if (n == "9999" || !rep && n == "4999") {
        if (!rep) {
          finalise(t, e + 1, 0);
          if (t.times(t).eq(x)) {
            r = t;
            break;
          }
        }
        sd += 4;
        rep = 1;
      } else {
        if (!+n || !+n.slice(1) && n.charAt(0) == "5") {
          finalise(r, e + 1, 1);
          m = !r.times(r).eq(x);
        }
        break;
      }
    }
  }
  external = true;
  return finalise(r, e, Ctor.rounding, m);
};
P.tangent = P.tan = function() {
  var pr, rm, x = this, Ctor = x.constructor;
  if (!x.isFinite())
    return new Ctor(NaN);
  if (x.isZero())
    return new Ctor(x);
  pr = Ctor.precision;
  rm = Ctor.rounding;
  Ctor.precision = pr + 10;
  Ctor.rounding = 1;
  x = x.sin();
  x.s = 1;
  x = divide(x, new Ctor(1).minus(x.times(x)).sqrt(), pr + 10, 0);
  Ctor.precision = pr;
  Ctor.rounding = rm;
  return finalise(quadrant == 2 || quadrant == 4 ? x.neg() : x, pr, rm, true);
};
P.times = P.mul = function(y) {
  var carry, e, i, k, r, rL, t, xdL, ydL, x = this, Ctor = x.constructor, xd = x.d, yd = (y = new Ctor(y)).d;
  y.s *= x.s;
  if (!xd || !xd[0] || !yd || !yd[0]) {
    return new Ctor(!y.s || xd && !xd[0] && !yd || yd && !yd[0] && !xd ? NaN : !xd || !yd ? y.s / 0 : y.s * 0);
  }
  e = mathfloor(x.e / LOG_BASE) + mathfloor(y.e / LOG_BASE);
  xdL = xd.length;
  ydL = yd.length;
  if (xdL < ydL) {
    r = xd;
    xd = yd;
    yd = r;
    rL = xdL;
    xdL = ydL;
    ydL = rL;
  }
  r = [];
  rL = xdL + ydL;
  for (i = rL; i--; )
    r.push(0);
  for (i = ydL; --i >= 0; ) {
    carry = 0;
    for (k = xdL + i; k > i; ) {
      t = r[k] + yd[i] * xd[k - i - 1] + carry;
      r[k--] = t % BASE | 0;
      carry = t / BASE | 0;
    }
    r[k] = (r[k] + carry) % BASE | 0;
  }
  for (; !r[--rL]; )
    r.pop();
  if (carry)
    ++e;
  else
    r.shift();
  y.d = r;
  y.e = getBase10Exponent(r, e);
  return external ? finalise(y, Ctor.precision, Ctor.rounding) : y;
};
P.toBinary = function(sd, rm) {
  return toStringBinary(this, 2, sd, rm);
};
P.toDecimalPlaces = P.toDP = function(dp, rm) {
  var x = this, Ctor = x.constructor;
  x = new Ctor(x);
  if (dp === void 0)
    return x;
  checkInt32(dp, 0, MAX_DIGITS);
  if (rm === void 0)
    rm = Ctor.rounding;
  else
    checkInt32(rm, 0, 8);
  return finalise(x, dp + x.e + 1, rm);
};
P.toExponential = function(dp, rm) {
  var str, x = this, Ctor = x.constructor;
  if (dp === void 0) {
    str = finiteToString(x, true);
  } else {
    checkInt32(dp, 0, MAX_DIGITS);
    if (rm === void 0)
      rm = Ctor.rounding;
    else
      checkInt32(rm, 0, 8);
    x = finalise(new Ctor(x), dp + 1, rm);
    str = finiteToString(x, true, dp + 1);
  }
  return x.isNeg() && !x.isZero() ? "-" + str : str;
};
P.toFixed = function(dp, rm) {
  var str, y, x = this, Ctor = x.constructor;
  if (dp === void 0) {
    str = finiteToString(x);
  } else {
    checkInt32(dp, 0, MAX_DIGITS);
    if (rm === void 0)
      rm = Ctor.rounding;
    else
      checkInt32(rm, 0, 8);
    y = finalise(new Ctor(x), dp + x.e + 1, rm);
    str = finiteToString(y, false, dp + y.e + 1);
  }
  return x.isNeg() && !x.isZero() ? "-" + str : str;
};
P.toFraction = function(maxD) {
  var d, d0, d1, d2, e, k, n, n0, n1, pr, q, r, x = this, xd = x.d, Ctor = x.constructor;
  if (!xd)
    return new Ctor(x);
  n1 = d0 = new Ctor(1);
  d1 = n0 = new Ctor(0);
  d = new Ctor(d1);
  e = d.e = getPrecision(xd) - x.e - 1;
  k = e % LOG_BASE;
  d.d[0] = mathpow(10, k < 0 ? LOG_BASE + k : k);
  if (maxD == null) {
    maxD = e > 0 ? d : n1;
  } else {
    n = new Ctor(maxD);
    if (!n.isInt() || n.lt(n1))
      throw Error(invalidArgument + n);
    maxD = n.gt(d) ? e > 0 ? d : n1 : n;
  }
  external = false;
  n = new Ctor(digitsToString(xd));
  pr = Ctor.precision;
  Ctor.precision = e = xd.length * LOG_BASE * 2;
  for (; ; ) {
    q = divide(n, d, 0, 1, 1);
    d2 = d0.plus(q.times(d1));
    if (d2.cmp(maxD) == 1)
      break;
    d0 = d1;
    d1 = d2;
    d2 = n1;
    n1 = n0.plus(q.times(d2));
    n0 = d2;
    d2 = d;
    d = n.minus(q.times(d2));
    n = d2;
  }
  d2 = divide(maxD.minus(d0), d1, 0, 1, 1);
  n0 = n0.plus(d2.times(n1));
  d0 = d0.plus(d2.times(d1));
  n0.s = n1.s = x.s;
  r = divide(n1, d1, e, 1).minus(x).abs().cmp(divide(n0, d0, e, 1).minus(x).abs()) < 1 ? [n1, d1] : [n0, d0];
  Ctor.precision = pr;
  external = true;
  return r;
};
P.toHexadecimal = P.toHex = function(sd, rm) {
  return toStringBinary(this, 16, sd, rm);
};
P.toNearest = function(y, rm) {
  var x = this, Ctor = x.constructor;
  x = new Ctor(x);
  if (y == null) {
    if (!x.d)
      return x;
    y = new Ctor(1);
    rm = Ctor.rounding;
  } else {
    y = new Ctor(y);
    if (rm === void 0) {
      rm = Ctor.rounding;
    } else {
      checkInt32(rm, 0, 8);
    }
    if (!x.d)
      return y.s ? x : y;
    if (!y.d) {
      if (y.s)
        y.s = x.s;
      return y;
    }
  }
  if (y.d[0]) {
    external = false;
    x = divide(x, y, 0, rm, 1).times(y);
    external = true;
    finalise(x);
  } else {
    y.s = x.s;
    x = y;
  }
  return x;
};
P.toNumber = function() {
  return +this;
};
P.toOctal = function(sd, rm) {
  return toStringBinary(this, 8, sd, rm);
};
P.toPower = P.pow = function(y) {
  var e, k, pr, r, rm, s, x = this, Ctor = x.constructor, yn = +(y = new Ctor(y));
  if (!x.d || !y.d || !x.d[0] || !y.d[0])
    return new Ctor(mathpow(+x, yn));
  x = new Ctor(x);
  if (x.eq(1))
    return x;
  pr = Ctor.precision;
  rm = Ctor.rounding;
  if (y.eq(1))
    return finalise(x, pr, rm);
  e = mathfloor(y.e / LOG_BASE);
  if (e >= y.d.length - 1 && (k = yn < 0 ? -yn : yn) <= MAX_SAFE_INTEGER) {
    r = intPow(Ctor, x, k, pr);
    return y.s < 0 ? new Ctor(1).div(r) : finalise(r, pr, rm);
  }
  s = x.s;
  if (s < 0) {
    if (e < y.d.length - 1)
      return new Ctor(NaN);
    if ((y.d[e] & 1) == 0)
      s = 1;
    if (x.e == 0 && x.d[0] == 1 && x.d.length == 1) {
      x.s = s;
      return x;
    }
  }
  k = mathpow(+x, yn);
  e = k == 0 || !isFinite(k) ? mathfloor(yn * (Math.log("0." + digitsToString(x.d)) / Math.LN10 + x.e + 1)) : new Ctor(k + "").e;
  if (e > Ctor.maxE + 1 || e < Ctor.minE - 1)
    return new Ctor(e > 0 ? s / 0 : 0);
  external = false;
  Ctor.rounding = x.s = 1;
  k = Math.min(12, (e + "").length);
  r = naturalExponential(y.times(naturalLogarithm(x, pr + k)), pr);
  if (r.d) {
    r = finalise(r, pr + 5, 1);
    if (checkRoundingDigits(r.d, pr, rm)) {
      e = pr + 10;
      r = finalise(naturalExponential(y.times(naturalLogarithm(x, e + k)), e), e + 5, 1);
      if (+digitsToString(r.d).slice(pr + 1, pr + 15) + 1 == 1e14) {
        r = finalise(r, pr + 1, 0);
      }
    }
  }
  r.s = s;
  external = true;
  Ctor.rounding = rm;
  return finalise(r, pr, rm);
};
P.toPrecision = function(sd, rm) {
  var str, x = this, Ctor = x.constructor;
  if (sd === void 0) {
    str = finiteToString(x, x.e <= Ctor.toExpNeg || x.e >= Ctor.toExpPos);
  } else {
    checkInt32(sd, 1, MAX_DIGITS);
    if (rm === void 0)
      rm = Ctor.rounding;
    else
      checkInt32(rm, 0, 8);
    x = finalise(new Ctor(x), sd, rm);
    str = finiteToString(x, sd <= x.e || x.e <= Ctor.toExpNeg, sd);
  }
  return x.isNeg() && !x.isZero() ? "-" + str : str;
};
P.toSignificantDigits = P.toSD = function(sd, rm) {
  var x = this, Ctor = x.constructor;
  if (sd === void 0) {
    sd = Ctor.precision;
    rm = Ctor.rounding;
  } else {
    checkInt32(sd, 1, MAX_DIGITS);
    if (rm === void 0)
      rm = Ctor.rounding;
    else
      checkInt32(rm, 0, 8);
  }
  return finalise(new Ctor(x), sd, rm);
};
P.toString = function() {
  var x = this, Ctor = x.constructor, str = finiteToString(x, x.e <= Ctor.toExpNeg || x.e >= Ctor.toExpPos);
  return x.isNeg() && !x.isZero() ? "-" + str : str;
};
P.truncated = P.trunc = function() {
  return finalise(new this.constructor(this), this.e + 1, 1);
};
P.valueOf = P.toJSON = function() {
  var x = this, Ctor = x.constructor, str = finiteToString(x, x.e <= Ctor.toExpNeg || x.e >= Ctor.toExpPos);
  return x.isNeg() ? "-" + str : str;
};
function digitsToString(d) {
  var i, k, ws, indexOfLastWord = d.length - 1, str = "", w = d[0];
  if (indexOfLastWord > 0) {
    str += w;
    for (i = 1; i < indexOfLastWord; i++) {
      ws = d[i] + "";
      k = LOG_BASE - ws.length;
      if (k)
        str += getZeroString(k);
      str += ws;
    }
    w = d[i];
    ws = w + "";
    k = LOG_BASE - ws.length;
    if (k)
      str += getZeroString(k);
  } else if (w === 0) {
    return "0";
  }
  for (; w % 10 === 0; )
    w /= 10;
  return str + w;
}
function checkInt32(i, min2, max2) {
  if (i !== ~~i || i < min2 || i > max2) {
    throw Error(invalidArgument + i);
  }
}
function checkRoundingDigits(d, i, rm, repeating) {
  var di, k, r, rd;
  for (k = d[0]; k >= 10; k /= 10)
    --i;
  if (--i < 0) {
    i += LOG_BASE;
    di = 0;
  } else {
    di = Math.ceil((i + 1) / LOG_BASE);
    i %= LOG_BASE;
  }
  k = mathpow(10, LOG_BASE - i);
  rd = d[di] % k | 0;
  if (repeating == null) {
    if (i < 3) {
      if (i == 0)
        rd = rd / 100 | 0;
      else if (i == 1)
        rd = rd / 10 | 0;
      r = rm < 4 && rd == 99999 || rm > 3 && rd == 49999 || rd == 5e4 || rd == 0;
    } else {
      r = (rm < 4 && rd + 1 == k || rm > 3 && rd + 1 == k / 2) && (d[di + 1] / k / 100 | 0) == mathpow(10, i - 2) - 1 || (rd == k / 2 || rd == 0) && (d[di + 1] / k / 100 | 0) == 0;
    }
  } else {
    if (i < 4) {
      if (i == 0)
        rd = rd / 1e3 | 0;
      else if (i == 1)
        rd = rd / 100 | 0;
      else if (i == 2)
        rd = rd / 10 | 0;
      r = (repeating || rm < 4) && rd == 9999 || !repeating && rm > 3 && rd == 4999;
    } else {
      r = ((repeating || rm < 4) && rd + 1 == k || !repeating && rm > 3 && rd + 1 == k / 2) && (d[di + 1] / k / 1e3 | 0) == mathpow(10, i - 3) - 1;
    }
  }
  return r;
}
function convertBase(str, baseIn, baseOut) {
  var j, arr = [0], arrL, i = 0, strL = str.length;
  for (; i < strL; ) {
    for (arrL = arr.length; arrL--; )
      arr[arrL] *= baseIn;
    arr[0] += NUMERALS.indexOf(str.charAt(i++));
    for (j = 0; j < arr.length; j++) {
      if (arr[j] > baseOut - 1) {
        if (arr[j + 1] === void 0)
          arr[j + 1] = 0;
        arr[j + 1] += arr[j] / baseOut | 0;
        arr[j] %= baseOut;
      }
    }
  }
  return arr.reverse();
}
function cosine(Ctor, x) {
  var k, len, y;
  if (x.isZero())
    return x;
  len = x.d.length;
  if (len < 32) {
    k = Math.ceil(len / 3);
    y = (1 / tinyPow(4, k)).toString();
  } else {
    k = 16;
    y = "2.3283064365386962890625e-10";
  }
  Ctor.precision += k;
  x = taylorSeries(Ctor, 1, x.times(y), new Ctor(1));
  for (var i = k; i--; ) {
    var cos2x = x.times(x);
    x = cos2x.times(cos2x).minus(cos2x).times(8).plus(1);
  }
  Ctor.precision -= k;
  return x;
}
var divide = function() {
  function multiplyInteger(x, k, base) {
    var temp, carry = 0, i = x.length;
    for (x = x.slice(); i--; ) {
      temp = x[i] * k + carry;
      x[i] = temp % base | 0;
      carry = temp / base | 0;
    }
    if (carry)
      x.unshift(carry);
    return x;
  }
  function compare(a, b, aL, bL) {
    var i, r;
    if (aL != bL) {
      r = aL > bL ? 1 : -1;
    } else {
      for (i = r = 0; i < aL; i++) {
        if (a[i] != b[i]) {
          r = a[i] > b[i] ? 1 : -1;
          break;
        }
      }
    }
    return r;
  }
  function subtract(a, b, aL, base) {
    var i = 0;
    for (; aL--; ) {
      a[aL] -= i;
      i = a[aL] < b[aL] ? 1 : 0;
      a[aL] = i * base + a[aL] - b[aL];
    }
    for (; !a[0] && a.length > 1; )
      a.shift();
  }
  return function(x, y, pr, rm, dp, base) {
    var cmp, e, i, k, logBase, more, prod, prodL, q, qd, rem, remL, rem0, sd, t, xi, xL, yd0, yL, yz, Ctor = x.constructor, sign2 = x.s == y.s ? 1 : -1, xd = x.d, yd = y.d;
    if (!xd || !xd[0] || !yd || !yd[0]) {
      return new Ctor(!x.s || !y.s || (xd ? yd && xd[0] == yd[0] : !yd) ? NaN : xd && xd[0] == 0 || !yd ? sign2 * 0 : sign2 / 0);
    }
    if (base) {
      logBase = 1;
      e = x.e - y.e;
    } else {
      base = BASE;
      logBase = LOG_BASE;
      e = mathfloor(x.e / logBase) - mathfloor(y.e / logBase);
    }
    yL = yd.length;
    xL = xd.length;
    q = new Ctor(sign2);
    qd = q.d = [];
    for (i = 0; yd[i] == (xd[i] || 0); i++)
      ;
    if (yd[i] > (xd[i] || 0))
      e--;
    if (pr == null) {
      sd = pr = Ctor.precision;
      rm = Ctor.rounding;
    } else if (dp) {
      sd = pr + (x.e - y.e) + 1;
    } else {
      sd = pr;
    }
    if (sd < 0) {
      qd.push(1);
      more = true;
    } else {
      sd = sd / logBase + 2 | 0;
      i = 0;
      if (yL == 1) {
        k = 0;
        yd = yd[0];
        sd++;
        for (; (i < xL || k) && sd--; i++) {
          t = k * base + (xd[i] || 0);
          qd[i] = t / yd | 0;
          k = t % yd | 0;
        }
        more = k || i < xL;
      } else {
        k = base / (yd[0] + 1) | 0;
        if (k > 1) {
          yd = multiplyInteger(yd, k, base);
          xd = multiplyInteger(xd, k, base);
          yL = yd.length;
          xL = xd.length;
        }
        xi = yL;
        rem = xd.slice(0, yL);
        remL = rem.length;
        for (; remL < yL; )
          rem[remL++] = 0;
        yz = yd.slice();
        yz.unshift(0);
        yd0 = yd[0];
        if (yd[1] >= base / 2)
          ++yd0;
        do {
          k = 0;
          cmp = compare(yd, rem, yL, remL);
          if (cmp < 0) {
            rem0 = rem[0];
            if (yL != remL)
              rem0 = rem0 * base + (rem[1] || 0);
            k = rem0 / yd0 | 0;
            if (k > 1) {
              if (k >= base)
                k = base - 1;
              prod = multiplyInteger(yd, k, base);
              prodL = prod.length;
              remL = rem.length;
              cmp = compare(prod, rem, prodL, remL);
              if (cmp == 1) {
                k--;
                subtract(prod, yL < prodL ? yz : yd, prodL, base);
              }
            } else {
              if (k == 0)
                cmp = k = 1;
              prod = yd.slice();
            }
            prodL = prod.length;
            if (prodL < remL)
              prod.unshift(0);
            subtract(rem, prod, remL, base);
            if (cmp == -1) {
              remL = rem.length;
              cmp = compare(yd, rem, yL, remL);
              if (cmp < 1) {
                k++;
                subtract(rem, yL < remL ? yz : yd, remL, base);
              }
            }
            remL = rem.length;
          } else if (cmp === 0) {
            k++;
            rem = [0];
          }
          qd[i++] = k;
          if (cmp && rem[0]) {
            rem[remL++] = xd[xi] || 0;
          } else {
            rem = [xd[xi]];
            remL = 1;
          }
        } while ((xi++ < xL || rem[0] !== void 0) && sd--);
        more = rem[0] !== void 0;
      }
      if (!qd[0])
        qd.shift();
    }
    if (logBase == 1) {
      q.e = e;
      inexact = more;
    } else {
      for (i = 1, k = qd[0]; k >= 10; k /= 10)
        i++;
      q.e = i + e * logBase - 1;
      finalise(q, dp ? pr + q.e + 1 : pr, rm, more);
    }
    return q;
  };
}();
function finalise(x, sd, rm, isTruncated) {
  var digits2, i, j, k, rd, roundUp, w, xd, xdi, Ctor = x.constructor;
  out:
    if (sd != null) {
      xd = x.d;
      if (!xd)
        return x;
      for (digits2 = 1, k = xd[0]; k >= 10; k /= 10)
        digits2++;
      i = sd - digits2;
      if (i < 0) {
        i += LOG_BASE;
        j = sd;
        w = xd[xdi = 0];
        rd = w / mathpow(10, digits2 - j - 1) % 10 | 0;
      } else {
        xdi = Math.ceil((i + 1) / LOG_BASE);
        k = xd.length;
        if (xdi >= k) {
          if (isTruncated) {
            for (; k++ <= xdi; )
              xd.push(0);
            w = rd = 0;
            digits2 = 1;
            i %= LOG_BASE;
            j = i - LOG_BASE + 1;
          } else {
            break out;
          }
        } else {
          w = k = xd[xdi];
          for (digits2 = 1; k >= 10; k /= 10)
            digits2++;
          i %= LOG_BASE;
          j = i - LOG_BASE + digits2;
          rd = j < 0 ? 0 : w / mathpow(10, digits2 - j - 1) % 10 | 0;
        }
      }
      isTruncated = isTruncated || sd < 0 || xd[xdi + 1] !== void 0 || (j < 0 ? w : w % mathpow(10, digits2 - j - 1));
      roundUp = rm < 4 ? (rd || isTruncated) && (rm == 0 || rm == (x.s < 0 ? 3 : 2)) : rd > 5 || rd == 5 && (rm == 4 || isTruncated || rm == 6 && (i > 0 ? j > 0 ? w / mathpow(10, digits2 - j) : 0 : xd[xdi - 1]) % 10 & 1 || rm == (x.s < 0 ? 8 : 7));
      if (sd < 1 || !xd[0]) {
        xd.length = 0;
        if (roundUp) {
          sd -= x.e + 1;
          xd[0] = mathpow(10, (LOG_BASE - sd % LOG_BASE) % LOG_BASE);
          x.e = -sd || 0;
        } else {
          xd[0] = x.e = 0;
        }
        return x;
      }
      if (i == 0) {
        xd.length = xdi;
        k = 1;
        xdi--;
      } else {
        xd.length = xdi + 1;
        k = mathpow(10, LOG_BASE - i);
        xd[xdi] = j > 0 ? (w / mathpow(10, digits2 - j) % mathpow(10, j) | 0) * k : 0;
      }
      if (roundUp) {
        for (; ; ) {
          if (xdi == 0) {
            for (i = 1, j = xd[0]; j >= 10; j /= 10)
              i++;
            j = xd[0] += k;
            for (k = 1; j >= 10; j /= 10)
              k++;
            if (i != k) {
              x.e++;
              if (xd[0] == BASE)
                xd[0] = 1;
            }
            break;
          } else {
            xd[xdi] += k;
            if (xd[xdi] != BASE)
              break;
            xd[xdi--] = 0;
            k = 1;
          }
        }
      }
      for (i = xd.length; xd[--i] === 0; )
        xd.pop();
    }
  if (external) {
    if (x.e > Ctor.maxE) {
      x.d = null;
      x.e = NaN;
    } else if (x.e < Ctor.minE) {
      x.e = 0;
      x.d = [0];
    }
  }
  return x;
}
function finiteToString(x, isExp, sd) {
  if (!x.isFinite())
    return nonFiniteToString(x);
  var k, e = x.e, str = digitsToString(x.d), len = str.length;
  if (isExp) {
    if (sd && (k = sd - len) > 0) {
      str = str.charAt(0) + "." + str.slice(1) + getZeroString(k);
    } else if (len > 1) {
      str = str.charAt(0) + "." + str.slice(1);
    }
    str = str + (x.e < 0 ? "e" : "e+") + x.e;
  } else if (e < 0) {
    str = "0." + getZeroString(-e - 1) + str;
    if (sd && (k = sd - len) > 0)
      str += getZeroString(k);
  } else if (e >= len) {
    str += getZeroString(e + 1 - len);
    if (sd && (k = sd - e - 1) > 0)
      str = str + "." + getZeroString(k);
  } else {
    if ((k = e + 1) < len)
      str = str.slice(0, k) + "." + str.slice(k);
    if (sd && (k = sd - len) > 0) {
      if (e + 1 === len)
        str += ".";
      str += getZeroString(k);
    }
  }
  return str;
}
function getBase10Exponent(digits2, e) {
  var w = digits2[0];
  for (e *= LOG_BASE; w >= 10; w /= 10)
    e++;
  return e;
}
function getLn10(Ctor, sd, pr) {
  if (sd > LN10_PRECISION) {
    external = true;
    if (pr)
      Ctor.precision = pr;
    throw Error(precisionLimitExceeded);
  }
  return finalise(new Ctor(LN10), sd, 1, true);
}
function getPi(Ctor, sd, rm) {
  if (sd > PI_PRECISION)
    throw Error(precisionLimitExceeded);
  return finalise(new Ctor(PI), sd, rm, true);
}
function getPrecision(digits2) {
  var w = digits2.length - 1, len = w * LOG_BASE + 1;
  w = digits2[w];
  if (w) {
    for (; w % 10 == 0; w /= 10)
      len--;
    for (w = digits2[0]; w >= 10; w /= 10)
      len++;
  }
  return len;
}
function getZeroString(k) {
  var zs = "";
  for (; k--; )
    zs += "0";
  return zs;
}
function intPow(Ctor, x, n, pr) {
  var isTruncated, r = new Ctor(1), k = Math.ceil(pr / LOG_BASE + 4);
  external = false;
  for (; ; ) {
    if (n % 2) {
      r = r.times(x);
      if (truncate(r.d, k))
        isTruncated = true;
    }
    n = mathfloor(n / 2);
    if (n === 0) {
      n = r.d.length - 1;
      if (isTruncated && r.d[n] === 0)
        ++r.d[n];
      break;
    }
    x = x.times(x);
    truncate(x.d, k);
  }
  external = true;
  return r;
}
function isOdd(n) {
  return n.d[n.d.length - 1] & 1;
}
function maxOrMin(Ctor, args, n) {
  var k, y, x = new Ctor(args[0]), i = 0;
  for (; ++i < args.length; ) {
    y = new Ctor(args[i]);
    if (!y.s) {
      x = y;
      break;
    }
    k = x.cmp(y);
    if (k === n || k === 0 && x.s === n) {
      x = y;
    }
  }
  return x;
}
function naturalExponential(x, sd) {
  var denominator, guard, j, pow2, sum2, t, wpr, rep = 0, i = 0, k = 0, Ctor = x.constructor, rm = Ctor.rounding, pr = Ctor.precision;
  if (!x.d || !x.d[0] || x.e > 17) {
    return new Ctor(x.d ? !x.d[0] ? 1 : x.s < 0 ? 0 : 1 / 0 : x.s ? x.s < 0 ? 0 : x : 0 / 0);
  }
  if (sd == null) {
    external = false;
    wpr = pr;
  } else {
    wpr = sd;
  }
  t = new Ctor(0.03125);
  while (x.e > -2) {
    x = x.times(t);
    k += 5;
  }
  guard = Math.log(mathpow(2, k)) / Math.LN10 * 2 + 5 | 0;
  wpr += guard;
  denominator = pow2 = sum2 = new Ctor(1);
  Ctor.precision = wpr;
  for (; ; ) {
    pow2 = finalise(pow2.times(x), wpr, 1);
    denominator = denominator.times(++i);
    t = sum2.plus(divide(pow2, denominator, wpr, 1));
    if (digitsToString(t.d).slice(0, wpr) === digitsToString(sum2.d).slice(0, wpr)) {
      j = k;
      while (j--)
        sum2 = finalise(sum2.times(sum2), wpr, 1);
      if (sd == null) {
        if (rep < 3 && checkRoundingDigits(sum2.d, wpr - guard, rm, rep)) {
          Ctor.precision = wpr += 10;
          denominator = pow2 = t = new Ctor(1);
          i = 0;
          rep++;
        } else {
          return finalise(sum2, Ctor.precision = pr, rm, external = true);
        }
      } else {
        Ctor.precision = pr;
        return sum2;
      }
    }
    sum2 = t;
  }
}
function naturalLogarithm(y, sd) {
  var c, c0, denominator, e, numerator, rep, sum2, t, wpr, x1, x2, n = 1, guard = 10, x = y, xd = x.d, Ctor = x.constructor, rm = Ctor.rounding, pr = Ctor.precision;
  if (x.s < 0 || !xd || !xd[0] || !x.e && xd[0] == 1 && xd.length == 1) {
    return new Ctor(xd && !xd[0] ? -1 / 0 : x.s != 1 ? NaN : xd ? 0 : x);
  }
  if (sd == null) {
    external = false;
    wpr = pr;
  } else {
    wpr = sd;
  }
  Ctor.precision = wpr += guard;
  c = digitsToString(xd);
  c0 = c.charAt(0);
  if (Math.abs(e = x.e) < 15e14) {
    while (c0 < 7 && c0 != 1 || c0 == 1 && c.charAt(1) > 3) {
      x = x.times(y);
      c = digitsToString(x.d);
      c0 = c.charAt(0);
      n++;
    }
    e = x.e;
    if (c0 > 1) {
      x = new Ctor("0." + c);
      e++;
    } else {
      x = new Ctor(c0 + "." + c.slice(1));
    }
  } else {
    t = getLn10(Ctor, wpr + 2, pr).times(e + "");
    x = naturalLogarithm(new Ctor(c0 + "." + c.slice(1)), wpr - guard).plus(t);
    Ctor.precision = pr;
    return sd == null ? finalise(x, pr, rm, external = true) : x;
  }
  x1 = x;
  sum2 = numerator = x = divide(x.minus(1), x.plus(1), wpr, 1);
  x2 = finalise(x.times(x), wpr, 1);
  denominator = 3;
  for (; ; ) {
    numerator = finalise(numerator.times(x2), wpr, 1);
    t = sum2.plus(divide(numerator, new Ctor(denominator), wpr, 1));
    if (digitsToString(t.d).slice(0, wpr) === digitsToString(sum2.d).slice(0, wpr)) {
      sum2 = sum2.times(2);
      if (e !== 0)
        sum2 = sum2.plus(getLn10(Ctor, wpr + 2, pr).times(e + ""));
      sum2 = divide(sum2, new Ctor(n), wpr, 1);
      if (sd == null) {
        if (checkRoundingDigits(sum2.d, wpr - guard, rm, rep)) {
          Ctor.precision = wpr += guard;
          t = numerator = x = divide(x1.minus(1), x1.plus(1), wpr, 1);
          x2 = finalise(x.times(x), wpr, 1);
          denominator = rep = 1;
        } else {
          return finalise(sum2, Ctor.precision = pr, rm, external = true);
        }
      } else {
        Ctor.precision = pr;
        return sum2;
      }
    }
    sum2 = t;
    denominator += 2;
  }
}
function nonFiniteToString(x) {
  return String(x.s * x.s / 0);
}
function parseDecimal(x, str) {
  var e, i, len;
  if ((e = str.indexOf(".")) > -1)
    str = str.replace(".", "");
  if ((i = str.search(/e/i)) > 0) {
    if (e < 0)
      e = i;
    e += +str.slice(i + 1);
    str = str.substring(0, i);
  } else if (e < 0) {
    e = str.length;
  }
  for (i = 0; str.charCodeAt(i) === 48; i++)
    ;
  for (len = str.length; str.charCodeAt(len - 1) === 48; --len)
    ;
  str = str.slice(i, len);
  if (str) {
    len -= i;
    x.e = e = e - i - 1;
    x.d = [];
    i = (e + 1) % LOG_BASE;
    if (e < 0)
      i += LOG_BASE;
    if (i < len) {
      if (i)
        x.d.push(+str.slice(0, i));
      for (len -= LOG_BASE; i < len; )
        x.d.push(+str.slice(i, i += LOG_BASE));
      str = str.slice(i);
      i = LOG_BASE - str.length;
    } else {
      i -= len;
    }
    for (; i--; )
      str += "0";
    x.d.push(+str);
    if (external) {
      if (x.e > x.constructor.maxE) {
        x.d = null;
        x.e = NaN;
      } else if (x.e < x.constructor.minE) {
        x.e = 0;
        x.d = [0];
      }
    }
  } else {
    x.e = 0;
    x.d = [0];
  }
  return x;
}
function parseOther(x, str) {
  var base, Ctor, divisor, i, isFloat, len, p, xd, xe;
  if (str.indexOf("_") > -1) {
    str = str.replace(/(\d)_(?=\d)/g, "$1");
    if (isDecimal.test(str))
      return parseDecimal(x, str);
  } else if (str === "Infinity" || str === "NaN") {
    if (!+str)
      x.s = NaN;
    x.e = NaN;
    x.d = null;
    return x;
  }
  if (isHex.test(str)) {
    base = 16;
    str = str.toLowerCase();
  } else if (isBinary.test(str)) {
    base = 2;
  } else if (isOctal.test(str)) {
    base = 8;
  } else {
    throw Error(invalidArgument + str);
  }
  i = str.search(/p/i);
  if (i > 0) {
    p = +str.slice(i + 1);
    str = str.substring(2, i);
  } else {
    str = str.slice(2);
  }
  i = str.indexOf(".");
  isFloat = i >= 0;
  Ctor = x.constructor;
  if (isFloat) {
    str = str.replace(".", "");
    len = str.length;
    i = len - i;
    divisor = intPow(Ctor, new Ctor(base), i, i * 2);
  }
  xd = convertBase(str, base, BASE);
  xe = xd.length - 1;
  for (i = xe; xd[i] === 0; --i)
    xd.pop();
  if (i < 0)
    return new Ctor(x.s * 0);
  x.e = getBase10Exponent(xd, xe);
  x.d = xd;
  external = false;
  if (isFloat)
    x = divide(x, divisor, len * 4);
  if (p)
    x = x.times(Math.abs(p) < 54 ? mathpow(2, p) : Decimal.pow(2, p));
  external = true;
  return x;
}
function sine(Ctor, x) {
  var k, len = x.d.length;
  if (len < 3) {
    return x.isZero() ? x : taylorSeries(Ctor, 2, x, x);
  }
  k = 1.4 * Math.sqrt(len);
  k = k > 16 ? 16 : k | 0;
  x = x.times(1 / tinyPow(5, k));
  x = taylorSeries(Ctor, 2, x, x);
  var sin2_x, d5 = new Ctor(5), d16 = new Ctor(16), d20 = new Ctor(20);
  for (; k--; ) {
    sin2_x = x.times(x);
    x = x.times(d5.plus(sin2_x.times(d16.times(sin2_x).minus(d20))));
  }
  return x;
}
function taylorSeries(Ctor, n, x, y, isHyperbolic) {
  var j, t, u, x2, i = 1, pr = Ctor.precision, k = Math.ceil(pr / LOG_BASE);
  external = false;
  x2 = x.times(x);
  u = new Ctor(y);
  for (; ; ) {
    t = divide(u.times(x2), new Ctor(n++ * n++), pr, 1);
    u = isHyperbolic ? y.plus(t) : y.minus(t);
    y = divide(t.times(x2), new Ctor(n++ * n++), pr, 1);
    t = u.plus(y);
    if (t.d[k] !== void 0) {
      for (j = k; t.d[j] === u.d[j] && j--; )
        ;
      if (j == -1)
        break;
    }
    j = u;
    u = y;
    y = t;
    t = j;
    i++;
  }
  external = true;
  t.d.length = k + 1;
  return t;
}
function tinyPow(b, e) {
  var n = b;
  while (--e)
    n *= b;
  return n;
}
function toLessThanHalfPi(Ctor, x) {
  var t, isNeg = x.s < 0, pi = getPi(Ctor, Ctor.precision, 1), halfPi = pi.times(0.5);
  x = x.abs();
  if (x.lte(halfPi)) {
    quadrant = isNeg ? 4 : 1;
    return x;
  }
  t = x.divToInt(pi);
  if (t.isZero()) {
    quadrant = isNeg ? 3 : 2;
  } else {
    x = x.minus(t.times(pi));
    if (x.lte(halfPi)) {
      quadrant = isOdd(t) ? isNeg ? 2 : 3 : isNeg ? 4 : 1;
      return x;
    }
    quadrant = isOdd(t) ? isNeg ? 1 : 4 : isNeg ? 3 : 2;
  }
  return x.minus(pi).abs();
}
function toStringBinary(x, baseOut, sd, rm) {
  var base, e, i, k, len, roundUp, str, xd, y, Ctor = x.constructor, isExp = sd !== void 0;
  if (isExp) {
    checkInt32(sd, 1, MAX_DIGITS);
    if (rm === void 0)
      rm = Ctor.rounding;
    else
      checkInt32(rm, 0, 8);
  } else {
    sd = Ctor.precision;
    rm = Ctor.rounding;
  }
  if (!x.isFinite()) {
    str = nonFiniteToString(x);
  } else {
    str = finiteToString(x);
    i = str.indexOf(".");
    if (isExp) {
      base = 2;
      if (baseOut == 16) {
        sd = sd * 4 - 3;
      } else if (baseOut == 8) {
        sd = sd * 3 - 2;
      }
    } else {
      base = baseOut;
    }
    if (i >= 0) {
      str = str.replace(".", "");
      y = new Ctor(1);
      y.e = str.length - i;
      y.d = convertBase(finiteToString(y), 10, base);
      y.e = y.d.length;
    }
    xd = convertBase(str, 10, base);
    e = len = xd.length;
    for (; xd[--len] == 0; )
      xd.pop();
    if (!xd[0]) {
      str = isExp ? "0p+0" : "0";
    } else {
      if (i < 0) {
        e--;
      } else {
        x = new Ctor(x);
        x.d = xd;
        x.e = e;
        x = divide(x, y, sd, rm, 0, base);
        xd = x.d;
        e = x.e;
        roundUp = inexact;
      }
      i = xd[sd];
      k = base / 2;
      roundUp = roundUp || xd[sd + 1] !== void 0;
      roundUp = rm < 4 ? (i !== void 0 || roundUp) && (rm === 0 || rm === (x.s < 0 ? 3 : 2)) : i > k || i === k && (rm === 4 || roundUp || rm === 6 && xd[sd - 1] & 1 || rm === (x.s < 0 ? 8 : 7));
      xd.length = sd;
      if (roundUp) {
        for (; ++xd[--sd] > base - 1; ) {
          xd[sd] = 0;
          if (!sd) {
            ++e;
            xd.unshift(1);
          }
        }
      }
      for (len = xd.length; !xd[len - 1]; --len)
        ;
      for (i = 0, str = ""; i < len; i++)
        str += NUMERALS.charAt(xd[i]);
      if (isExp) {
        if (len > 1) {
          if (baseOut == 16 || baseOut == 8) {
            i = baseOut == 16 ? 4 : 3;
            for (--len; len % i; len++)
              str += "0";
            xd = convertBase(str, base, baseOut);
            for (len = xd.length; !xd[len - 1]; --len)
              ;
            for (i = 1, str = "1."; i < len; i++)
              str += NUMERALS.charAt(xd[i]);
          } else {
            str = str.charAt(0) + "." + str.slice(1);
          }
        }
        str = str + (e < 0 ? "p" : "p+") + e;
      } else if (e < 0) {
        for (; ++e; )
          str = "0" + str;
        str = "0." + str;
      } else {
        if (++e > len)
          for (e -= len; e--; )
            str += "0";
        else if (e < len)
          str = str.slice(0, e) + "." + str.slice(e);
      }
    }
    str = (baseOut == 16 ? "0x" : baseOut == 2 ? "0b" : baseOut == 8 ? "0o" : "") + str;
  }
  return x.s < 0 ? "-" + str : str;
}
function truncate(arr, len) {
  if (arr.length > len) {
    arr.length = len;
    return true;
  }
}
function abs(x) {
  return new this(x).abs();
}
function acos(x) {
  return new this(x).acos();
}
function acosh(x) {
  return new this(x).acosh();
}
function add(x, y) {
  return new this(x).plus(y);
}
function asin(x) {
  return new this(x).asin();
}
function asinh(x) {
  return new this(x).asinh();
}
function atan(x) {
  return new this(x).atan();
}
function atanh(x) {
  return new this(x).atanh();
}
function atan2(y, x) {
  y = new this(y);
  x = new this(x);
  var r, pr = this.precision, rm = this.rounding, wpr = pr + 4;
  if (!y.s || !x.s) {
    r = new this(NaN);
  } else if (!y.d && !x.d) {
    r = getPi(this, wpr, 1).times(x.s > 0 ? 0.25 : 0.75);
    r.s = y.s;
  } else if (!x.d || y.isZero()) {
    r = x.s < 0 ? getPi(this, pr, rm) : new this(0);
    r.s = y.s;
  } else if (!y.d || x.isZero()) {
    r = getPi(this, wpr, 1).times(0.5);
    r.s = y.s;
  } else if (x.s < 0) {
    this.precision = wpr;
    this.rounding = 1;
    r = this.atan(divide(y, x, wpr, 1));
    x = getPi(this, wpr, 1);
    this.precision = pr;
    this.rounding = rm;
    r = y.s < 0 ? r.minus(x) : r.plus(x);
  } else {
    r = this.atan(divide(y, x, wpr, 1));
  }
  return r;
}
function cbrt(x) {
  return new this(x).cbrt();
}
function ceil(x) {
  return finalise(x = new this(x), x.e + 1, 2);
}
function clamp(x, min2, max2) {
  return new this(x).clamp(min2, max2);
}
function config3(obj) {
  if (!obj || typeof obj !== "object")
    throw Error(decimalError + "Object expected");
  var i, p, v, useDefaults = obj.defaults === true, ps = [
    "precision",
    1,
    MAX_DIGITS,
    "rounding",
    0,
    8,
    "toExpNeg",
    -EXP_LIMIT,
    0,
    "toExpPos",
    0,
    EXP_LIMIT,
    "maxE",
    0,
    EXP_LIMIT,
    "minE",
    -EXP_LIMIT,
    0,
    "modulo",
    0,
    9
  ];
  for (i = 0; i < ps.length; i += 3) {
    if (p = ps[i], useDefaults)
      this[p] = DEFAULTS[p];
    if ((v = obj[p]) !== void 0) {
      if (mathfloor(v) === v && v >= ps[i + 1] && v <= ps[i + 2])
        this[p] = v;
      else
        throw Error(invalidArgument + p + ": " + v);
    }
  }
  if (p = "crypto", useDefaults)
    this[p] = DEFAULTS[p];
  if ((v = obj[p]) !== void 0) {
    if (v === true || v === false || v === 0 || v === 1) {
      if (v) {
        if (typeof crypto != "undefined" && crypto && (crypto.getRandomValues || crypto.randomBytes)) {
          this[p] = true;
        } else {
          throw Error(cryptoUnavailable);
        }
      } else {
        this[p] = false;
      }
    } else {
      throw Error(invalidArgument + p + ": " + v);
    }
  }
  return this;
}
function cos(x) {
  return new this(x).cos();
}
function cosh(x) {
  return new this(x).cosh();
}
function clone2(obj) {
  var i, p, ps;
  function Decimal2(v) {
    var e, i2, t, x = this;
    if (!(x instanceof Decimal2))
      return new Decimal2(v);
    x.constructor = Decimal2;
    if (isDecimalInstance(v)) {
      x.s = v.s;
      if (external) {
        if (!v.d || v.e > Decimal2.maxE) {
          x.e = NaN;
          x.d = null;
        } else if (v.e < Decimal2.minE) {
          x.e = 0;
          x.d = [0];
        } else {
          x.e = v.e;
          x.d = v.d.slice();
        }
      } else {
        x.e = v.e;
        x.d = v.d ? v.d.slice() : v.d;
      }
      return;
    }
    t = typeof v;
    if (t === "number") {
      if (v === 0) {
        x.s = 1 / v < 0 ? -1 : 1;
        x.e = 0;
        x.d = [0];
        return;
      }
      if (v < 0) {
        v = -v;
        x.s = -1;
      } else {
        x.s = 1;
      }
      if (v === ~~v && v < 1e7) {
        for (e = 0, i2 = v; i2 >= 10; i2 /= 10)
          e++;
        if (external) {
          if (e > Decimal2.maxE) {
            x.e = NaN;
            x.d = null;
          } else if (e < Decimal2.minE) {
            x.e = 0;
            x.d = [0];
          } else {
            x.e = e;
            x.d = [v];
          }
        } else {
          x.e = e;
          x.d = [v];
        }
        return;
      }
      if (v * 0 !== 0) {
        if (!v)
          x.s = NaN;
        x.e = NaN;
        x.d = null;
        return;
      }
      return parseDecimal(x, v.toString());
    }
    if (t === "string") {
      if ((i2 = v.charCodeAt(0)) === 45) {
        v = v.slice(1);
        x.s = -1;
      } else {
        if (i2 === 43)
          v = v.slice(1);
        x.s = 1;
      }
      return isDecimal.test(v) ? parseDecimal(x, v) : parseOther(x, v);
    }
    if (t === "bigint") {
      if (v < 0) {
        v = -v;
        x.s = -1;
      } else {
        x.s = 1;
      }
      return parseDecimal(x, v.toString());
    }
    throw Error(invalidArgument + v);
  }
  Decimal2.prototype = P;
  Decimal2.ROUND_UP = 0;
  Decimal2.ROUND_DOWN = 1;
  Decimal2.ROUND_CEIL = 2;
  Decimal2.ROUND_FLOOR = 3;
  Decimal2.ROUND_HALF_UP = 4;
  Decimal2.ROUND_HALF_DOWN = 5;
  Decimal2.ROUND_HALF_EVEN = 6;
  Decimal2.ROUND_HALF_CEIL = 7;
  Decimal2.ROUND_HALF_FLOOR = 8;
  Decimal2.EUCLID = 9;
  Decimal2.config = Decimal2.set = config3;
  Decimal2.clone = clone2;
  Decimal2.isDecimal = isDecimalInstance;
  Decimal2.abs = abs;
  Decimal2.acos = acos;
  Decimal2.acosh = acosh;
  Decimal2.add = add;
  Decimal2.asin = asin;
  Decimal2.asinh = asinh;
  Decimal2.atan = atan;
  Decimal2.atanh = atanh;
  Decimal2.atan2 = atan2;
  Decimal2.cbrt = cbrt;
  Decimal2.ceil = ceil;
  Decimal2.clamp = clamp;
  Decimal2.cos = cos;
  Decimal2.cosh = cosh;
  Decimal2.div = div;
  Decimal2.exp = exp;
  Decimal2.floor = floor;
  Decimal2.hypot = hypot;
  Decimal2.ln = ln;
  Decimal2.log = log;
  Decimal2.log10 = log10;
  Decimal2.log2 = log2;
  Decimal2.max = max;
  Decimal2.min = min;
  Decimal2.mod = mod;
  Decimal2.mul = mul;
  Decimal2.pow = pow;
  Decimal2.random = random;
  Decimal2.round = round;
  Decimal2.sign = sign;
  Decimal2.sin = sin;
  Decimal2.sinh = sinh;
  Decimal2.sqrt = sqrt;
  Decimal2.sub = sub;
  Decimal2.sum = sum;
  Decimal2.tan = tan;
  Decimal2.tanh = tanh;
  Decimal2.trunc = trunc;
  if (obj === void 0)
    obj = {};
  if (obj) {
    if (obj.defaults !== true) {
      ps = ["precision", "rounding", "toExpNeg", "toExpPos", "maxE", "minE", "modulo", "crypto"];
      for (i = 0; i < ps.length; )
        if (!obj.hasOwnProperty(p = ps[i++]))
          obj[p] = this[p];
    }
  }
  Decimal2.config(obj);
  return Decimal2;
}
function div(x, y) {
  return new this(x).div(y);
}
function exp(x) {
  return new this(x).exp();
}
function floor(x) {
  return finalise(x = new this(x), x.e + 1, 3);
}
function hypot() {
  var i, n, t = new this(0);
  external = false;
  for (i = 0; i < arguments.length; ) {
    n = new this(arguments[i++]);
    if (!n.d) {
      if (n.s) {
        external = true;
        return new this(1 / 0);
      }
      t = n;
    } else if (t.d) {
      t = t.plus(n.times(n));
    }
  }
  external = true;
  return t.sqrt();
}
function isDecimalInstance(obj) {
  return obj instanceof Decimal || obj && obj.toStringTag === tag || false;
}
function ln(x) {
  return new this(x).ln();
}
function log(x, y) {
  return new this(x).log(y);
}
function log2(x) {
  return new this(x).log(2);
}
function log10(x) {
  return new this(x).log(10);
}
function max() {
  return maxOrMin(this, arguments, -1);
}
function min() {
  return maxOrMin(this, arguments, 1);
}
function mod(x, y) {
  return new this(x).mod(y);
}
function mul(x, y) {
  return new this(x).mul(y);
}
function pow(x, y) {
  return new this(x).pow(y);
}
function random(sd) {
  var d, e, k, n, i = 0, r = new this(1), rd = [];
  if (sd === void 0)
    sd = this.precision;
  else
    checkInt32(sd, 1, MAX_DIGITS);
  k = Math.ceil(sd / LOG_BASE);
  if (!this.crypto) {
    for (; i < k; )
      rd[i++] = Math.random() * 1e7 | 0;
  } else if (crypto.getRandomValues) {
    d = crypto.getRandomValues(new Uint32Array(k));
    for (; i < k; ) {
      n = d[i];
      if (n >= 429e7) {
        d[i] = crypto.getRandomValues(new Uint32Array(1))[0];
      } else {
        rd[i++] = n % 1e7;
      }
    }
  } else if (crypto.randomBytes) {
    d = crypto.randomBytes(k *= 4);
    for (; i < k; ) {
      n = d[i] + (d[i + 1] << 8) + (d[i + 2] << 16) + ((d[i + 3] & 127) << 24);
      if (n >= 214e7) {
        crypto.randomBytes(4).copy(d, i);
      } else {
        rd.push(n % 1e7);
        i += 4;
      }
    }
    i = k / 4;
  } else {
    throw Error(cryptoUnavailable);
  }
  k = rd[--i];
  sd %= LOG_BASE;
  if (k && sd) {
    n = mathpow(10, LOG_BASE - sd);
    rd[i] = (k / n | 0) * n;
  }
  for (; rd[i] === 0; i--)
    rd.pop();
  if (i < 0) {
    e = 0;
    rd = [0];
  } else {
    e = -1;
    for (; rd[0] === 0; e -= LOG_BASE)
      rd.shift();
    for (k = 1, n = rd[0]; n >= 10; n /= 10)
      k++;
    if (k < LOG_BASE)
      e -= LOG_BASE - k;
  }
  r.e = e;
  r.d = rd;
  return r;
}
function round(x) {
  return finalise(x = new this(x), x.e + 1, this.rounding);
}
function sign(x) {
  x = new this(x);
  return x.d ? x.d[0] ? x.s : 0 * x.s : x.s || NaN;
}
function sin(x) {
  return new this(x).sin();
}
function sinh(x) {
  return new this(x).sinh();
}
function sqrt(x) {
  return new this(x).sqrt();
}
function sub(x, y) {
  return new this(x).sub(y);
}
function sum() {
  var i = 0, args = arguments, x = new this(args[i]);
  external = false;
  for (; x.s && ++i < args.length; )
    x = x.plus(args[i]);
  external = true;
  return finalise(x, this.precision, this.rounding);
}
function tan(x) {
  return new this(x).tan();
}
function tanh(x) {
  return new this(x).tanh();
}
function trunc(x) {
  return finalise(x = new this(x), x.e + 1, 1);
}
P[Symbol.for("nodejs.util.inspect.custom")] = P.toString;
P[Symbol.toStringTag] = "Decimal";
var Decimal = P.constructor = clone2(DEFAULTS);
LN10 = new Decimal(LN10);
PI = new Decimal(PI);
var decimal_default = Decimal;

// node_modules/mathjs/lib/esm/type/bignumber/BigNumber.js
var name = "BigNumber";
var dependencies2 = ["?on", "config"];
var createBigNumberClass = /* @__PURE__ */ factory(name, dependencies2, (_ref) => {
  var {
    on,
    config: config4
  } = _ref;
  var BigNumber2 = decimal_default.clone({
    precision: config4.precision,
    modulo: decimal_default.EUCLID
  });
  BigNumber2.prototype = Object.create(BigNumber2.prototype);
  BigNumber2.prototype.type = "BigNumber";
  BigNumber2.prototype.isBigNumber = true;
  BigNumber2.prototype.toJSON = function() {
    return {
      mathjs: "BigNumber",
      value: this.toString()
    };
  };
  BigNumber2.fromJSON = function(json) {
    return new BigNumber2(json.value);
  };
  if (on) {
    on("config", function(curr, prev) {
      if (curr.precision !== prev.precision) {
        BigNumber2.config({
          precision: curr.precision
        });
      }
    });
  }
  return BigNumber2;
}, {
  isClass: true
});

// node_modules/complex.js/dist/complex.mjs
var cosh2 = Math.cosh || function(x) {
  return Math.abs(x) < 1e-9 ? 1 - x : (Math.exp(x) + Math.exp(-x)) * 0.5;
};
var sinh2 = Math.sinh || function(x) {
  return Math.abs(x) < 1e-9 ? x : (Math.exp(x) - Math.exp(-x)) * 0.5;
};
var cosm1 = function(x) {
  const b = Math.PI / 4;
  if (-b > x || x > b) {
    return Math.cos(x) - 1;
  }
  const xx = x * x;
  return xx * (xx * (xx * (xx * (xx * (xx * (xx * (xx / 20922789888e3 - 1 / 87178291200) + 1 / 479001600) - 1 / 3628800) + 1 / 40320) - 1 / 720) + 1 / 24) - 1 / 2);
};
var hypot2 = function(x, y) {
  x = Math.abs(x);
  y = Math.abs(y);
  if (x < y)
    [x, y] = [y, x];
  if (x < 1e8)
    return Math.sqrt(x * x + y * y);
  y /= x;
  return x * Math.sqrt(1 + y * y);
};
var parser_exit = function() {
  throw SyntaxError("Invalid Param");
};
function logHypot(a, b) {
  const _a = Math.abs(a);
  const _b = Math.abs(b);
  if (a === 0) {
    return Math.log(_b);
  }
  if (b === 0) {
    return Math.log(_a);
  }
  if (_a < 3e3 && _b < 3e3) {
    return Math.log(a * a + b * b) * 0.5;
  }
  a = a * 0.5;
  b = b * 0.5;
  return 0.5 * Math.log(a * a + b * b) + Math.LN2;
}
var P2 = { "re": 0, "im": 0 };
var parse = function(a, b) {
  const z = P2;
  if (a === void 0 || a === null) {
    z["re"] = z["im"] = 0;
  } else if (b !== void 0) {
    z["re"] = a;
    z["im"] = b;
  } else
    switch (typeof a) {
      case "object":
        if ("im" in a && "re" in a) {
          z["re"] = a["re"];
          z["im"] = a["im"];
        } else if ("abs" in a && "arg" in a) {
          if (!isFinite(a["abs"]) && isFinite(a["arg"])) {
            return Complex["INFINITY"];
          }
          z["re"] = a["abs"] * Math.cos(a["arg"]);
          z["im"] = a["abs"] * Math.sin(a["arg"]);
        } else if ("r" in a && "phi" in a) {
          if (!isFinite(a["r"]) && isFinite(a["phi"])) {
            return Complex["INFINITY"];
          }
          z["re"] = a["r"] * Math.cos(a["phi"]);
          z["im"] = a["r"] * Math.sin(a["phi"]);
        } else if (a.length === 2) {
          z["re"] = a[0];
          z["im"] = a[1];
        } else {
          parser_exit();
        }
        break;
      case "string":
        z["im"] = z["re"] = 0;
        const tokens = a.replace(/_/g, "").match(/\d+\.?\d*e[+-]?\d+|\d+\.?\d*|\.\d+|./g);
        let plus = 1;
        let minus = 0;
        if (tokens === null) {
          parser_exit();
        }
        for (let i = 0; i < tokens.length; i++) {
          const c = tokens[i];
          if (c === " " || c === "	" || c === "\n") {
          } else if (c === "+") {
            plus++;
          } else if (c === "-") {
            minus++;
          } else if (c === "i" || c === "I") {
            if (plus + minus === 0) {
              parser_exit();
            }
            if (tokens[i + 1] !== " " && !isNaN(tokens[i + 1])) {
              z["im"] += parseFloat((minus % 2 ? "-" : "") + tokens[i + 1]);
              i++;
            } else {
              z["im"] += parseFloat((minus % 2 ? "-" : "") + "1");
            }
            plus = minus = 0;
          } else {
            if (plus + minus === 0 || isNaN(c)) {
              parser_exit();
            }
            if (tokens[i + 1] === "i" || tokens[i + 1] === "I") {
              z["im"] += parseFloat((minus % 2 ? "-" : "") + c);
              i++;
            } else {
              z["re"] += parseFloat((minus % 2 ? "-" : "") + c);
            }
            plus = minus = 0;
          }
        }
        if (plus + minus > 0) {
          parser_exit();
        }
        break;
      case "number":
        z["im"] = 0;
        z["re"] = a;
        break;
      default:
        parser_exit();
    }
  if (isNaN(z["re"]) || isNaN(z["im"])) {
  }
  return z;
};
function Complex(a, b) {
  if (!(this instanceof Complex)) {
    return new Complex(a, b);
  }
  const z = parse(a, b);
  this["re"] = z["re"];
  this["im"] = z["im"];
}
Complex.prototype = {
  "re": 0,
  "im": 0,
  "sign": function() {
    const abs2 = hypot2(this["re"], this["im"]);
    return new Complex(this["re"] / abs2, this["im"] / abs2);
  },
  "add": function(a, b) {
    const z = parse(a, b);
    const tInfin = this["isInfinite"]();
    const zInfin = !(isFinite(z["re"]) && isFinite(z["im"]));
    if (tInfin || zInfin) {
      if (tInfin && zInfin) {
        return Complex["NAN"];
      }
      return Complex["INFINITY"];
    }
    return new Complex(this["re"] + z["re"], this["im"] + z["im"]);
  },
  "sub": function(a, b) {
    const z = parse(a, b);
    const tInfin = this["isInfinite"]();
    const zInfin = !(isFinite(z["re"]) && isFinite(z["im"]));
    if (tInfin || zInfin) {
      if (tInfin && zInfin) {
        return Complex["NAN"];
      }
      return Complex["INFINITY"];
    }
    return new Complex(this["re"] - z["re"], this["im"] - z["im"]);
  },
  "mul": function(a, b) {
    const z = parse(a, b);
    const tInfin = this["isInfinite"]();
    const zInfin = !(isFinite(z["re"]) && isFinite(z["im"]));
    const tIsZero = this["re"] === 0 && this["im"] === 0;
    const zIsZero = z["re"] === 0 && z["im"] === 0;
    if (tInfin && zIsZero || zInfin && tIsZero) {
      return Complex["NAN"];
    }
    if (tInfin || zInfin) {
      return Complex["INFINITY"];
    }
    if (z["im"] === 0 && this["im"] === 0) {
      return new Complex(this["re"] * z["re"], 0);
    }
    return new Complex(this["re"] * z["re"] - this["im"] * z["im"], this["re"] * z["im"] + this["im"] * z["re"]);
  },
  "div": function(a, b) {
    const z = parse(a, b);
    const tInfin = this["isInfinite"]();
    const zInfin = !(isFinite(z["re"]) && isFinite(z["im"]));
    const tIsZero = this["re"] === 0 && this["im"] === 0;
    const zIsZero = z["re"] === 0 && z["im"] === 0;
    if (tIsZero && zIsZero || tInfin && zInfin) {
      return Complex["NAN"];
    }
    if (zIsZero || tInfin) {
      return Complex["INFINITY"];
    }
    if (tIsZero || zInfin) {
      return Complex["ZERO"];
    }
    if (z["im"] === 0) {
      return new Complex(this["re"] / z["re"], this["im"] / z["re"]);
    }
    if (Math.abs(z["re"]) < Math.abs(z["im"])) {
      const x = z["re"] / z["im"];
      const t = z["re"] * x + z["im"];
      return new Complex((this["re"] * x + this["im"]) / t, (this["im"] * x - this["re"]) / t);
    } else {
      const x = z["im"] / z["re"];
      const t = z["im"] * x + z["re"];
      return new Complex((this["re"] + this["im"] * x) / t, (this["im"] - this["re"] * x) / t);
    }
  },
  "pow": function(a, b) {
    const z = parse(a, b);
    const tIsZero = this["re"] === 0 && this["im"] === 0;
    const zIsZero = z["re"] === 0 && z["im"] === 0;
    if (zIsZero) {
      return Complex["ONE"];
    }
    if (z["im"] === 0) {
      if (this["im"] === 0 && this["re"] > 0) {
        return new Complex(Math.pow(this["re"], z["re"]), 0);
      } else if (this["re"] === 0) {
        switch ((z["re"] % 4 + 4) % 4) {
          case 0:
            return new Complex(Math.pow(this["im"], z["re"]), 0);
          case 1:
            return new Complex(0, Math.pow(this["im"], z["re"]));
          case 2:
            return new Complex(-Math.pow(this["im"], z["re"]), 0);
          case 3:
            return new Complex(0, -Math.pow(this["im"], z["re"]));
        }
      }
    }
    if (tIsZero && z["re"] > 0) {
      return Complex["ZERO"];
    }
    const arg = Math.atan2(this["im"], this["re"]);
    const loh = logHypot(this["re"], this["im"]);
    let re = Math.exp(z["re"] * loh - z["im"] * arg);
    let im = z["im"] * loh + z["re"] * arg;
    return new Complex(re * Math.cos(im), re * Math.sin(im));
  },
  "sqrt": function() {
    const a = this["re"];
    const b = this["im"];
    if (b === 0) {
      if (a >= 0) {
        return new Complex(Math.sqrt(a), 0);
      } else {
        return new Complex(0, Math.sqrt(-a));
      }
    }
    const r = hypot2(a, b);
    let re = Math.sqrt(0.5 * (r + Math.abs(a)));
    let im = Math.abs(b) / (2 * re);
    if (a >= 0) {
      return new Complex(re, b < 0 ? -im : im);
    } else {
      return new Complex(im, b < 0 ? -re : re);
    }
  },
  "exp": function() {
    const er = Math.exp(this["re"]);
    if (this["im"] === 0) {
      return new Complex(er, 0);
    }
    return new Complex(er * Math.cos(this["im"]), er * Math.sin(this["im"]));
  },
  "expm1": function() {
    const a = this["re"];
    const b = this["im"];
    return new Complex(Math.expm1(a) * Math.cos(b) + cosm1(b), Math.exp(a) * Math.sin(b));
  },
  "log": function() {
    const a = this["re"];
    const b = this["im"];
    if (b === 0 && a > 0) {
      return new Complex(Math.log(a), 0);
    }
    return new Complex(logHypot(a, b), Math.atan2(b, a));
  },
  "abs": function() {
    return hypot2(this["re"], this["im"]);
  },
  "arg": function() {
    return Math.atan2(this["im"], this["re"]);
  },
  "sin": function() {
    const a = this["re"];
    const b = this["im"];
    return new Complex(Math.sin(a) * cosh2(b), Math.cos(a) * sinh2(b));
  },
  "cos": function() {
    const a = this["re"];
    const b = this["im"];
    return new Complex(Math.cos(a) * cosh2(b), -Math.sin(a) * sinh2(b));
  },
  "tan": function() {
    const a = 2 * this["re"];
    const b = 2 * this["im"];
    const d = Math.cos(a) + cosh2(b);
    return new Complex(Math.sin(a) / d, sinh2(b) / d);
  },
  "cot": function() {
    const a = 2 * this["re"];
    const b = 2 * this["im"];
    const d = Math.cos(a) - cosh2(b);
    return new Complex(-Math.sin(a) / d, sinh2(b) / d);
  },
  "sec": function() {
    const a = this["re"];
    const b = this["im"];
    const d = 0.5 * cosh2(2 * b) + 0.5 * Math.cos(2 * a);
    return new Complex(Math.cos(a) * cosh2(b) / d, Math.sin(a) * sinh2(b) / d);
  },
  "csc": function() {
    const a = this["re"];
    const b = this["im"];
    const d = 0.5 * cosh2(2 * b) - 0.5 * Math.cos(2 * a);
    return new Complex(Math.sin(a) * cosh2(b) / d, -Math.cos(a) * sinh2(b) / d);
  },
  "asin": function() {
    const a = this["re"];
    const b = this["im"];
    const t1 = new Complex(b * b - a * a + 1, -2 * a * b)["sqrt"]();
    const t2 = new Complex(t1["re"] - b, t1["im"] + a)["log"]();
    return new Complex(t2["im"], -t2["re"]);
  },
  "acos": function() {
    const a = this["re"];
    const b = this["im"];
    const t1 = new Complex(b * b - a * a + 1, -2 * a * b)["sqrt"]();
    const t2 = new Complex(t1["re"] - b, t1["im"] + a)["log"]();
    return new Complex(Math.PI / 2 - t2["im"], t2["re"]);
  },
  "atan": function() {
    const a = this["re"];
    const b = this["im"];
    if (a === 0) {
      if (b === 1) {
        return new Complex(0, Infinity);
      }
      if (b === -1) {
        return new Complex(0, -Infinity);
      }
    }
    const d = a * a + (1 - b) * (1 - b);
    const t1 = new Complex((1 - b * b - a * a) / d, -2 * a / d).log();
    return new Complex(-0.5 * t1["im"], 0.5 * t1["re"]);
  },
  "acot": function() {
    const a = this["re"];
    const b = this["im"];
    if (b === 0) {
      return new Complex(Math.atan2(1, a), 0);
    }
    const d = a * a + b * b;
    return d !== 0 ? new Complex(a / d, -b / d).atan() : new Complex(a !== 0 ? a / 0 : 0, b !== 0 ? -b / 0 : 0).atan();
  },
  "asec": function() {
    const a = this["re"];
    const b = this["im"];
    if (a === 0 && b === 0) {
      return new Complex(0, Infinity);
    }
    const d = a * a + b * b;
    return d !== 0 ? new Complex(a / d, -b / d).acos() : new Complex(a !== 0 ? a / 0 : 0, b !== 0 ? -b / 0 : 0).acos();
  },
  "acsc": function() {
    const a = this["re"];
    const b = this["im"];
    if (a === 0 && b === 0) {
      return new Complex(Math.PI / 2, Infinity);
    }
    const d = a * a + b * b;
    return d !== 0 ? new Complex(a / d, -b / d).asin() : new Complex(a !== 0 ? a / 0 : 0, b !== 0 ? -b / 0 : 0).asin();
  },
  "sinh": function() {
    const a = this["re"];
    const b = this["im"];
    return new Complex(sinh2(a) * Math.cos(b), cosh2(a) * Math.sin(b));
  },
  "cosh": function() {
    const a = this["re"];
    const b = this["im"];
    return new Complex(cosh2(a) * Math.cos(b), sinh2(a) * Math.sin(b));
  },
  "tanh": function() {
    const a = 2 * this["re"];
    const b = 2 * this["im"];
    const d = cosh2(a) + Math.cos(b);
    return new Complex(sinh2(a) / d, Math.sin(b) / d);
  },
  "coth": function() {
    const a = 2 * this["re"];
    const b = 2 * this["im"];
    const d = cosh2(a) - Math.cos(b);
    return new Complex(sinh2(a) / d, -Math.sin(b) / d);
  },
  "csch": function() {
    const a = this["re"];
    const b = this["im"];
    const d = Math.cos(2 * b) - cosh2(2 * a);
    return new Complex(-2 * sinh2(a) * Math.cos(b) / d, 2 * cosh2(a) * Math.sin(b) / d);
  },
  "sech": function() {
    const a = this["re"];
    const b = this["im"];
    const d = Math.cos(2 * b) + cosh2(2 * a);
    return new Complex(2 * cosh2(a) * Math.cos(b) / d, -2 * sinh2(a) * Math.sin(b) / d);
  },
  "asinh": function() {
    let tmp = this["im"];
    this["im"] = -this["re"];
    this["re"] = tmp;
    const res = this["asin"]();
    this["re"] = -this["im"];
    this["im"] = tmp;
    tmp = res["re"];
    res["re"] = -res["im"];
    res["im"] = tmp;
    return res;
  },
  "acosh": function() {
    const res = this["acos"]();
    if (res["im"] <= 0) {
      const tmp = res["re"];
      res["re"] = -res["im"];
      res["im"] = tmp;
    } else {
      const tmp = res["im"];
      res["im"] = -res["re"];
      res["re"] = tmp;
    }
    return res;
  },
  "atanh": function() {
    const a = this["re"];
    const b = this["im"];
    const noIM = a > 1 && b === 0;
    const oneMinus = 1 - a;
    const onePlus = 1 + a;
    const d = oneMinus * oneMinus + b * b;
    const x = d !== 0 ? new Complex((onePlus * oneMinus - b * b) / d, (b * oneMinus + onePlus * b) / d) : new Complex(a !== -1 ? a / 0 : 0, b !== 0 ? b / 0 : 0);
    const temp = x["re"];
    x["re"] = logHypot(x["re"], x["im"]) / 2;
    x["im"] = Math.atan2(x["im"], temp) / 2;
    if (noIM) {
      x["im"] = -x["im"];
    }
    return x;
  },
  "acoth": function() {
    const a = this["re"];
    const b = this["im"];
    if (a === 0 && b === 0) {
      return new Complex(0, Math.PI / 2);
    }
    const d = a * a + b * b;
    return d !== 0 ? new Complex(a / d, -b / d).atanh() : new Complex(a !== 0 ? a / 0 : 0, b !== 0 ? -b / 0 : 0).atanh();
  },
  "acsch": function() {
    const a = this["re"];
    const b = this["im"];
    if (b === 0) {
      return new Complex(a !== 0 ? Math.log(a + Math.sqrt(a * a + 1)) : Infinity, 0);
    }
    const d = a * a + b * b;
    return d !== 0 ? new Complex(a / d, -b / d).asinh() : new Complex(a !== 0 ? a / 0 : 0, b !== 0 ? -b / 0 : 0).asinh();
  },
  "asech": function() {
    const a = this["re"];
    const b = this["im"];
    if (this["isZero"]()) {
      return Complex["INFINITY"];
    }
    const d = a * a + b * b;
    return d !== 0 ? new Complex(a / d, -b / d).acosh() : new Complex(a !== 0 ? a / 0 : 0, b !== 0 ? -b / 0 : 0).acosh();
  },
  "inverse": function() {
    if (this["isZero"]()) {
      return Complex["INFINITY"];
    }
    if (this["isInfinite"]()) {
      return Complex["ZERO"];
    }
    const a = this["re"];
    const b = this["im"];
    const d = a * a + b * b;
    return new Complex(a / d, -b / d);
  },
  "conjugate": function() {
    return new Complex(this["re"], -this["im"]);
  },
  "neg": function() {
    return new Complex(-this["re"], -this["im"]);
  },
  "ceil": function(places) {
    places = Math.pow(10, places || 0);
    return new Complex(Math.ceil(this["re"] * places) / places, Math.ceil(this["im"] * places) / places);
  },
  "floor": function(places) {
    places = Math.pow(10, places || 0);
    return new Complex(Math.floor(this["re"] * places) / places, Math.floor(this["im"] * places) / places);
  },
  "round": function(places) {
    places = Math.pow(10, places || 0);
    return new Complex(Math.round(this["re"] * places) / places, Math.round(this["im"] * places) / places);
  },
  "equals": function(a, b) {
    const z = parse(a, b);
    return Math.abs(z["re"] - this["re"]) <= Complex["EPSILON"] && Math.abs(z["im"] - this["im"]) <= Complex["EPSILON"];
  },
  "clone": function() {
    return new Complex(this["re"], this["im"]);
  },
  "toString": function() {
    let a = this["re"];
    let b = this["im"];
    let ret = "";
    if (this["isNaN"]()) {
      return "NaN";
    }
    if (this["isInfinite"]()) {
      return "Infinity";
    }
    if (Math.abs(a) < Complex["EPSILON"]) {
      a = 0;
    }
    if (Math.abs(b) < Complex["EPSILON"]) {
      b = 0;
    }
    if (b === 0) {
      return ret + a;
    }
    if (a !== 0) {
      ret += a;
      ret += " ";
      if (b < 0) {
        b = -b;
        ret += "-";
      } else {
        ret += "+";
      }
      ret += " ";
    } else if (b < 0) {
      b = -b;
      ret += "-";
    }
    if (b !== 1) {
      ret += b;
    }
    return ret + "i";
  },
  "toVector": function() {
    return [this["re"], this["im"]];
  },
  "valueOf": function() {
    if (this["im"] === 0) {
      return this["re"];
    }
    return null;
  },
  "isNaN": function() {
    return isNaN(this["re"]) || isNaN(this["im"]);
  },
  "isZero": function() {
    return this["im"] === 0 && this["re"] === 0;
  },
  "isFinite": function() {
    return isFinite(this["re"]) && isFinite(this["im"]);
  },
  "isInfinite": function() {
    return !this["isFinite"]();
  }
};
Complex["ZERO"] = new Complex(0, 0);
Complex["ONE"] = new Complex(1, 0);
Complex["I"] = new Complex(0, 1);
Complex["PI"] = new Complex(Math.PI, 0);
Complex["E"] = new Complex(Math.E, 0);
Complex["INFINITY"] = new Complex(Infinity, Infinity);
Complex["NAN"] = new Complex(NaN, NaN);
Complex["EPSILON"] = 1e-15;

// node_modules/mathjs/lib/esm/type/complex/Complex.js
var name2 = "Complex";
var dependencies3 = [];
var createComplexClass = /* @__PURE__ */ factory(name2, dependencies3, () => {
  Object.defineProperty(Complex, "name", {
    value: "Complex"
  });
  Complex.prototype.constructor = Complex;
  Complex.prototype.type = "Complex";
  Complex.prototype.isComplex = true;
  Complex.prototype.toJSON = function() {
    return {
      mathjs: "Complex",
      re: this.re,
      im: this.im
    };
  };
  Complex.prototype.toPolar = function() {
    return {
      r: this.abs(),
      phi: this.arg()
    };
  };
  Complex.prototype.format = function(options) {
    var str = "";
    var im = this.im;
    var re = this.re;
    var strRe = format(this.re, options);
    var strIm = format(this.im, options);
    var precision = isNumber(options) ? options : options ? options.precision : null;
    if (precision !== null) {
      var epsilon = Math.pow(10, -precision);
      if (Math.abs(re / im) < epsilon) {
        re = 0;
      }
      if (Math.abs(im / re) < epsilon) {
        im = 0;
      }
    }
    if (im === 0) {
      str = strRe;
    } else if (re === 0) {
      if (im === 1) {
        str = "i";
      } else if (im === -1) {
        str = "-i";
      } else {
        str = strIm + "i";
      }
    } else {
      if (im < 0) {
        if (im === -1) {
          str = strRe + " - i";
        } else {
          str = strRe + " - " + strIm.substring(1) + "i";
        }
      } else {
        if (im === 1) {
          str = strRe + " + i";
        } else {
          str = strRe + " + " + strIm + "i";
        }
      }
    }
    return str;
  };
  Complex.fromPolar = function(args) {
    switch (arguments.length) {
      case 1: {
        var arg = arguments[0];
        if (typeof arg === "object") {
          return Complex(arg);
        } else {
          throw new TypeError("Input has to be an object with r and phi keys.");
        }
      }
      case 2: {
        var r = arguments[0];
        var phi = arguments[1];
        if (isNumber(r)) {
          if (isUnit(phi) && phi.hasBase("ANGLE")) {
            phi = phi.toNumber("rad");
          }
          if (isNumber(phi)) {
            return new Complex({
              r,
              phi
            });
          }
          throw new TypeError("Phi is not a number nor an angle unit.");
        } else {
          throw new TypeError("Radius r is not a number.");
        }
      }
      default:
        throw new SyntaxError("Wrong number of arguments in function fromPolar");
    }
  };
  Complex.prototype.valueOf = Complex.prototype.toString;
  Complex.fromJSON = function(json) {
    return new Complex(json);
  };
  Complex.compare = function(a, b) {
    if (a.re > b.re) {
      return 1;
    }
    if (a.re < b.re) {
      return -1;
    }
    if (a.im > b.im) {
      return 1;
    }
    if (a.im < b.im) {
      return -1;
    }
    return 0;
  };
  return Complex;
}, {
  isClass: true
});

// node_modules/fraction.js/fraction.js
var MAX_CYCLE_LEN = 2e3;
var P3 = {
  "s": 1,
  "n": 0,
  "d": 1
};
function assign(n, s) {
  if (isNaN(n = parseInt(n, 10))) {
    throw InvalidParameter();
  }
  return n * s;
}
function newFraction(n, d) {
  if (d === 0) {
    throw DivisionByZero();
  }
  var f = Object.create(Fraction.prototype);
  f["s"] = n < 0 ? -1 : 1;
  n = n < 0 ? -n : n;
  var a = gcd(n, d);
  f["n"] = n / a;
  f["d"] = d / a;
  return f;
}
function factorize(num) {
  var factors = {};
  var n = num;
  var i = 2;
  var s = 4;
  while (s <= n) {
    while (n % i === 0) {
      n /= i;
      factors[i] = (factors[i] || 0) + 1;
    }
    s += 1 + 2 * i++;
  }
  if (n !== num) {
    if (n > 1)
      factors[n] = (factors[n] || 0) + 1;
  } else {
    factors[num] = (factors[num] || 0) + 1;
  }
  return factors;
}
var parse2 = function(p1, p2) {
  var n = 0, d = 1, s = 1;
  var v = 0, w = 0, x = 0, y = 1, z = 1;
  var A = 0, B = 1;
  var C = 1, D = 1;
  var N = 1e7;
  var M;
  if (p1 === void 0 || p1 === null) {
  } else if (p2 !== void 0) {
    n = p1;
    d = p2;
    s = n * d;
    if (n % 1 !== 0 || d % 1 !== 0) {
      throw NonIntegerParameter();
    }
  } else
    switch (typeof p1) {
      case "object": {
        if ("d" in p1 && "n" in p1) {
          n = p1["n"];
          d = p1["d"];
          if ("s" in p1)
            n *= p1["s"];
        } else if (0 in p1) {
          n = p1[0];
          if (1 in p1)
            d = p1[1];
        } else {
          throw InvalidParameter();
        }
        s = n * d;
        break;
      }
      case "number": {
        if (p1 < 0) {
          s = p1;
          p1 = -p1;
        }
        if (p1 % 1 === 0) {
          n = p1;
        } else if (p1 > 0) {
          if (p1 >= 1) {
            z = Math.pow(10, Math.floor(1 + Math.log(p1) / Math.LN10));
            p1 /= z;
          }
          while (B <= N && D <= N) {
            M = (A + C) / (B + D);
            if (p1 === M) {
              if (B + D <= N) {
                n = A + C;
                d = B + D;
              } else if (D > B) {
                n = C;
                d = D;
              } else {
                n = A;
                d = B;
              }
              break;
            } else {
              if (p1 > M) {
                A += C;
                B += D;
              } else {
                C += A;
                D += B;
              }
              if (B > N) {
                n = C;
                d = D;
              } else {
                n = A;
                d = B;
              }
            }
          }
          n *= z;
        } else if (isNaN(p1) || isNaN(p2)) {
          d = n = NaN;
        }
        break;
      }
      case "string": {
        B = p1.match(/\d+|./g);
        if (B === null)
          throw InvalidParameter();
        if (B[A] === "-") {
          s = -1;
          A++;
        } else if (B[A] === "+") {
          A++;
        }
        if (B.length === A + 1) {
          w = assign(B[A++], s);
        } else if (B[A + 1] === "." || B[A] === ".") {
          if (B[A] !== ".") {
            v = assign(B[A++], s);
          }
          A++;
          if (A + 1 === B.length || B[A + 1] === "(" && B[A + 3] === ")" || B[A + 1] === "'" && B[A + 3] === "'") {
            w = assign(B[A], s);
            y = Math.pow(10, B[A].length);
            A++;
          }
          if (B[A] === "(" && B[A + 2] === ")" || B[A] === "'" && B[A + 2] === "'") {
            x = assign(B[A + 1], s);
            z = Math.pow(10, B[A + 1].length) - 1;
            A += 3;
          }
        } else if (B[A + 1] === "/" || B[A + 1] === ":") {
          w = assign(B[A], s);
          y = assign(B[A + 2], 1);
          A += 3;
        } else if (B[A + 3] === "/" && B[A + 1] === " ") {
          v = assign(B[A], s);
          w = assign(B[A + 2], s);
          y = assign(B[A + 4], 1);
          A += 5;
        }
        if (B.length <= A) {
          d = y * z;
          s = n = x + d * v + z * w;
          break;
        }
      }
      default:
        throw InvalidParameter();
    }
  if (d === 0) {
    throw DivisionByZero();
  }
  P3["s"] = s < 0 ? -1 : 1;
  P3["n"] = Math.abs(n);
  P3["d"] = Math.abs(d);
};
function modpow(b, e, m) {
  var r = 1;
  for (; e > 0; b = b * b % m, e >>= 1) {
    if (e & 1) {
      r = r * b % m;
    }
  }
  return r;
}
function cycleLen(n, d) {
  for (; d % 2 === 0; d /= 2) {
  }
  for (; d % 5 === 0; d /= 5) {
  }
  if (d === 1)
    return 0;
  var rem = 10 % d;
  var t = 1;
  for (; rem !== 1; t++) {
    rem = rem * 10 % d;
    if (t > MAX_CYCLE_LEN)
      return 0;
  }
  return t;
}
function cycleStart(n, d, len) {
  var rem1 = 1;
  var rem2 = modpow(10, len, d);
  for (var t = 0; t < 300; t++) {
    if (rem1 === rem2)
      return t;
    rem1 = rem1 * 10 % d;
    rem2 = rem2 * 10 % d;
  }
  return 0;
}
function gcd(a, b) {
  if (!a)
    return b;
  if (!b)
    return a;
  while (1) {
    a %= b;
    if (!a)
      return b;
    b %= a;
    if (!b)
      return a;
  }
}
function Fraction(a, b) {
  parse2(a, b);
  if (this instanceof Fraction) {
    a = gcd(P3["d"], P3["n"]);
    this["s"] = P3["s"];
    this["n"] = P3["n"] / a;
    this["d"] = P3["d"] / a;
  } else {
    return newFraction(P3["s"] * P3["n"], P3["d"]);
  }
}
var DivisionByZero = function() {
  return new Error("Division by Zero");
};
var InvalidParameter = function() {
  return new Error("Invalid argument");
};
var NonIntegerParameter = function() {
  return new Error("Parameters must be integer");
};
Fraction.prototype = {
  "s": 1,
  "n": 0,
  "d": 1,
  "abs": function() {
    return newFraction(this["n"], this["d"]);
  },
  "neg": function() {
    return newFraction(-this["s"] * this["n"], this["d"]);
  },
  "add": function(a, b) {
    parse2(a, b);
    return newFraction(this["s"] * this["n"] * P3["d"] + P3["s"] * this["d"] * P3["n"], this["d"] * P3["d"]);
  },
  "sub": function(a, b) {
    parse2(a, b);
    return newFraction(this["s"] * this["n"] * P3["d"] - P3["s"] * this["d"] * P3["n"], this["d"] * P3["d"]);
  },
  "mul": function(a, b) {
    parse2(a, b);
    return newFraction(this["s"] * P3["s"] * this["n"] * P3["n"], this["d"] * P3["d"]);
  },
  "div": function(a, b) {
    parse2(a, b);
    return newFraction(this["s"] * P3["s"] * this["n"] * P3["d"], this["d"] * P3["n"]);
  },
  "clone": function() {
    return newFraction(this["s"] * this["n"], this["d"]);
  },
  "mod": function(a, b) {
    if (isNaN(this["n"]) || isNaN(this["d"])) {
      return new Fraction(NaN);
    }
    if (a === void 0) {
      return newFraction(this["s"] * this["n"] % this["d"], 1);
    }
    parse2(a, b);
    if (P3["n"] === 0 && this["d"] === 0) {
      throw DivisionByZero();
    }
    return newFraction(this["s"] * (P3["d"] * this["n"]) % (P3["n"] * this["d"]), P3["d"] * this["d"]);
  },
  "gcd": function(a, b) {
    parse2(a, b);
    return newFraction(gcd(P3["n"], this["n"]) * gcd(P3["d"], this["d"]), P3["d"] * this["d"]);
  },
  "lcm": function(a, b) {
    parse2(a, b);
    if (P3["n"] === 0 && this["n"] === 0) {
      return newFraction(0, 1);
    }
    return newFraction(P3["n"] * this["n"], gcd(P3["n"], this["n"]) * gcd(P3["d"], this["d"]));
  },
  "ceil": function(places) {
    places = Math.pow(10, places || 0);
    if (isNaN(this["n"]) || isNaN(this["d"])) {
      return new Fraction(NaN);
    }
    return newFraction(Math.ceil(places * this["s"] * this["n"] / this["d"]), places);
  },
  "floor": function(places) {
    places = Math.pow(10, places || 0);
    if (isNaN(this["n"]) || isNaN(this["d"])) {
      return new Fraction(NaN);
    }
    return newFraction(Math.floor(places * this["s"] * this["n"] / this["d"]), places);
  },
  "round": function(places) {
    places = Math.pow(10, places || 0);
    if (isNaN(this["n"]) || isNaN(this["d"])) {
      return new Fraction(NaN);
    }
    return newFraction(Math.round(places * this["s"] * this["n"] / this["d"]), places);
  },
  "roundTo": function(a, b) {
    parse2(a, b);
    return newFraction(this["s"] * Math.round(this["n"] * P3["d"] / (this["d"] * P3["n"])) * P3["n"], P3["d"]);
  },
  "inverse": function() {
    return newFraction(this["s"] * this["d"], this["n"]);
  },
  "pow": function(a, b) {
    parse2(a, b);
    if (P3["d"] === 1) {
      if (P3["s"] < 0) {
        return newFraction(Math.pow(this["s"] * this["d"], P3["n"]), Math.pow(this["n"], P3["n"]));
      } else {
        return newFraction(Math.pow(this["s"] * this["n"], P3["n"]), Math.pow(this["d"], P3["n"]));
      }
    }
    if (this["s"] < 0)
      return null;
    var N = factorize(this["n"]);
    var D = factorize(this["d"]);
    var n = 1;
    var d = 1;
    for (var k in N) {
      if (k === "1")
        continue;
      if (k === "0") {
        n = 0;
        break;
      }
      N[k] *= P3["n"];
      if (N[k] % P3["d"] === 0) {
        N[k] /= P3["d"];
      } else
        return null;
      n *= Math.pow(k, N[k]);
    }
    for (var k in D) {
      if (k === "1")
        continue;
      D[k] *= P3["n"];
      if (D[k] % P3["d"] === 0) {
        D[k] /= P3["d"];
      } else
        return null;
      d *= Math.pow(k, D[k]);
    }
    if (P3["s"] < 0) {
      return newFraction(d, n);
    }
    return newFraction(n, d);
  },
  "equals": function(a, b) {
    parse2(a, b);
    return this["s"] * this["n"] * P3["d"] === P3["s"] * P3["n"] * this["d"];
  },
  "compare": function(a, b) {
    parse2(a, b);
    var t = this["s"] * this["n"] * P3["d"] - P3["s"] * P3["n"] * this["d"];
    return (0 < t) - (t < 0);
  },
  "simplify": function(eps) {
    if (isNaN(this["n"]) || isNaN(this["d"])) {
      return this;
    }
    eps = eps || 1e-3;
    var thisABS = this["abs"]();
    var cont = thisABS["toContinued"]();
    for (var i = 1; i < cont.length; i++) {
      var s = newFraction(cont[i - 1], 1);
      for (var k = i - 2; k >= 0; k--) {
        s = s["inverse"]()["add"](cont[k]);
      }
      if (Math.abs(s["sub"](thisABS).valueOf()) < eps) {
        return s["mul"](this["s"]);
      }
    }
    return this;
  },
  "divisible": function(a, b) {
    parse2(a, b);
    return !(!(P3["n"] * this["d"]) || this["n"] * P3["d"] % (P3["n"] * this["d"]));
  },
  "valueOf": function() {
    return this["s"] * this["n"] / this["d"];
  },
  "toFraction": function(excludeWhole) {
    var whole, str = "";
    var n = this["n"];
    var d = this["d"];
    if (this["s"] < 0) {
      str += "-";
    }
    if (d === 1) {
      str += n;
    } else {
      if (excludeWhole && (whole = Math.floor(n / d)) > 0) {
        str += whole;
        str += " ";
        n %= d;
      }
      str += n;
      str += "/";
      str += d;
    }
    return str;
  },
  "toLatex": function(excludeWhole) {
    var whole, str = "";
    var n = this["n"];
    var d = this["d"];
    if (this["s"] < 0) {
      str += "-";
    }
    if (d === 1) {
      str += n;
    } else {
      if (excludeWhole && (whole = Math.floor(n / d)) > 0) {
        str += whole;
        n %= d;
      }
      str += "\\frac{";
      str += n;
      str += "}{";
      str += d;
      str += "}";
    }
    return str;
  },
  "toContinued": function() {
    var t;
    var a = this["n"];
    var b = this["d"];
    var res = [];
    if (isNaN(a) || isNaN(b)) {
      return res;
    }
    do {
      res.push(Math.floor(a / b));
      t = a % b;
      a = b;
      b = t;
    } while (a !== 1);
    return res;
  },
  "toString": function(dec) {
    var N = this["n"];
    var D = this["d"];
    if (isNaN(N) || isNaN(D)) {
      return "NaN";
    }
    dec = dec || 15;
    var cycLen = cycleLen(N, D);
    var cycOff = cycleStart(N, D, cycLen);
    var str = this["s"] < 0 ? "-" : "";
    str += N / D | 0;
    N %= D;
    N *= 10;
    if (N)
      str += ".";
    if (cycLen) {
      for (var i = cycOff; i--; ) {
        str += N / D | 0;
        N %= D;
        N *= 10;
      }
      str += "(";
      for (var i = cycLen; i--; ) {
        str += N / D | 0;
        N %= D;
        N *= 10;
      }
      str += ")";
    } else {
      for (var i = dec; N && i--; ) {
        str += N / D | 0;
        N %= D;
        N *= 10;
      }
    }
    return str;
  }
};

// node_modules/mathjs/lib/esm/type/fraction/Fraction.js
var name3 = "Fraction";
var dependencies4 = [];
var createFractionClass = /* @__PURE__ */ factory(name3, dependencies4, () => {
  Object.defineProperty(Fraction, "name", {
    value: "Fraction"
  });
  Fraction.prototype.constructor = Fraction;
  Fraction.prototype.type = "Fraction";
  Fraction.prototype.isFraction = true;
  Fraction.prototype.toJSON = function() {
    return {
      mathjs: "Fraction",
      n: this.s * this.n,
      d: this.d
    };
  };
  Fraction.fromJSON = function(json) {
    return new Fraction(json);
  };
  return Fraction;
}, {
  isClass: true
});

// node_modules/mathjs/lib/esm/type/matrix/Matrix.js
var name4 = "Matrix";
var dependencies5 = [];
var createMatrixClass = /* @__PURE__ */ factory(name4, dependencies5, () => {
  function Matrix2() {
    if (!(this instanceof Matrix2)) {
      throw new SyntaxError("Constructor must be called with the new operator");
    }
  }
  Matrix2.prototype.type = "Matrix";
  Matrix2.prototype.isMatrix = true;
  Matrix2.prototype.storage = function() {
    throw new Error("Cannot invoke storage on a Matrix interface");
  };
  Matrix2.prototype.datatype = function() {
    throw new Error("Cannot invoke datatype on a Matrix interface");
  };
  Matrix2.prototype.create = function(data, datatype) {
    throw new Error("Cannot invoke create on a Matrix interface");
  };
  Matrix2.prototype.subset = function(index, replacement, defaultValue) {
    throw new Error("Cannot invoke subset on a Matrix interface");
  };
  Matrix2.prototype.get = function(index) {
    throw new Error("Cannot invoke get on a Matrix interface");
  };
  Matrix2.prototype.set = function(index, value, defaultValue) {
    throw new Error("Cannot invoke set on a Matrix interface");
  };
  Matrix2.prototype.resize = function(size, defaultValue) {
    throw new Error("Cannot invoke resize on a Matrix interface");
  };
  Matrix2.prototype.reshape = function(size, defaultValue) {
    throw new Error("Cannot invoke reshape on a Matrix interface");
  };
  Matrix2.prototype.clone = function() {
    throw new Error("Cannot invoke clone on a Matrix interface");
  };
  Matrix2.prototype.size = function() {
    throw new Error("Cannot invoke size on a Matrix interface");
  };
  Matrix2.prototype.map = function(callback, skipZeros) {
    throw new Error("Cannot invoke map on a Matrix interface");
  };
  Matrix2.prototype.forEach = function(callback) {
    throw new Error("Cannot invoke forEach on a Matrix interface");
  };
  Matrix2.prototype[Symbol.iterator] = function() {
    throw new Error("Cannot iterate a Matrix interface");
  };
  Matrix2.prototype.toArray = function() {
    throw new Error("Cannot invoke toArray on a Matrix interface");
  };
  Matrix2.prototype.valueOf = function() {
    throw new Error("Cannot invoke valueOf on a Matrix interface");
  };
  Matrix2.prototype.format = function(options) {
    throw new Error("Cannot invoke format on a Matrix interface");
  };
  Matrix2.prototype.toString = function() {
    throw new Error("Cannot invoke toString on a Matrix interface");
  };
  return Matrix2;
}, {
  isClass: true
});

// node_modules/mathjs/lib/esm/utils/function.js
function maxArgumentCount(fn) {
  return Object.keys(fn.signatures || {}).reduce(function(args, signature) {
    var count = (signature.match(/,/g) || []).length + 1;
    return Math.max(args, count);
  }, -1);
}

// node_modules/mathjs/lib/esm/type/matrix/DenseMatrix.js
var name5 = "DenseMatrix";
var dependencies6 = ["Matrix"];
var createDenseMatrixClass = /* @__PURE__ */ factory(name5, dependencies6, (_ref) => {
  var {
    Matrix: Matrix2
  } = _ref;
  function DenseMatrix2(data, datatype) {
    if (!(this instanceof DenseMatrix2)) {
      throw new SyntaxError("Constructor must be called with the new operator");
    }
    if (datatype && !isString(datatype)) {
      throw new Error("Invalid datatype: " + datatype);
    }
    if (isMatrix(data)) {
      if (data.type === "DenseMatrix") {
        this._data = clone(data._data);
        this._size = clone(data._size);
        this._datatype = datatype || data._datatype;
      } else {
        this._data = data.toArray();
        this._size = data.size();
        this._datatype = datatype || data._datatype;
      }
    } else if (data && isArray(data.data) && isArray(data.size)) {
      this._data = data.data;
      this._size = data.size;
      validate(this._data, this._size);
      this._datatype = datatype || data.datatype;
    } else if (isArray(data)) {
      this._data = preprocess(data);
      this._size = arraySize(this._data);
      validate(this._data, this._size);
      this._datatype = datatype;
    } else if (data) {
      throw new TypeError("Unsupported type of data (" + typeOf(data) + ")");
    } else {
      this._data = [];
      this._size = [0];
      this._datatype = datatype;
    }
  }
  DenseMatrix2.prototype = new Matrix2();
  DenseMatrix2.prototype.createDenseMatrix = function(data, datatype) {
    return new DenseMatrix2(data, datatype);
  };
  Object.defineProperty(DenseMatrix2, "name", {
    value: "DenseMatrix"
  });
  DenseMatrix2.prototype.constructor = DenseMatrix2;
  DenseMatrix2.prototype.type = "DenseMatrix";
  DenseMatrix2.prototype.isDenseMatrix = true;
  DenseMatrix2.prototype.getDataType = function() {
    return getArrayDataType(this._data, typeOf);
  };
  DenseMatrix2.prototype.storage = function() {
    return "dense";
  };
  DenseMatrix2.prototype.datatype = function() {
    return this._datatype;
  };
  DenseMatrix2.prototype.create = function(data, datatype) {
    return new DenseMatrix2(data, datatype);
  };
  DenseMatrix2.prototype.subset = function(index, replacement, defaultValue) {
    switch (arguments.length) {
      case 1:
        return _get(this, index);
      case 2:
      case 3:
        return _set(this, index, replacement, defaultValue);
      default:
        throw new SyntaxError("Wrong number of arguments");
    }
  };
  DenseMatrix2.prototype.get = function(index) {
    if (!isArray(index)) {
      throw new TypeError("Array expected");
    }
    if (index.length !== this._size.length) {
      throw new DimensionError(index.length, this._size.length);
    }
    for (var x = 0; x < index.length; x++) {
      validateIndex(index[x], this._size[x]);
    }
    var data = this._data;
    for (var i = 0, ii = index.length; i < ii; i++) {
      var indexI = index[i];
      validateIndex(indexI, data.length);
      data = data[indexI];
    }
    return data;
  };
  DenseMatrix2.prototype.set = function(index, value, defaultValue) {
    if (!isArray(index)) {
      throw new TypeError("Array expected");
    }
    if (index.length < this._size.length) {
      throw new DimensionError(index.length, this._size.length, "<");
    }
    var i, ii, indexI;
    var size = index.map(function(i2) {
      return i2 + 1;
    });
    _fit(this, size, defaultValue);
    var data = this._data;
    for (i = 0, ii = index.length - 1; i < ii; i++) {
      indexI = index[i];
      validateIndex(indexI, data.length);
      data = data[indexI];
    }
    indexI = index[index.length - 1];
    validateIndex(indexI, data.length);
    data[indexI] = value;
    return this;
  };
  function _get(matrix2, index) {
    if (!isIndex(index)) {
      throw new TypeError("Invalid index");
    }
    var isScalar = index.isScalar();
    if (isScalar) {
      return matrix2.get(index.min());
    } else {
      var size = index.size();
      if (size.length !== matrix2._size.length) {
        throw new DimensionError(size.length, matrix2._size.length);
      }
      var min2 = index.min();
      var max2 = index.max();
      for (var i = 0, ii = matrix2._size.length; i < ii; i++) {
        validateIndex(min2[i], matrix2._size[i]);
        validateIndex(max2[i], matrix2._size[i]);
      }
      return new DenseMatrix2(_getSubmatrix(matrix2._data, index, size.length, 0), matrix2._datatype);
    }
  }
  function _getSubmatrix(data, index, dims, dim) {
    var last = dim === dims - 1;
    var range = index.dimension(dim);
    if (last) {
      return range.map(function(i) {
        validateIndex(i, data.length);
        return data[i];
      }).valueOf();
    } else {
      return range.map(function(i) {
        validateIndex(i, data.length);
        var child = data[i];
        return _getSubmatrix(child, index, dims, dim + 1);
      }).valueOf();
    }
  }
  function _set(matrix2, index, submatrix, defaultValue) {
    if (!index || index.isIndex !== true) {
      throw new TypeError("Invalid index");
    }
    var iSize = index.size();
    var isScalar = index.isScalar();
    var sSize;
    if (isMatrix(submatrix)) {
      sSize = submatrix.size();
      submatrix = submatrix.valueOf();
    } else {
      sSize = arraySize(submatrix);
    }
    if (isScalar) {
      if (sSize.length !== 0) {
        throw new TypeError("Scalar expected");
      }
      matrix2.set(index.min(), submatrix, defaultValue);
    } else {
      if (iSize.length < matrix2._size.length) {
        throw new DimensionError(iSize.length, matrix2._size.length, "<");
      }
      if (sSize.length < iSize.length) {
        var i = 0;
        var outer = 0;
        while (iSize[i] === 1 && sSize[i] === 1) {
          i++;
        }
        while (iSize[i] === 1) {
          outer++;
          i++;
        }
        submatrix = unsqueeze(submatrix, iSize.length, outer, sSize);
      }
      if (!deepStrictEqual(iSize, sSize)) {
        throw new DimensionError(iSize, sSize, ">");
      }
      var size = index.max().map(function(i2) {
        return i2 + 1;
      });
      _fit(matrix2, size, defaultValue);
      var dims = iSize.length;
      var dim = 0;
      _setSubmatrix(matrix2._data, index, submatrix, dims, dim);
    }
    return matrix2;
  }
  function _setSubmatrix(data, index, submatrix, dims, dim) {
    var last = dim === dims - 1;
    var range = index.dimension(dim);
    if (last) {
      range.forEach(function(dataIndex, subIndex) {
        validateIndex(dataIndex);
        data[dataIndex] = submatrix[subIndex[0]];
      });
    } else {
      range.forEach(function(dataIndex, subIndex) {
        validateIndex(dataIndex);
        _setSubmatrix(data[dataIndex], index, submatrix[subIndex[0]], dims, dim + 1);
      });
    }
  }
  DenseMatrix2.prototype.resize = function(size, defaultValue, copy) {
    if (!isCollection(size)) {
      throw new TypeError("Array or Matrix expected");
    }
    var sizeArray = size.valueOf().map((value) => {
      return Array.isArray(value) && value.length === 1 ? value[0] : value;
    });
    var m = copy ? this.clone() : this;
    return _resize2(m, sizeArray, defaultValue);
  };
  function _resize2(matrix2, size, defaultValue) {
    if (size.length === 0) {
      var v = matrix2._data;
      while (isArray(v)) {
        v = v[0];
      }
      return v;
    }
    matrix2._size = size.slice(0);
    matrix2._data = resize(matrix2._data, matrix2._size, defaultValue);
    return matrix2;
  }
  DenseMatrix2.prototype.reshape = function(size, copy) {
    var m = copy ? this.clone() : this;
    m._data = reshape(m._data, size);
    var currentLength = m._size.reduce((length, size2) => length * size2);
    m._size = processSizesWildcard(size, currentLength);
    return m;
  };
  function _fit(matrix2, size, defaultValue) {
    var newSize = matrix2._size.slice(0);
    var changed = false;
    while (newSize.length < size.length) {
      newSize.push(0);
      changed = true;
    }
    for (var i = 0, ii = size.length; i < ii; i++) {
      if (size[i] > newSize[i]) {
        newSize[i] = size[i];
        changed = true;
      }
    }
    if (changed) {
      _resize2(matrix2, newSize, defaultValue);
    }
  }
  DenseMatrix2.prototype.clone = function() {
    var m = new DenseMatrix2({
      data: clone(this._data),
      size: clone(this._size),
      datatype: this._datatype
    });
    return m;
  };
  DenseMatrix2.prototype.size = function() {
    return this._size.slice(0);
  };
  DenseMatrix2.prototype.map = function(callback) {
    var me = this;
    var args = maxArgumentCount(callback);
    var recurse = function recurse2(value, index) {
      if (isArray(value)) {
        return value.map(function(child, i) {
          return recurse2(child, index.concat(i));
        });
      } else {
        if (args === 1) {
          return callback(value);
        } else if (args === 2) {
          return callback(value, index);
        } else {
          return callback(value, index, me);
        }
      }
    };
    var data = recurse(this._data, []);
    var datatype = this._datatype !== void 0 ? getArrayDataType(data, typeOf) : void 0;
    return new DenseMatrix2(data, datatype);
  };
  DenseMatrix2.prototype.forEach = function(callback) {
    var me = this;
    var recurse = function recurse2(value, index) {
      if (isArray(value)) {
        value.forEach(function(child, i) {
          recurse2(child, index.concat(i));
        });
      } else {
        callback(value, index, me);
      }
    };
    recurse(this._data, []);
  };
  DenseMatrix2.prototype[Symbol.iterator] = function* () {
    var recurse = function* recurse2(value, index) {
      if (isArray(value)) {
        for (var i = 0; i < value.length; i++) {
          yield* recurse2(value[i], index.concat(i));
        }
      } else {
        yield {
          value,
          index
        };
      }
    };
    yield* recurse(this._data, []);
  };
  DenseMatrix2.prototype.rows = function() {
    var result = [];
    var s = this.size();
    if (s.length !== 2) {
      throw new TypeError("Rows can only be returned for a 2D matrix.");
    }
    var data = this._data;
    for (var row of data) {
      result.push(new DenseMatrix2([row], this._datatype));
    }
    return result;
  };
  DenseMatrix2.prototype.columns = function() {
    var _this = this;
    var result = [];
    var s = this.size();
    if (s.length !== 2) {
      throw new TypeError("Rows can only be returned for a 2D matrix.");
    }
    var data = this._data;
    var _loop = function _loop2(i2) {
      var col = data.map((row) => [row[i2]]);
      result.push(new DenseMatrix2(col, _this._datatype));
    };
    for (var i = 0; i < s[1]; i++) {
      _loop(i);
    }
    return result;
  };
  DenseMatrix2.prototype.toArray = function() {
    return clone(this._data);
  };
  DenseMatrix2.prototype.valueOf = function() {
    return this._data;
  };
  DenseMatrix2.prototype.format = function(options) {
    return format3(this._data, options);
  };
  DenseMatrix2.prototype.toString = function() {
    return format3(this._data);
  };
  DenseMatrix2.prototype.toJSON = function() {
    return {
      mathjs: "DenseMatrix",
      data: this._data,
      size: this._size,
      datatype: this._datatype
    };
  };
  DenseMatrix2.prototype.diagonal = function(k) {
    if (k) {
      if (isBigNumber(k)) {
        k = k.toNumber();
      }
      if (!isNumber(k) || !isInteger(k)) {
        throw new TypeError("The parameter k must be an integer number");
      }
    } else {
      k = 0;
    }
    var kSuper = k > 0 ? k : 0;
    var kSub = k < 0 ? -k : 0;
    var rows = this._size[0];
    var columns = this._size[1];
    var n = Math.min(rows - kSub, columns - kSuper);
    var data = [];
    for (var i = 0; i < n; i++) {
      data[i] = this._data[i + kSub][i + kSuper];
    }
    return new DenseMatrix2({
      data,
      size: [n],
      datatype: this._datatype
    });
  };
  DenseMatrix2.diagonal = function(size, value, k, defaultValue) {
    if (!isArray(size)) {
      throw new TypeError("Array expected, size parameter");
    }
    if (size.length !== 2) {
      throw new Error("Only two dimensions matrix are supported");
    }
    size = size.map(function(s) {
      if (isBigNumber(s)) {
        s = s.toNumber();
      }
      if (!isNumber(s) || !isInteger(s) || s < 1) {
        throw new Error("Size values must be positive integers");
      }
      return s;
    });
    if (k) {
      if (isBigNumber(k)) {
        k = k.toNumber();
      }
      if (!isNumber(k) || !isInteger(k)) {
        throw new TypeError("The parameter k must be an integer number");
      }
    } else {
      k = 0;
    }
    var kSuper = k > 0 ? k : 0;
    var kSub = k < 0 ? -k : 0;
    var rows = size[0];
    var columns = size[1];
    var n = Math.min(rows - kSub, columns - kSuper);
    var _value;
    if (isArray(value)) {
      if (value.length !== n) {
        throw new Error("Invalid value array length");
      }
      _value = function _value2(i) {
        return value[i];
      };
    } else if (isMatrix(value)) {
      var ms = value.size();
      if (ms.length !== 1 || ms[0] !== n) {
        throw new Error("Invalid matrix length");
      }
      _value = function _value2(i) {
        return value.get([i]);
      };
    } else {
      _value = function _value2() {
        return value;
      };
    }
    if (!defaultValue) {
      defaultValue = isBigNumber(_value(0)) ? _value(0).mul(0) : 0;
    }
    var data = [];
    if (size.length > 0) {
      data = resize(data, size, defaultValue);
      for (var d = 0; d < n; d++) {
        data[d + kSub][d + kSuper] = _value(d);
      }
    }
    return new DenseMatrix2({
      data,
      size: [rows, columns]
    });
  };
  DenseMatrix2.fromJSON = function(json) {
    return new DenseMatrix2(json);
  };
  DenseMatrix2.prototype.swapRows = function(i, j) {
    if (!isNumber(i) || !isInteger(i) || !isNumber(j) || !isInteger(j)) {
      throw new Error("Row index must be positive integers");
    }
    if (this._size.length !== 2) {
      throw new Error("Only two dimensional matrix is supported");
    }
    validateIndex(i, this._size[0]);
    validateIndex(j, this._size[0]);
    DenseMatrix2._swapRows(i, j, this._data);
    return this;
  };
  DenseMatrix2._swapRows = function(i, j, data) {
    var vi = data[i];
    data[i] = data[j];
    data[j] = vi;
  };
  function preprocess(data) {
    for (var i = 0, ii = data.length; i < ii; i++) {
      var elem = data[i];
      if (isArray(elem)) {
        data[i] = preprocess(elem);
      } else if (elem && elem.isMatrix === true) {
        data[i] = preprocess(elem.valueOf());
      }
    }
    return data;
  }
  return DenseMatrix2;
}, {
  isClass: true
});

// node_modules/mathjs/lib/esm/utils/collection.js
function deepMap(array, callback, skipZeros) {
  if (array && typeof array.map === "function") {
    return array.map(function(x) {
      return deepMap(x, callback, skipZeros);
    });
  } else {
    return callback(array);
  }
}

// node_modules/mathjs/lib/esm/function/utils/isInteger.js
var name6 = "isInteger";
var dependencies7 = ["typed"];
var createIsInteger = /* @__PURE__ */ factory(name6, dependencies7, (_ref) => {
  var {
    typed: typed2
  } = _ref;
  return typed2(name6, {
    number: isInteger,
    BigNumber: function BigNumber2(x) {
      return x.isInt();
    },
    Fraction: function Fraction3(x) {
      return x.d === 1 && isFinite(x.n);
    },
    "Array | Matrix": typed2.referToSelf((self2) => (x) => deepMap(x, self2))
  });
});

// node_modules/mathjs/lib/esm/utils/bignumber/nearlyEqual.js
function nearlyEqual2(x, y, epsilon) {
  if (epsilon === null || epsilon === void 0) {
    return x.eq(y);
  }
  if (x.eq(y)) {
    return true;
  }
  if (x.isNaN() || y.isNaN()) {
    return false;
  }
  if (x.isFinite() && y.isFinite()) {
    var diff = x.minus(y).abs();
    if (diff.isZero()) {
      return true;
    } else {
      var max2 = x.constructor.max(x.abs(), y.abs());
      return diff.lte(max2.times(epsilon));
    }
  }
  return false;
}

// node_modules/mathjs/lib/esm/utils/complex.js
function complexEquals(x, y, epsilon) {
  return nearlyEqual(x.re, y.re, epsilon) && nearlyEqual(x.im, y.im, epsilon);
}

// node_modules/mathjs/lib/esm/function/relational/compareUnits.js
var createCompareUnits = /* @__PURE__ */ factory("compareUnits", ["typed"], (_ref) => {
  var {
    typed: typed2
  } = _ref;
  return {
    "Unit, Unit": typed2.referToSelf((self2) => (x, y) => {
      if (!x.equalBase(y)) {
        throw new Error("Cannot compare units with different base");
      }
      return typed2.find(self2, [x.valueType(), y.valueType()])(x.value, y.value);
    })
  };
});

// node_modules/mathjs/lib/esm/function/relational/equalScalar.js
var name7 = "equalScalar";
var dependencies8 = ["typed", "config"];
var createEqualScalar = /* @__PURE__ */ factory(name7, dependencies8, (_ref) => {
  var {
    typed: typed2,
    config: config4
  } = _ref;
  var compareUnits = createCompareUnits({
    typed: typed2
  });
  return typed2(name7, {
    "boolean, boolean": function booleanBoolean(x, y) {
      return x === y;
    },
    "number, number": function numberNumber(x, y) {
      return nearlyEqual(x, y, config4.epsilon);
    },
    "BigNumber, BigNumber": function BigNumberBigNumber(x, y) {
      return x.eq(y) || nearlyEqual2(x, y, config4.epsilon);
    },
    "Fraction, Fraction": function FractionFraction(x, y) {
      return x.equals(y);
    },
    "Complex, Complex": function ComplexComplex(x, y) {
      return complexEquals(x, y, config4.epsilon);
    }
  }, compareUnits);
});
var createEqualScalarNumber = factory(name7, ["typed", "config"], (_ref2) => {
  var {
    typed: typed2,
    config: config4
  } = _ref2;
  return typed2(name7, {
    "number, number": function numberNumber(x, y) {
      return nearlyEqual(x, y, config4.epsilon);
    }
  });
});

// node_modules/mathjs/lib/esm/type/matrix/SparseMatrix.js
var name8 = "SparseMatrix";
var dependencies9 = ["typed", "equalScalar", "Matrix"];
var createSparseMatrixClass = /* @__PURE__ */ factory(name8, dependencies9, (_ref) => {
  var {
    typed: typed2,
    equalScalar: equalScalar2,
    Matrix: Matrix2
  } = _ref;
  function SparseMatrix2(data, datatype) {
    if (!(this instanceof SparseMatrix2)) {
      throw new SyntaxError("Constructor must be called with the new operator");
    }
    if (datatype && !isString(datatype)) {
      throw new Error("Invalid datatype: " + datatype);
    }
    if (isMatrix(data)) {
      _createFromMatrix(this, data, datatype);
    } else if (data && isArray(data.index) && isArray(data.ptr) && isArray(data.size)) {
      this._values = data.values;
      this._index = data.index;
      this._ptr = data.ptr;
      this._size = data.size;
      this._datatype = datatype || data.datatype;
    } else if (isArray(data)) {
      _createFromArray(this, data, datatype);
    } else if (data) {
      throw new TypeError("Unsupported type of data (" + typeOf(data) + ")");
    } else {
      this._values = [];
      this._index = [];
      this._ptr = [0];
      this._size = [0, 0];
      this._datatype = datatype;
    }
  }
  function _createFromMatrix(matrix2, source, datatype) {
    if (source.type === "SparseMatrix") {
      matrix2._values = source._values ? clone(source._values) : void 0;
      matrix2._index = clone(source._index);
      matrix2._ptr = clone(source._ptr);
      matrix2._size = clone(source._size);
      matrix2._datatype = datatype || source._datatype;
    } else {
      _createFromArray(matrix2, source.valueOf(), datatype || source._datatype);
    }
  }
  function _createFromArray(matrix2, data, datatype) {
    matrix2._values = [];
    matrix2._index = [];
    matrix2._ptr = [];
    matrix2._datatype = datatype;
    var rows = data.length;
    var columns = 0;
    var eq = equalScalar2;
    var zero = 0;
    if (isString(datatype)) {
      eq = typed2.find(equalScalar2, [datatype, datatype]) || equalScalar2;
      zero = typed2.convert(0, datatype);
    }
    if (rows > 0) {
      var j = 0;
      do {
        matrix2._ptr.push(matrix2._index.length);
        for (var i = 0; i < rows; i++) {
          var row = data[i];
          if (isArray(row)) {
            if (j === 0 && columns < row.length) {
              columns = row.length;
            }
            if (j < row.length) {
              var v = row[j];
              if (!eq(v, zero)) {
                matrix2._values.push(v);
                matrix2._index.push(i);
              }
            }
          } else {
            if (j === 0 && columns < 1) {
              columns = 1;
            }
            if (!eq(row, zero)) {
              matrix2._values.push(row);
              matrix2._index.push(i);
            }
          }
        }
        j++;
      } while (j < columns);
    }
    matrix2._ptr.push(matrix2._index.length);
    matrix2._size = [rows, columns];
  }
  SparseMatrix2.prototype = new Matrix2();
  SparseMatrix2.prototype.createSparseMatrix = function(data, datatype) {
    return new SparseMatrix2(data, datatype);
  };
  Object.defineProperty(SparseMatrix2, "name", {
    value: "SparseMatrix"
  });
  SparseMatrix2.prototype.constructor = SparseMatrix2;
  SparseMatrix2.prototype.type = "SparseMatrix";
  SparseMatrix2.prototype.isSparseMatrix = true;
  SparseMatrix2.prototype.getDataType = function() {
    return getArrayDataType(this._values, typeOf);
  };
  SparseMatrix2.prototype.storage = function() {
    return "sparse";
  };
  SparseMatrix2.prototype.datatype = function() {
    return this._datatype;
  };
  SparseMatrix2.prototype.create = function(data, datatype) {
    return new SparseMatrix2(data, datatype);
  };
  SparseMatrix2.prototype.density = function() {
    var rows = this._size[0];
    var columns = this._size[1];
    return rows !== 0 && columns !== 0 ? this._index.length / (rows * columns) : 0;
  };
  SparseMatrix2.prototype.subset = function(index, replacement, defaultValue) {
    if (!this._values) {
      throw new Error("Cannot invoke subset on a Pattern only matrix");
    }
    switch (arguments.length) {
      case 1:
        return _getsubset(this, index);
      case 2:
      case 3:
        return _setsubset(this, index, replacement, defaultValue);
      default:
        throw new SyntaxError("Wrong number of arguments");
    }
  };
  function _getsubset(matrix2, idx) {
    if (!isIndex(idx)) {
      throw new TypeError("Invalid index");
    }
    var isScalar = idx.isScalar();
    if (isScalar) {
      return matrix2.get(idx.min());
    }
    var size = idx.size();
    if (size.length !== matrix2._size.length) {
      throw new DimensionError(size.length, matrix2._size.length);
    }
    var i, ii, k, kk;
    var min2 = idx.min();
    var max2 = idx.max();
    for (i = 0, ii = matrix2._size.length; i < ii; i++) {
      validateIndex(min2[i], matrix2._size[i]);
      validateIndex(max2[i], matrix2._size[i]);
    }
    var mvalues = matrix2._values;
    var mindex = matrix2._index;
    var mptr = matrix2._ptr;
    var rows = idx.dimension(0);
    var columns = idx.dimension(1);
    var w = [];
    var pv = [];
    rows.forEach(function(i2, r) {
      pv[i2] = r[0];
      w[i2] = true;
    });
    var values = mvalues ? [] : void 0;
    var index = [];
    var ptr = [];
    columns.forEach(function(j) {
      ptr.push(index.length);
      for (k = mptr[j], kk = mptr[j + 1]; k < kk; k++) {
        i = mindex[k];
        if (w[i] === true) {
          index.push(pv[i]);
          if (values) {
            values.push(mvalues[k]);
          }
        }
      }
    });
    ptr.push(index.length);
    return new SparseMatrix2({
      values,
      index,
      ptr,
      size,
      datatype: matrix2._datatype
    });
  }
  function _setsubset(matrix2, index, submatrix, defaultValue) {
    if (!index || index.isIndex !== true) {
      throw new TypeError("Invalid index");
    }
    var iSize = index.size();
    var isScalar = index.isScalar();
    var sSize;
    if (isMatrix(submatrix)) {
      sSize = submatrix.size();
      submatrix = submatrix.toArray();
    } else {
      sSize = arraySize(submatrix);
    }
    if (isScalar) {
      if (sSize.length !== 0) {
        throw new TypeError("Scalar expected");
      }
      matrix2.set(index.min(), submatrix, defaultValue);
    } else {
      if (iSize.length !== 1 && iSize.length !== 2) {
        throw new DimensionError(iSize.length, matrix2._size.length, "<");
      }
      if (sSize.length < iSize.length) {
        var i = 0;
        var outer = 0;
        while (iSize[i] === 1 && sSize[i] === 1) {
          i++;
        }
        while (iSize[i] === 1) {
          outer++;
          i++;
        }
        submatrix = unsqueeze(submatrix, iSize.length, outer, sSize);
      }
      if (!deepStrictEqual(iSize, sSize)) {
        throw new DimensionError(iSize, sSize, ">");
      }
      if (iSize.length === 1) {
        var range = index.dimension(0);
        range.forEach(function(dataIndex, subIndex) {
          validateIndex(dataIndex);
          matrix2.set([dataIndex, 0], submatrix[subIndex[0]], defaultValue);
        });
      } else {
        var firstDimensionRange = index.dimension(0);
        var secondDimensionRange = index.dimension(1);
        firstDimensionRange.forEach(function(firstDataIndex, firstSubIndex) {
          validateIndex(firstDataIndex);
          secondDimensionRange.forEach(function(secondDataIndex, secondSubIndex) {
            validateIndex(secondDataIndex);
            matrix2.set([firstDataIndex, secondDataIndex], submatrix[firstSubIndex[0]][secondSubIndex[0]], defaultValue);
          });
        });
      }
    }
    return matrix2;
  }
  SparseMatrix2.prototype.get = function(index) {
    if (!isArray(index)) {
      throw new TypeError("Array expected");
    }
    if (index.length !== this._size.length) {
      throw new DimensionError(index.length, this._size.length);
    }
    if (!this._values) {
      throw new Error("Cannot invoke get on a Pattern only matrix");
    }
    var i = index[0];
    var j = index[1];
    validateIndex(i, this._size[0]);
    validateIndex(j, this._size[1]);
    var k = _getValueIndex(i, this._ptr[j], this._ptr[j + 1], this._index);
    if (k < this._ptr[j + 1] && this._index[k] === i) {
      return this._values[k];
    }
    return 0;
  };
  SparseMatrix2.prototype.set = function(index, v, defaultValue) {
    if (!isArray(index)) {
      throw new TypeError("Array expected");
    }
    if (index.length !== this._size.length) {
      throw new DimensionError(index.length, this._size.length);
    }
    if (!this._values) {
      throw new Error("Cannot invoke set on a Pattern only matrix");
    }
    var i = index[0];
    var j = index[1];
    var rows = this._size[0];
    var columns = this._size[1];
    var eq = equalScalar2;
    var zero = 0;
    if (isString(this._datatype)) {
      eq = typed2.find(equalScalar2, [this._datatype, this._datatype]) || equalScalar2;
      zero = typed2.convert(0, this._datatype);
    }
    if (i > rows - 1 || j > columns - 1) {
      _resize2(this, Math.max(i + 1, rows), Math.max(j + 1, columns), defaultValue);
      rows = this._size[0];
      columns = this._size[1];
    }
    validateIndex(i, rows);
    validateIndex(j, columns);
    var k = _getValueIndex(i, this._ptr[j], this._ptr[j + 1], this._index);
    if (k < this._ptr[j + 1] && this._index[k] === i) {
      if (!eq(v, zero)) {
        this._values[k] = v;
      } else {
        _remove(k, j, this._values, this._index, this._ptr);
      }
    } else {
      if (!eq(v, zero)) {
        _insert(k, i, j, v, this._values, this._index, this._ptr);
      }
    }
    return this;
  };
  function _getValueIndex(i, top, bottom, index) {
    if (bottom - top === 0) {
      return bottom;
    }
    for (var r = top; r < bottom; r++) {
      if (index[r] === i) {
        return r;
      }
    }
    return top;
  }
  function _remove(k, j, values, index, ptr) {
    values.splice(k, 1);
    index.splice(k, 1);
    for (var x = j + 1; x < ptr.length; x++) {
      ptr[x]--;
    }
  }
  function _insert(k, i, j, v, values, index, ptr) {
    values.splice(k, 0, v);
    index.splice(k, 0, i);
    for (var x = j + 1; x < ptr.length; x++) {
      ptr[x]++;
    }
  }
  SparseMatrix2.prototype.resize = function(size, defaultValue, copy) {
    if (!isCollection(size)) {
      throw new TypeError("Array or Matrix expected");
    }
    var sizeArray = size.valueOf().map((value) => {
      return Array.isArray(value) && value.length === 1 ? value[0] : value;
    });
    if (sizeArray.length !== 2) {
      throw new Error("Only two dimensions matrix are supported");
    }
    sizeArray.forEach(function(value) {
      if (!isNumber(value) || !isInteger(value) || value < 0) {
        throw new TypeError("Invalid size, must contain positive integers (size: " + format3(sizeArray) + ")");
      }
    });
    var m = copy ? this.clone() : this;
    return _resize2(m, sizeArray[0], sizeArray[1], defaultValue);
  };
  function _resize2(matrix2, rows, columns, defaultValue) {
    var value = defaultValue || 0;
    var eq = equalScalar2;
    var zero = 0;
    if (isString(matrix2._datatype)) {
      eq = typed2.find(equalScalar2, [matrix2._datatype, matrix2._datatype]) || equalScalar2;
      zero = typed2.convert(0, matrix2._datatype);
      value = typed2.convert(value, matrix2._datatype);
    }
    var ins = !eq(value, zero);
    var r = matrix2._size[0];
    var c = matrix2._size[1];
    var i, j, k;
    if (columns > c) {
      for (j = c; j < columns; j++) {
        matrix2._ptr[j] = matrix2._values.length;
        if (ins) {
          for (i = 0; i < r; i++) {
            matrix2._values.push(value);
            matrix2._index.push(i);
          }
        }
      }
      matrix2._ptr[columns] = matrix2._values.length;
    } else if (columns < c) {
      matrix2._ptr.splice(columns + 1, c - columns);
      matrix2._values.splice(matrix2._ptr[columns], matrix2._values.length);
      matrix2._index.splice(matrix2._ptr[columns], matrix2._index.length);
    }
    c = columns;
    if (rows > r) {
      if (ins) {
        var n = 0;
        for (j = 0; j < c; j++) {
          matrix2._ptr[j] = matrix2._ptr[j] + n;
          k = matrix2._ptr[j + 1] + n;
          var p = 0;
          for (i = r; i < rows; i++, p++) {
            matrix2._values.splice(k + p, 0, value);
            matrix2._index.splice(k + p, 0, i);
            n++;
          }
        }
        matrix2._ptr[c] = matrix2._values.length;
      }
    } else if (rows < r) {
      var d = 0;
      for (j = 0; j < c; j++) {
        matrix2._ptr[j] = matrix2._ptr[j] - d;
        var k0 = matrix2._ptr[j];
        var k1 = matrix2._ptr[j + 1] - d;
        for (k = k0; k < k1; k++) {
          i = matrix2._index[k];
          if (i > rows - 1) {
            matrix2._values.splice(k, 1);
            matrix2._index.splice(k, 1);
            d++;
          }
        }
      }
      matrix2._ptr[j] = matrix2._values.length;
    }
    matrix2._size[0] = rows;
    matrix2._size[1] = columns;
    return matrix2;
  }
  SparseMatrix2.prototype.reshape = function(sizes, copy) {
    if (!isArray(sizes)) {
      throw new TypeError("Array expected");
    }
    if (sizes.length !== 2) {
      throw new Error("Sparse matrices can only be reshaped in two dimensions");
    }
    sizes.forEach(function(value) {
      if (!isNumber(value) || !isInteger(value) || value <= -2 || value === 0) {
        throw new TypeError("Invalid size, must contain positive integers or -1 (size: " + format3(sizes) + ")");
      }
    });
    var currentLength = this._size[0] * this._size[1];
    sizes = processSizesWildcard(sizes, currentLength);
    var newLength = sizes[0] * sizes[1];
    if (currentLength !== newLength) {
      throw new Error("Reshaping sparse matrix will result in the wrong number of elements");
    }
    var m = copy ? this.clone() : this;
    if (this._size[0] === sizes[0] && this._size[1] === sizes[1]) {
      return m;
    }
    var colIndex = [];
    for (var i = 0; i < m._ptr.length; i++) {
      for (var j = 0; j < m._ptr[i + 1] - m._ptr[i]; j++) {
        colIndex.push(i);
      }
    }
    var values = m._values.slice();
    var rowIndex = m._index.slice();
    for (var _i = 0; _i < m._index.length; _i++) {
      var r1 = rowIndex[_i];
      var c1 = colIndex[_i];
      var flat = r1 * m._size[1] + c1;
      colIndex[_i] = flat % sizes[1];
      rowIndex[_i] = Math.floor(flat / sizes[1]);
    }
    m._values.length = 0;
    m._index.length = 0;
    m._ptr.length = sizes[1] + 1;
    m._size = sizes.slice();
    for (var _i2 = 0; _i2 < m._ptr.length; _i2++) {
      m._ptr[_i2] = 0;
    }
    for (var h = 0; h < values.length; h++) {
      var _i3 = rowIndex[h];
      var _j = colIndex[h];
      var v = values[h];
      var k = _getValueIndex(_i3, m._ptr[_j], m._ptr[_j + 1], m._index);
      _insert(k, _i3, _j, v, m._values, m._index, m._ptr);
    }
    return m;
  };
  SparseMatrix2.prototype.clone = function() {
    var m = new SparseMatrix2({
      values: this._values ? clone(this._values) : void 0,
      index: clone(this._index),
      ptr: clone(this._ptr),
      size: clone(this._size),
      datatype: this._datatype
    });
    return m;
  };
  SparseMatrix2.prototype.size = function() {
    return this._size.slice(0);
  };
  SparseMatrix2.prototype.map = function(callback, skipZeros) {
    if (!this._values) {
      throw new Error("Cannot invoke map on a Pattern only matrix");
    }
    var me = this;
    var rows = this._size[0];
    var columns = this._size[1];
    var args = maxArgumentCount(callback);
    var invoke = function invoke2(v, i, j) {
      if (args === 1)
        return callback(v);
      if (args === 2)
        return callback(v, [i, j]);
      return callback(v, [i, j], me);
    };
    return _map(this, 0, rows - 1, 0, columns - 1, invoke, skipZeros);
  };
  function _map(matrix2, minRow, maxRow, minColumn, maxColumn, callback, skipZeros) {
    var values = [];
    var index = [];
    var ptr = [];
    var eq = equalScalar2;
    var zero = 0;
    if (isString(matrix2._datatype)) {
      eq = typed2.find(equalScalar2, [matrix2._datatype, matrix2._datatype]) || equalScalar2;
      zero = typed2.convert(0, matrix2._datatype);
    }
    var invoke = function invoke2(v, x, y) {
      v = callback(v, x, y);
      if (!eq(v, zero)) {
        values.push(v);
        index.push(x);
      }
    };
    for (var j = minColumn; j <= maxColumn; j++) {
      ptr.push(values.length);
      var k0 = matrix2._ptr[j];
      var k1 = matrix2._ptr[j + 1];
      if (skipZeros) {
        for (var k = k0; k < k1; k++) {
          var i = matrix2._index[k];
          if (i >= minRow && i <= maxRow) {
            invoke(matrix2._values[k], i - minRow, j - minColumn);
          }
        }
      } else {
        var _values = {};
        for (var _k = k0; _k < k1; _k++) {
          var _i4 = matrix2._index[_k];
          _values[_i4] = matrix2._values[_k];
        }
        for (var _i5 = minRow; _i5 <= maxRow; _i5++) {
          var value = _i5 in _values ? _values[_i5] : 0;
          invoke(value, _i5 - minRow, j - minColumn);
        }
      }
    }
    ptr.push(values.length);
    return new SparseMatrix2({
      values,
      index,
      ptr,
      size: [maxRow - minRow + 1, maxColumn - minColumn + 1]
    });
  }
  SparseMatrix2.prototype.forEach = function(callback, skipZeros) {
    if (!this._values) {
      throw new Error("Cannot invoke forEach on a Pattern only matrix");
    }
    var me = this;
    var rows = this._size[0];
    var columns = this._size[1];
    for (var j = 0; j < columns; j++) {
      var k0 = this._ptr[j];
      var k1 = this._ptr[j + 1];
      if (skipZeros) {
        for (var k = k0; k < k1; k++) {
          var i = this._index[k];
          callback(this._values[k], [i, j], me);
        }
      } else {
        var values = {};
        for (var _k2 = k0; _k2 < k1; _k2++) {
          var _i6 = this._index[_k2];
          values[_i6] = this._values[_k2];
        }
        for (var _i7 = 0; _i7 < rows; _i7++) {
          var value = _i7 in values ? values[_i7] : 0;
          callback(value, [_i7, j], me);
        }
      }
    }
  };
  SparseMatrix2.prototype[Symbol.iterator] = function* () {
    if (!this._values) {
      throw new Error("Cannot iterate a Pattern only matrix");
    }
    var columns = this._size[1];
    for (var j = 0; j < columns; j++) {
      var k0 = this._ptr[j];
      var k1 = this._ptr[j + 1];
      for (var k = k0; k < k1; k++) {
        var i = this._index[k];
        yield {
          value: this._values[k],
          index: [i, j]
        };
      }
    }
  };
  SparseMatrix2.prototype.toArray = function() {
    return _toArray(this._values, this._index, this._ptr, this._size, true);
  };
  SparseMatrix2.prototype.valueOf = function() {
    return _toArray(this._values, this._index, this._ptr, this._size, false);
  };
  function _toArray(values, index, ptr, size, copy) {
    var rows = size[0];
    var columns = size[1];
    var a = [];
    var i, j;
    for (i = 0; i < rows; i++) {
      a[i] = [];
      for (j = 0; j < columns; j++) {
        a[i][j] = 0;
      }
    }
    for (j = 0; j < columns; j++) {
      var k0 = ptr[j];
      var k1 = ptr[j + 1];
      for (var k = k0; k < k1; k++) {
        i = index[k];
        a[i][j] = values ? copy ? clone(values[k]) : values[k] : 1;
      }
    }
    return a;
  }
  SparseMatrix2.prototype.format = function(options) {
    var rows = this._size[0];
    var columns = this._size[1];
    var density = this.density();
    var str = "Sparse Matrix [" + format3(rows, options) + " x " + format3(columns, options) + "] density: " + format3(density, options) + "\n";
    for (var j = 0; j < columns; j++) {
      var k0 = this._ptr[j];
      var k1 = this._ptr[j + 1];
      for (var k = k0; k < k1; k++) {
        var i = this._index[k];
        str += "\n    (" + format3(i, options) + ", " + format3(j, options) + ") ==> " + (this._values ? format3(this._values[k], options) : "X");
      }
    }
    return str;
  };
  SparseMatrix2.prototype.toString = function() {
    return format3(this.toArray());
  };
  SparseMatrix2.prototype.toJSON = function() {
    return {
      mathjs: "SparseMatrix",
      values: this._values,
      index: this._index,
      ptr: this._ptr,
      size: this._size,
      datatype: this._datatype
    };
  };
  SparseMatrix2.prototype.diagonal = function(k) {
    if (k) {
      if (isBigNumber(k)) {
        k = k.toNumber();
      }
      if (!isNumber(k) || !isInteger(k)) {
        throw new TypeError("The parameter k must be an integer number");
      }
    } else {
      k = 0;
    }
    var kSuper = k > 0 ? k : 0;
    var kSub = k < 0 ? -k : 0;
    var rows = this._size[0];
    var columns = this._size[1];
    var n = Math.min(rows - kSub, columns - kSuper);
    var values = [];
    var index = [];
    var ptr = [];
    ptr[0] = 0;
    for (var j = kSuper; j < columns && values.length < n; j++) {
      var k0 = this._ptr[j];
      var k1 = this._ptr[j + 1];
      for (var x = k0; x < k1; x++) {
        var i = this._index[x];
        if (i === j - kSuper + kSub) {
          values.push(this._values[x]);
          index[values.length - 1] = i - kSub;
          break;
        }
      }
    }
    ptr.push(values.length);
    return new SparseMatrix2({
      values,
      index,
      ptr,
      size: [n, 1]
    });
  };
  SparseMatrix2.fromJSON = function(json) {
    return new SparseMatrix2(json);
  };
  SparseMatrix2.diagonal = function(size, value, k, defaultValue, datatype) {
    if (!isArray(size)) {
      throw new TypeError("Array expected, size parameter");
    }
    if (size.length !== 2) {
      throw new Error("Only two dimensions matrix are supported");
    }
    size = size.map(function(s) {
      if (isBigNumber(s)) {
        s = s.toNumber();
      }
      if (!isNumber(s) || !isInteger(s) || s < 1) {
        throw new Error("Size values must be positive integers");
      }
      return s;
    });
    if (k) {
      if (isBigNumber(k)) {
        k = k.toNumber();
      }
      if (!isNumber(k) || !isInteger(k)) {
        throw new TypeError("The parameter k must be an integer number");
      }
    } else {
      k = 0;
    }
    var eq = equalScalar2;
    var zero = 0;
    if (isString(datatype)) {
      eq = typed2.find(equalScalar2, [datatype, datatype]) || equalScalar2;
      zero = typed2.convert(0, datatype);
    }
    var kSuper = k > 0 ? k : 0;
    var kSub = k < 0 ? -k : 0;
    var rows = size[0];
    var columns = size[1];
    var n = Math.min(rows - kSub, columns - kSuper);
    var _value;
    if (isArray(value)) {
      if (value.length !== n) {
        throw new Error("Invalid value array length");
      }
      _value = function _value2(i2) {
        return value[i2];
      };
    } else if (isMatrix(value)) {
      var ms = value.size();
      if (ms.length !== 1 || ms[0] !== n) {
        throw new Error("Invalid matrix length");
      }
      _value = function _value2(i2) {
        return value.get([i2]);
      };
    } else {
      _value = function _value2() {
        return value;
      };
    }
    var values = [];
    var index = [];
    var ptr = [];
    for (var j = 0; j < columns; j++) {
      ptr.push(values.length);
      var i = j - kSuper;
      if (i >= 0 && i < n) {
        var v = _value(i);
        if (!eq(v, zero)) {
          index.push(i + kSub);
          values.push(v);
        }
      }
    }
    ptr.push(values.length);
    return new SparseMatrix2({
      values,
      index,
      ptr,
      size: [rows, columns]
    });
  };
  SparseMatrix2.prototype.swapRows = function(i, j) {
    if (!isNumber(i) || !isInteger(i) || !isNumber(j) || !isInteger(j)) {
      throw new Error("Row index must be positive integers");
    }
    if (this._size.length !== 2) {
      throw new Error("Only two dimensional matrix is supported");
    }
    validateIndex(i, this._size[0]);
    validateIndex(j, this._size[0]);
    SparseMatrix2._swapRows(i, j, this._size[1], this._values, this._index, this._ptr);
    return this;
  };
  SparseMatrix2._forEachRow = function(j, values, index, ptr, callback) {
    var k0 = ptr[j];
    var k1 = ptr[j + 1];
    for (var k = k0; k < k1; k++) {
      callback(index[k], values[k]);
    }
  };
  SparseMatrix2._swapRows = function(x, y, columns, values, index, ptr) {
    for (var j = 0; j < columns; j++) {
      var k0 = ptr[j];
      var k1 = ptr[j + 1];
      var kx = _getValueIndex(x, k0, k1, index);
      var ky = _getValueIndex(y, k0, k1, index);
      if (kx < k1 && ky < k1 && index[kx] === x && index[ky] === y) {
        if (values) {
          var v = values[kx];
          values[kx] = values[ky];
          values[ky] = v;
        }
        continue;
      }
      if (kx < k1 && index[kx] === x && (ky >= k1 || index[ky] !== y)) {
        var vx = values ? values[kx] : void 0;
        index.splice(ky, 0, y);
        if (values) {
          values.splice(ky, 0, vx);
        }
        index.splice(ky <= kx ? kx + 1 : kx, 1);
        if (values) {
          values.splice(ky <= kx ? kx + 1 : kx, 1);
        }
        continue;
      }
      if (ky < k1 && index[ky] === y && (kx >= k1 || index[kx] !== x)) {
        var vy = values ? values[ky] : void 0;
        index.splice(kx, 0, x);
        if (values) {
          values.splice(kx, 0, vy);
        }
        index.splice(kx <= ky ? ky + 1 : ky, 1);
        if (values) {
          values.splice(kx <= ky ? ky + 1 : ky, 1);
        }
      }
    }
  };
  return SparseMatrix2;
}, {
  isClass: true
});

// node_modules/mathjs/lib/esm/type/matrix/function/matrix.js
var name9 = "matrix";
var dependencies10 = ["typed", "Matrix", "DenseMatrix", "SparseMatrix"];
var createMatrix = /* @__PURE__ */ factory(name9, dependencies10, (_ref) => {
  var {
    typed: typed2,
    Matrix: Matrix2,
    DenseMatrix: DenseMatrix2,
    SparseMatrix: SparseMatrix2
  } = _ref;
  return typed2(name9, {
    "": function _() {
      return _create([]);
    },
    string: function string(format4) {
      return _create([], format4);
    },
    "string, string": function stringString(format4, datatype) {
      return _create([], format4, datatype);
    },
    Array: function Array2(data) {
      return _create(data);
    },
    Matrix: function Matrix3(data) {
      return _create(data, data.storage());
    },
    "Array | Matrix, string": _create,
    "Array | Matrix, string, string": _create
  });
  function _create(data, format4, datatype) {
    if (format4 === "dense" || format4 === "default" || format4 === void 0) {
      return new DenseMatrix2(data, datatype);
    }
    if (format4 === "sparse") {
      return new SparseMatrix2(data, datatype);
    }
    throw new TypeError("Unknown matrix type " + JSON.stringify(format4) + ".");
  }
});

// node_modules/mathjs/lib/esm/type/matrix/utils/matAlgo11xS0s.js
var name10 = "matAlgo11xS0s";
var dependencies11 = ["typed", "equalScalar"];
var createMatAlgo11xS0s = /* @__PURE__ */ factory(name10, dependencies11, (_ref) => {
  var {
    typed: typed2,
    equalScalar: equalScalar2
  } = _ref;
  return function matAlgo11xS0s(s, b, callback, inverse) {
    var avalues = s._values;
    var aindex = s._index;
    var aptr = s._ptr;
    var asize = s._size;
    var adt = s._datatype;
    if (!avalues) {
      throw new Error("Cannot perform operation on Pattern Sparse Matrix and Scalar value");
    }
    var rows = asize[0];
    var columns = asize[1];
    var dt;
    var eq = equalScalar2;
    var zero = 0;
    var cf = callback;
    if (typeof adt === "string") {
      dt = adt;
      eq = typed2.find(equalScalar2, [dt, dt]);
      zero = typed2.convert(0, dt);
      b = typed2.convert(b, dt);
      cf = typed2.find(callback, [dt, dt]);
    }
    var cvalues = [];
    var cindex = [];
    var cptr = [];
    for (var j = 0; j < columns; j++) {
      cptr[j] = cindex.length;
      for (var k0 = aptr[j], k1 = aptr[j + 1], k = k0; k < k1; k++) {
        var i = aindex[k];
        var v = inverse ? cf(b, avalues[k]) : cf(avalues[k], b);
        if (!eq(v, zero)) {
          cindex.push(i);
          cvalues.push(v);
        }
      }
    }
    cptr[columns] = cindex.length;
    return s.createSparseMatrix({
      values: cvalues,
      index: cindex,
      ptr: cptr,
      size: [rows, columns],
      datatype: dt
    });
  };
});

// node_modules/mathjs/lib/esm/type/matrix/utils/matAlgo12xSfs.js
var name11 = "matAlgo12xSfs";
var dependencies12 = ["typed", "DenseMatrix"];
var createMatAlgo12xSfs = /* @__PURE__ */ factory(name11, dependencies12, (_ref) => {
  var {
    typed: typed2,
    DenseMatrix: DenseMatrix2
  } = _ref;
  return function matAlgo12xSfs(s, b, callback, inverse) {
    var avalues = s._values;
    var aindex = s._index;
    var aptr = s._ptr;
    var asize = s._size;
    var adt = s._datatype;
    if (!avalues) {
      throw new Error("Cannot perform operation on Pattern Sparse Matrix and Scalar value");
    }
    var rows = asize[0];
    var columns = asize[1];
    var dt;
    var cf = callback;
    if (typeof adt === "string") {
      dt = adt;
      b = typed2.convert(b, dt);
      cf = typed2.find(callback, [dt, dt]);
    }
    var cdata = [];
    var x = [];
    var w = [];
    for (var j = 0; j < columns; j++) {
      var mark = j + 1;
      for (var k0 = aptr[j], k1 = aptr[j + 1], k = k0; k < k1; k++) {
        var r = aindex[k];
        x[r] = avalues[k];
        w[r] = mark;
      }
      for (var i = 0; i < rows; i++) {
        if (j === 0) {
          cdata[i] = [];
        }
        if (w[i] === mark) {
          cdata[i][j] = inverse ? cf(b, x[i]) : cf(x[i], b);
        } else {
          cdata[i][j] = inverse ? cf(b, 0) : cf(0, b);
        }
      }
    }
    return new DenseMatrix2({
      data: cdata,
      size: [rows, columns],
      datatype: dt
    });
  };
});

// node_modules/mathjs/lib/esm/type/matrix/utils/matAlgo14xDs.js
var name12 = "matAlgo14xDs";
var dependencies13 = ["typed"];
var createMatAlgo14xDs = /* @__PURE__ */ factory(name12, dependencies13, (_ref) => {
  var {
    typed: typed2
  } = _ref;
  return function matAlgo14xDs(a, b, callback, inverse) {
    var adata = a._data;
    var asize = a._size;
    var adt = a._datatype;
    var dt;
    var cf = callback;
    if (typeof adt === "string") {
      dt = adt;
      b = typed2.convert(b, dt);
      cf = typed2.find(callback, [dt, dt]);
    }
    var cdata = asize.length > 0 ? _iterate(cf, 0, asize, asize[0], adata, b, inverse) : [];
    return a.createDenseMatrix({
      data: cdata,
      size: clone(asize),
      datatype: dt
    });
  };
  function _iterate(f, level, s, n, av, bv, inverse) {
    var cv = [];
    if (level === s.length - 1) {
      for (var i = 0; i < n; i++) {
        cv[i] = inverse ? f(bv, av[i]) : f(av[i], bv);
      }
    } else {
      for (var j = 0; j < n; j++) {
        cv[j] = _iterate(f, level + 1, s, s[level + 1], av[j], bv, inverse);
      }
    }
    return cv;
  }
});

// node_modules/mathjs/lib/esm/type/matrix/utils/matAlgo13xDD.js
var name13 = "matAlgo13xDD";
var dependencies14 = ["typed"];
var createMatAlgo13xDD = /* @__PURE__ */ factory(name13, dependencies14, (_ref) => {
  var {
    typed: typed2
  } = _ref;
  return function matAlgo13xDD(a, b, callback) {
    var adata = a._data;
    var asize = a._size;
    var adt = a._datatype;
    var bdata = b._data;
    var bsize = b._size;
    var bdt = b._datatype;
    var csize = [];
    if (asize.length !== bsize.length) {
      throw new DimensionError(asize.length, bsize.length);
    }
    for (var s = 0; s < asize.length; s++) {
      if (asize[s] !== bsize[s]) {
        throw new RangeError("Dimension mismatch. Matrix A (" + asize + ") must match Matrix B (" + bsize + ")");
      }
      csize[s] = asize[s];
    }
    var dt;
    var cf = callback;
    if (typeof adt === "string" && adt === bdt) {
      dt = adt;
      cf = typed2.find(callback, [dt, dt]);
    }
    var cdata = csize.length > 0 ? _iterate(cf, 0, csize, csize[0], adata, bdata) : [];
    return a.createDenseMatrix({
      data: cdata,
      size: csize,
      datatype: dt
    });
  };
  function _iterate(f, level, s, n, av, bv) {
    var cv = [];
    if (level === s.length - 1) {
      for (var i = 0; i < n; i++) {
        cv[i] = f(av[i], bv[i]);
      }
    } else {
      for (var j = 0; j < n; j++) {
        cv[j] = _iterate(f, level + 1, s, s[level + 1], av[j], bv[j]);
      }
    }
    return cv;
  }
});

// node_modules/mathjs/lib/esm/type/matrix/utils/broadcast.js
var name14 = "broadcast";
var dependancies = ["concat"];
var createBroadcast = /* @__PURE__ */ factory(name14, dependancies, (_ref) => {
  var {
    concat: concat2
  } = _ref;
  return function(A, B) {
    var N = Math.max(A._size.length, B._size.length);
    if (A._size.length === B._size.length) {
      if (A._size.every((dim2, i) => dim2 === B._size[i])) {
        return [A, B];
      }
    }
    var sizeA = _padLeft(A._size, N, 0);
    var sizeB = _padLeft(B._size, N, 0);
    var sizeMax = [];
    for (var dim = 0; dim < N; dim++) {
      sizeMax[dim] = Math.max(sizeA[dim], sizeB[dim]);
    }
    for (var _dim = 0; _dim < N; _dim++) {
      _checkRules(sizeA, sizeMax, _dim);
      _checkRules(sizeB, sizeMax, _dim);
    }
    var AA = A.clone();
    var BB = B.clone();
    if (AA._size.length < N) {
      AA.reshape(_padLeft(AA._size, N, 1));
    } else if (BB._size.length < N) {
      BB.reshape(_padLeft(BB._size, N, 1));
    }
    for (var _dim2 = 0; _dim2 < N; _dim2++) {
      if (AA._size[_dim2] < sizeMax[_dim2]) {
        AA = _stretch(AA, sizeMax[_dim2], _dim2);
      }
      if (BB._size[_dim2] < sizeMax[_dim2]) {
        BB = _stretch(BB, sizeMax[_dim2], _dim2);
      }
    }
    return [AA, BB];
  };
  function _padLeft(shape, N, filler) {
    return [...Array(N - shape.length).fill(filler), ...shape];
  }
  function _stretch(arrayToStretch, sizeToStretch, dimToStretch) {
    return concat2(...Array(sizeToStretch).fill(arrayToStretch), dimToStretch);
  }
  function _checkRules(shape, sizeMax, dim) {
    if (shape[dim] < sizeMax[dim] & shape[dim] > 1) {
      throw new Error("shape missmatch: missmatch is found in arg with shape (".concat(shape, ") not possible to broadcast dimension ").concat(dim, " with size ").concat(shape[dim], " to size ").concat(sizeMax[dim]));
    }
  }
});

// node_modules/mathjs/lib/esm/type/matrix/utils/matrixAlgorithmSuite.js
var name15 = "matrixAlgorithmSuite";
var dependencies15 = ["typed", "matrix", "concat"];
var createMatrixAlgorithmSuite = /* @__PURE__ */ factory(name15, dependencies15, (_ref) => {
  var {
    typed: typed2,
    matrix: matrix2,
    concat: concat2
  } = _ref;
  var matAlgo13xDD = createMatAlgo13xDD({
    typed: typed2
  });
  var matAlgo14xDs = createMatAlgo14xDs({
    typed: typed2
  });
  var broadcast = createBroadcast({
    concat: concat2
  });
  return function matrixAlgorithmSuite(options) {
    var elop = options.elop;
    var SD = options.SD || options.DS;
    var matrixSignatures;
    if (elop) {
      matrixSignatures = {
        "DenseMatrix, DenseMatrix": (x, y) => matAlgo13xDD(...broadcast(x, y), elop),
        "Array, Array": (x, y) => matAlgo13xDD(...broadcast(matrix2(x), matrix2(y)), elop).valueOf(),
        "Array, DenseMatrix": (x, y) => matAlgo13xDD(...broadcast(matrix2(x), y), elop),
        "DenseMatrix, Array": (x, y) => matAlgo13xDD(...broadcast(x, matrix2(y)), elop)
      };
      if (options.SS) {
        matrixSignatures["SparseMatrix, SparseMatrix"] = (x, y) => options.SS(...broadcast(x, y), elop, false);
      }
      if (options.DS) {
        matrixSignatures["DenseMatrix, SparseMatrix"] = (x, y) => options.DS(...broadcast(x, y), elop, false);
        matrixSignatures["Array, SparseMatrix"] = (x, y) => options.DS(...broadcast(matrix2(x), y), elop, false);
      }
      if (SD) {
        matrixSignatures["SparseMatrix, DenseMatrix"] = (x, y) => SD(...broadcast(y, x), elop, true);
        matrixSignatures["SparseMatrix, Array"] = (x, y) => SD(...broadcast(matrix2(y), x), elop, true);
      }
    } else {
      matrixSignatures = {
        "DenseMatrix, DenseMatrix": typed2.referToSelf((self2) => (x, y) => {
          return matAlgo13xDD(...broadcast(x, y), self2);
        }),
        "Array, Array": typed2.referToSelf((self2) => (x, y) => {
          return matAlgo13xDD(...broadcast(matrix2(x), matrix2(y)), self2).valueOf();
        }),
        "Array, DenseMatrix": typed2.referToSelf((self2) => (x, y) => {
          return matAlgo13xDD(...broadcast(matrix2(x), y), self2);
        }),
        "DenseMatrix, Array": typed2.referToSelf((self2) => (x, y) => {
          return matAlgo13xDD(...broadcast(x, matrix2(y)), self2);
        })
      };
      if (options.SS) {
        matrixSignatures["SparseMatrix, SparseMatrix"] = typed2.referToSelf((self2) => (x, y) => {
          return options.SS(...broadcast(x, y), self2, false);
        });
      }
      if (options.DS) {
        matrixSignatures["DenseMatrix, SparseMatrix"] = typed2.referToSelf((self2) => (x, y) => {
          return options.DS(...broadcast(x, y), self2, false);
        });
        matrixSignatures["Array, SparseMatrix"] = typed2.referToSelf((self2) => (x, y) => {
          return options.DS(...broadcast(matrix2(x), y), self2, false);
        });
      }
      if (SD) {
        matrixSignatures["SparseMatrix, DenseMatrix"] = typed2.referToSelf((self2) => (x, y) => {
          return SD(...broadcast(y, x), self2, true);
        });
        matrixSignatures["SparseMatrix, Array"] = typed2.referToSelf((self2) => (x, y) => {
          return SD(...broadcast(matrix2(y), x), self2, true);
        });
      }
    }
    var scalar = options.scalar || "any";
    var Ds = options.Ds || options.Ss;
    if (Ds) {
      if (elop) {
        matrixSignatures["DenseMatrix," + scalar] = (x, y) => matAlgo14xDs(x, y, elop, false);
        matrixSignatures[scalar + ", DenseMatrix"] = (x, y) => matAlgo14xDs(y, x, elop, true);
        matrixSignatures["Array," + scalar] = (x, y) => matAlgo14xDs(matrix2(x), y, elop, false).valueOf();
        matrixSignatures[scalar + ", Array"] = (x, y) => matAlgo14xDs(matrix2(y), x, elop, true).valueOf();
      } else {
        matrixSignatures["DenseMatrix," + scalar] = typed2.referToSelf((self2) => (x, y) => {
          return matAlgo14xDs(x, y, self2, false);
        });
        matrixSignatures[scalar + ", DenseMatrix"] = typed2.referToSelf((self2) => (x, y) => {
          return matAlgo14xDs(y, x, self2, true);
        });
        matrixSignatures["Array," + scalar] = typed2.referToSelf((self2) => (x, y) => {
          return matAlgo14xDs(matrix2(x), y, self2, false).valueOf();
        });
        matrixSignatures[scalar + ", Array"] = typed2.referToSelf((self2) => (x, y) => {
          return matAlgo14xDs(matrix2(y), x, self2, true).valueOf();
        });
      }
    }
    var sS = options.sS !== void 0 ? options.sS : options.Ss;
    if (elop) {
      if (options.Ss) {
        matrixSignatures["SparseMatrix," + scalar] = (x, y) => options.Ss(x, y, elop, false);
      }
      if (sS) {
        matrixSignatures[scalar + ", SparseMatrix"] = (x, y) => sS(y, x, elop, true);
      }
    } else {
      if (options.Ss) {
        matrixSignatures["SparseMatrix," + scalar] = typed2.referToSelf((self2) => (x, y) => {
          return options.Ss(x, y, self2, false);
        });
      }
      if (sS) {
        matrixSignatures[scalar + ", SparseMatrix"] = typed2.referToSelf((self2) => (x, y) => {
          return sS(y, x, self2, true);
        });
      }
    }
    if (elop && elop.signatures) {
      extend(matrixSignatures, elop.signatures);
    }
    return matrixSignatures;
  };
});

// node_modules/mathjs/lib/esm/type/matrix/utils/matAlgo02xDS0.js
var name16 = "matAlgo02xDS0";
var dependencies16 = ["typed", "equalScalar"];
var createMatAlgo02xDS0 = /* @__PURE__ */ factory(name16, dependencies16, (_ref) => {
  var {
    typed: typed2,
    equalScalar: equalScalar2
  } = _ref;
  return function matAlgo02xDS0(denseMatrix, sparseMatrix, callback, inverse) {
    var adata = denseMatrix._data;
    var asize = denseMatrix._size;
    var adt = denseMatrix._datatype;
    var bvalues = sparseMatrix._values;
    var bindex = sparseMatrix._index;
    var bptr = sparseMatrix._ptr;
    var bsize = sparseMatrix._size;
    var bdt = sparseMatrix._datatype;
    if (asize.length !== bsize.length) {
      throw new DimensionError(asize.length, bsize.length);
    }
    if (asize[0] !== bsize[0] || asize[1] !== bsize[1]) {
      throw new RangeError("Dimension mismatch. Matrix A (" + asize + ") must match Matrix B (" + bsize + ")");
    }
    if (!bvalues) {
      throw new Error("Cannot perform operation on Dense Matrix and Pattern Sparse Matrix");
    }
    var rows = asize[0];
    var columns = asize[1];
    var dt;
    var eq = equalScalar2;
    var zero = 0;
    var cf = callback;
    if (typeof adt === "string" && adt === bdt) {
      dt = adt;
      eq = typed2.find(equalScalar2, [dt, dt]);
      zero = typed2.convert(0, dt);
      cf = typed2.find(callback, [dt, dt]);
    }
    var cvalues = [];
    var cindex = [];
    var cptr = [];
    for (var j = 0; j < columns; j++) {
      cptr[j] = cindex.length;
      for (var k0 = bptr[j], k1 = bptr[j + 1], k = k0; k < k1; k++) {
        var i = bindex[k];
        var cij = inverse ? cf(bvalues[k], adata[i][j]) : cf(adata[i][j], bvalues[k]);
        if (!eq(cij, zero)) {
          cindex.push(i);
          cvalues.push(cij);
        }
      }
    }
    cptr[columns] = cindex.length;
    return sparseMatrix.createSparseMatrix({
      values: cvalues,
      index: cindex,
      ptr: cptr,
      size: [rows, columns],
      datatype: dt
    });
  };
});

// node_modules/mathjs/lib/esm/type/matrix/utils/matAlgo03xDSf.js
var name17 = "matAlgo03xDSf";
var dependencies17 = ["typed"];
var createMatAlgo03xDSf = /* @__PURE__ */ factory(name17, dependencies17, (_ref) => {
  var {
    typed: typed2
  } = _ref;
  return function matAlgo03xDSf(denseMatrix, sparseMatrix, callback, inverse) {
    var adata = denseMatrix._data;
    var asize = denseMatrix._size;
    var adt = denseMatrix._datatype;
    var bvalues = sparseMatrix._values;
    var bindex = sparseMatrix._index;
    var bptr = sparseMatrix._ptr;
    var bsize = sparseMatrix._size;
    var bdt = sparseMatrix._datatype;
    if (asize.length !== bsize.length) {
      throw new DimensionError(asize.length, bsize.length);
    }
    if (asize[0] !== bsize[0] || asize[1] !== bsize[1]) {
      throw new RangeError("Dimension mismatch. Matrix A (" + asize + ") must match Matrix B (" + bsize + ")");
    }
    if (!bvalues) {
      throw new Error("Cannot perform operation on Dense Matrix and Pattern Sparse Matrix");
    }
    var rows = asize[0];
    var columns = asize[1];
    var dt;
    var zero = 0;
    var cf = callback;
    if (typeof adt === "string" && adt === bdt) {
      dt = adt;
      zero = typed2.convert(0, dt);
      cf = typed2.find(callback, [dt, dt]);
    }
    var cdata = [];
    for (var z = 0; z < rows; z++) {
      cdata[z] = [];
    }
    var x = [];
    var w = [];
    for (var j = 0; j < columns; j++) {
      var mark = j + 1;
      for (var k0 = bptr[j], k1 = bptr[j + 1], k = k0; k < k1; k++) {
        var i = bindex[k];
        x[i] = inverse ? cf(bvalues[k], adata[i][j]) : cf(adata[i][j], bvalues[k]);
        w[i] = mark;
      }
      for (var y = 0; y < rows; y++) {
        if (w[y] === mark) {
          cdata[y][j] = x[y];
        } else {
          cdata[y][j] = inverse ? cf(zero, adata[y][j]) : cf(adata[y][j], zero);
        }
      }
    }
    return denseMatrix.createDenseMatrix({
      data: cdata,
      size: [rows, columns],
      datatype: dt
    });
  };
});

// node_modules/mathjs/lib/esm/type/matrix/utils/matAlgo09xS0Sf.js
var name18 = "matAlgo09xS0Sf";
var dependencies18 = ["typed", "equalScalar"];
var createMatAlgo09xS0Sf = /* @__PURE__ */ factory(name18, dependencies18, (_ref) => {
  var {
    typed: typed2,
    equalScalar: equalScalar2
  } = _ref;
  return function matAlgo09xS0Sf(a, b, callback) {
    var avalues = a._values;
    var aindex = a._index;
    var aptr = a._ptr;
    var asize = a._size;
    var adt = a._datatype;
    var bvalues = b._values;
    var bindex = b._index;
    var bptr = b._ptr;
    var bsize = b._size;
    var bdt = b._datatype;
    if (asize.length !== bsize.length) {
      throw new DimensionError(asize.length, bsize.length);
    }
    if (asize[0] !== bsize[0] || asize[1] !== bsize[1]) {
      throw new RangeError("Dimension mismatch. Matrix A (" + asize + ") must match Matrix B (" + bsize + ")");
    }
    var rows = asize[0];
    var columns = asize[1];
    var dt;
    var eq = equalScalar2;
    var zero = 0;
    var cf = callback;
    if (typeof adt === "string" && adt === bdt) {
      dt = adt;
      eq = typed2.find(equalScalar2, [dt, dt]);
      zero = typed2.convert(0, dt);
      cf = typed2.find(callback, [dt, dt]);
    }
    var cvalues = avalues && bvalues ? [] : void 0;
    var cindex = [];
    var cptr = [];
    var x = cvalues ? [] : void 0;
    var w = [];
    var i, j, k, k0, k1;
    for (j = 0; j < columns; j++) {
      cptr[j] = cindex.length;
      var mark = j + 1;
      if (x) {
        for (k0 = bptr[j], k1 = bptr[j + 1], k = k0; k < k1; k++) {
          i = bindex[k];
          w[i] = mark;
          x[i] = bvalues[k];
        }
      }
      for (k0 = aptr[j], k1 = aptr[j + 1], k = k0; k < k1; k++) {
        i = aindex[k];
        if (x) {
          var vb = w[i] === mark ? x[i] : zero;
          var vc = cf(avalues[k], vb);
          if (!eq(vc, zero)) {
            cindex.push(i);
            cvalues.push(vc);
          }
        } else {
          cindex.push(i);
        }
      }
    }
    cptr[columns] = cindex.length;
    return a.createSparseMatrix({
      values: cvalues,
      index: cindex,
      ptr: cptr,
      size: [rows, columns],
      datatype: dt
    });
  };
});

// node_modules/mathjs/lib/esm/function/matrix/concat.js
var name19 = "concat";
var dependencies19 = ["typed", "matrix", "isInteger"];
var createConcat = /* @__PURE__ */ factory(name19, dependencies19, (_ref) => {
  var {
    typed: typed2,
    matrix: matrix2,
    isInteger: isInteger3
  } = _ref;
  return typed2(name19, {
    "...Array | Matrix | number | BigNumber": function ArrayMatrixNumberBigNumber(args) {
      var i;
      var len = args.length;
      var dim = -1;
      var prevDim;
      var asMatrix = false;
      var matrices = [];
      for (i = 0; i < len; i++) {
        var arg = args[i];
        if (isMatrix(arg)) {
          asMatrix = true;
        }
        if (isNumber(arg) || isBigNumber(arg)) {
          if (i !== len - 1) {
            throw new Error("Dimension must be specified as last argument");
          }
          prevDim = dim;
          dim = arg.valueOf();
          if (!isInteger3(dim)) {
            throw new TypeError("Integer number expected for dimension");
          }
          if (dim < 0 || i > 0 && dim > prevDim) {
            throw new IndexError(dim, prevDim + 1);
          }
        } else {
          var m = clone(arg).valueOf();
          var size = arraySize(m);
          matrices[i] = m;
          prevDim = dim;
          dim = size.length - 1;
          if (i > 0 && dim !== prevDim) {
            throw new DimensionError(prevDim + 1, dim + 1);
          }
        }
      }
      if (matrices.length === 0) {
        throw new SyntaxError("At least one matrix expected");
      }
      var res = matrices.shift();
      while (matrices.length) {
        res = _concat(res, matrices.shift(), dim, 0);
      }
      return asMatrix ? matrix2(res) : res;
    },
    "...string": function string(args) {
      return args.join("");
    }
  });
});
function _concat(a, b, concatDim, dim) {
  if (dim < concatDim) {
    if (a.length !== b.length) {
      throw new DimensionError(a.length, b.length);
    }
    var c = [];
    for (var i = 0; i < a.length; i++) {
      c[i] = _concat(a[i], b[i], concatDim, dim + 1);
    }
    return c;
  } else {
    return a.concat(b);
  }
}

// node_modules/mathjs/lib/esm/function/trigonometry/atan2.js
var name20 = "atan2";
var dependencies20 = ["typed", "matrix", "equalScalar", "BigNumber", "DenseMatrix", "concat"];
var createAtan2 = /* @__PURE__ */ factory(name20, dependencies20, (_ref) => {
  var {
    typed: typed2,
    matrix: matrix2,
    equalScalar: equalScalar2,
    BigNumber: BigNumber2,
    DenseMatrix: DenseMatrix2,
    concat: concat2
  } = _ref;
  var matAlgo02xDS0 = createMatAlgo02xDS0({
    typed: typed2,
    equalScalar: equalScalar2
  });
  var matAlgo03xDSf = createMatAlgo03xDSf({
    typed: typed2
  });
  var matAlgo09xS0Sf = createMatAlgo09xS0Sf({
    typed: typed2,
    equalScalar: equalScalar2
  });
  var matAlgo11xS0s = createMatAlgo11xS0s({
    typed: typed2,
    equalScalar: equalScalar2
  });
  var matAlgo12xSfs = createMatAlgo12xSfs({
    typed: typed2,
    DenseMatrix: DenseMatrix2
  });
  var matrixAlgorithmSuite = createMatrixAlgorithmSuite({
    typed: typed2,
    matrix: matrix2,
    concat: concat2
  });
  return typed2(name20, {
    "number, number": Math.atan2,
    "BigNumber, BigNumber": (y, x) => BigNumber2.atan2(y, x)
  }, matrixAlgorithmSuite({
    scalar: "number | BigNumber",
    SS: matAlgo09xS0Sf,
    DS: matAlgo03xDSf,
    SD: matAlgo02xDS0,
    Ss: matAlgo11xS0s,
    sS: matAlgo12xSfs
  }));
});

// node_modules/mathjs/lib/esm/entry/pureFunctionsAny.generated.js
var BigNumber = /* @__PURE__ */ createBigNumberClass({
  config
});
var Complex2 = /* @__PURE__ */ createComplexClass({});
var Fraction2 = /* @__PURE__ */ createFractionClass({});
var Matrix = /* @__PURE__ */ createMatrixClass({});
var DenseMatrix = /* @__PURE__ */ createDenseMatrixClass({
  Matrix
});
var typed = /* @__PURE__ */ createTyped({
  BigNumber,
  Complex: Complex2,
  DenseMatrix,
  Fraction: Fraction2
});
var equalScalar = /* @__PURE__ */ createEqualScalar({
  config,
  typed
});
var isInteger2 = /* @__PURE__ */ createIsInteger({
  typed
});
var SparseMatrix = /* @__PURE__ */ createSparseMatrixClass({
  Matrix,
  equalScalar,
  typed
});
var matrix = /* @__PURE__ */ createMatrix({
  DenseMatrix,
  Matrix,
  SparseMatrix,
  typed
});
var concat = /* @__PURE__ */ createConcat({
  isInteger: isInteger2,
  matrix,
  typed
});
var atan22 = /* @__PURE__ */ createAtan2({
  BigNumber,
  DenseMatrix,
  concat,
  equalScalar,
  matrix,
  typed
});

// examples/mathjs/input.ts
function atan23(one, two) {
  const result = atan22(one, two);
  return result;
}

/*!
 *  decimal.js v10.6.0
 *  An arbitrary-precision Decimal type for JavaScript.
 *  https://github.com/MikeMcl/decimal.js
 *  Copyright (c) 2025 Michael Mclaughlin <M8ch88l@gmail.com>
 *  MIT Licence
 */
/**
 * @license Fraction.js v4.3.7 31/08/2023
 * https://www.xarg.org/2014/03/rational-numbers-in-javascript/
 *
 * Copyright (c) 2023, Robert Eisele (robert@raw.org)
 * Dual licensed under the MIT or GPL Version 2 licenses.
 **/

return atan2(one,two)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;