/* IMPORTANT
 * This snapshot file is auto-generated, but designed for humans.
 * It should be checked into source control and tracked carefully.
 * Re-generate by setting TAP_SNAPSHOT=1 and running tests.
 * Make sure to inspect the output below.  Do not ignore changes!
 */
'use strict'
exports[`src/impl/EsBuild.test.ts TAP getBundleJs - inline mode > must match snapshot 1`] = `
"use strict";
var plv8ify = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

  // src/test-fixtures/input.fixture.ts
  var input_fixture_exports = {};
  __export(input_fixture_exports, {
    sayHello: () => sayHello
  });
  function sayHello(toWhom) {
    const greet = \`hello \` + toWhom;
    return greet;
  }
  return __toCommonJS(input_fixture_exports);
})();

`

exports[`src/impl/EsBuild.test.ts TAP getBundleJs - newline string > must match snapshot 1`] = `
"use strict";
var plv8ify = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

  // src/test-fixtures/newline-string.fixture.ts
  var newline_string_fixture_exports = {};
  __export(newline_string_fixture_exports, {
    sayHello: () => sayHello
  });
  function sayHello() {
    const greetString = "hello\\nworld";
    return greetString;
  }
  return __toCommonJS(newline_string_fixture_exports);
})();

`

exports[`src/impl/EsBuild.test.ts TAP getBundleJs - newline template > must match snapshot 1`] = `
"use strict";
var plv8ify = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

  // src/test-fixtures/newline-template.fixture.ts
  var newline_template_fixture_exports = {};
  __export(newline_template_fixture_exports, {
    sayHello: () => sayHello
  });
  function sayHello() {
    const greetTemplate = \`hello 
 world\`;
    return greetTemplate;
  }
  return __toCommonJS(newline_template_fixture_exports);
})();

`
