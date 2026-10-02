import test from "node:test";
import assert from "node:assert/strict";
import {distanceMeters} from "../src/geo.js";

test("distanceMeters returns zero for identical points", () => {
  assert.equal(distanceMeters({latitude: 37.72, longitude: -122.48}, {latitude: 37.72, longitude: -122.48}), 0);
});

test("distanceMeters is symmetric", () => {
  const a = {latitude: 37.7219, longitude: -122.4782};
  const b = {latitude: 37.7236, longitude: -122.4812};
  const ab = distanceMeters(a, b);
  const ba = distanceMeters(b, a);
  assert.ok(Math.abs(ab - ba) < 0.001);
  assert.ok(ab > 100 && ab < 1000);
});
