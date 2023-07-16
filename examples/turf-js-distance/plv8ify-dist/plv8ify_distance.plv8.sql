DROP FUNCTION IF EXISTS plv8ify_distance(lat JSONB,long JSONB);
CREATE OR REPLACE FUNCTION plv8ify_distance(lat JSONB,long JSONB) RETURNS float8 AS $plv8ify$
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

  // examples/turf-js-distance/input.ts
  var input_exports = {};
  __export(input_exports, {
    distance: () => distance2
  });

  // node_modules/@turf/helpers/dist/es/index.js
  var earthRadius = 63710088e-1;
  var factors = {
    centimeters: earthRadius * 100,
    centimetres: earthRadius * 100,
    degrees: earthRadius / 111325,
    feet: earthRadius * 3.28084,
    inches: earthRadius * 39.37,
    kilometers: earthRadius / 1e3,
    kilometres: earthRadius / 1e3,
    meters: earthRadius,
    metres: earthRadius,
    miles: earthRadius / 1609.344,
    millimeters: earthRadius * 1e3,
    millimetres: earthRadius * 1e3,
    nauticalmiles: earthRadius / 1852,
    radians: 1,
    yards: earthRadius * 1.0936
  };
  var unitsFactors = {
    centimeters: 100,
    centimetres: 100,
    degrees: 1 / 111325,
    feet: 3.28084,
    inches: 39.37,
    kilometers: 1 / 1e3,
    kilometres: 1 / 1e3,
    meters: 1,
    metres: 1,
    miles: 1 / 1609.344,
    millimeters: 1e3,
    millimetres: 1e3,
    nauticalmiles: 1 / 1852,
    radians: 1 / earthRadius,
    yards: 1.0936133
  };
  function radiansToLength(radians, units) {
    if (units === void 0) {
      units = "kilometers";
    }
    var factor = factors[units];
    if (!factor) {
      throw new Error(units + " units is invalid");
    }
    return radians * factor;
  }
  function degreesToRadians(degrees) {
    var radians = degrees % 360;
    return radians * Math.PI / 180;
  }

  // node_modules/@turf/invariant/dist/es/index.js
  function getCoord(coord) {
    if (!coord) {
      throw new Error("coord is required");
    }
    if (!Array.isArray(coord)) {
      if (coord.type === "Feature" && coord.geometry !== null && coord.geometry.type === "Point") {
        return coord.geometry.coordinates;
      }
      if (coord.type === "Point") {
        return coord.coordinates;
      }
    }
    if (Array.isArray(coord) && coord.length >= 2 && !Array.isArray(coord[0]) && !Array.isArray(coord[1])) {
      return coord;
    }
    throw new Error("coord must be GeoJSON Point or an Array of numbers");
  }

  // node_modules/@turf/distance/dist/es/index.js
  function distance(from, to, options) {
    if (options === void 0) {
      options = {};
    }
    var coordinates1 = getCoord(from);
    var coordinates2 = getCoord(to);
    var dLat = degreesToRadians(coordinates2[1] - coordinates1[1]);
    var dLon = degreesToRadians(coordinates2[0] - coordinates1[0]);
    var lat1 = degreesToRadians(coordinates1[1]);
    var lat2 = degreesToRadians(coordinates2[1]);
    var a = Math.pow(Math.sin(dLat / 2), 2) + Math.pow(Math.sin(dLon / 2), 2) * Math.cos(lat1) * Math.cos(lat2);
    return radiansToLength(2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)), options.units);
  }
  var es_default = distance;

  // examples/turf-js-distance/input.ts
  function distance2(lat, long) {
    const pt = es_default(lat, long, {
      units: "kilometers"
    });
    return pt;
  }
  console.log(distance2([13.408976, 52.543672], [13.409018, 52.543605]));
  return __toCommonJS(input_exports);
})();

return plv8ify.distance(lat,long)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;