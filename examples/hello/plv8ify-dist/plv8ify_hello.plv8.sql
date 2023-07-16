DROP FUNCTION IF EXISTS plv8ify_hello();
CREATE OR REPLACE FUNCTION plv8ify_hello() RETURNS text AS $plv8ify$
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

  // examples/hello/input.ts
  var input_exports = {};
  __export(input_exports, {
    hello: () => hello
  });
  function hello() {
    return "world";
  }
  return __toCommonJS(input_exports);
})();

return plv8ify.hello()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;