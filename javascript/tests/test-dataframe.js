import DataFrame from "./dataframe";
import assert from "assert";

describe("DataFrame", () => {
  let speed = [4, 4, 7, 7, 8, 9, 10, 10, 10, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 16, 16, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 20, 20, 20, 20, 20, 22, 23, 24, 24, 24, 24, 25];
  let dist = [2, 10, 4, 22, 16, 10, 18, 26, 34, 17, 28, 14, 20, 24, 28, 26, 34, 34, 46, 26, 36, 60, 80, 20, 26, 54, 32, 40, 32, 40, 50, 42, 56, 76, 84, 36, 46, 68, 32, 48, 52, 56, 64, 66, 54, 70, 92, 93, 120, 85];
  let df = new DataFrame();
  df.col("speed", speed)
    .col("dist", dist)
    .col("color", ["yellow", "red"])
    .cbind({
      "Make" : ["Toyota", "Cadillac", "BMW"],
      "Model" : ["Corolla", "CTS", "435i"]
    });

  it("can index into rows", () => {
  	assert.equal(df.get(9, "speed"), 11);
  	assert.equal(df.get(9, "dist"), 17);
  });

  it("recycles column values", () => {
  	assert.equal(df.get(9, "color"), "red");
  });

  it("recycles when cbinding", () => {
  	assert.equal(df.get(9, "Make"), "Toyota");
  	assert.equal(df.get(9, "Model"), "Corolla");
  });
});
