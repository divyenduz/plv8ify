DROP FUNCTION IF EXISTS plv8ify_init();
CREATE OR REPLACE FUNCTION plv8ify_init() RETURNS VOID AS $$
"use strict";
this.plv8ify = (() => {
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

  // examples/hello-start_proc/input.ts
  var input_exports = {};
  __export(input_exports, {
    hello: () => hello,
    world: () => world
  });
  function hello() {
    return "world";
  }
  function world() {
    return "hello";
  }
  return __toCommonJS(input_exports);
})();

$$ LANGUAGE plv8 IMMUTABLE STRICT;
