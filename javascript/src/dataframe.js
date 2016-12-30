import { recycle, asArray } from "./util";

export default class DataFrame {
  constructor() {
    this.columns = [];
    this.colnames = [];
    this.colstrict = [];

    this.effectiveLength = 0;
    this.colindices = {};
  }

  _updateCachedProperties() {
    this.effectiveLength = 0;
    this.colindices = {};

    this.columns.forEach((column, i) => {
      this.effectiveLength = Math.max(this.effectiveLength, column.length);
      this.colindices[this.colnames[i]] = i;
    });
  }

  _colIndex(colname) {
    let index = this.colindices[colname];
    if (typeof(index) === "undefined")
      return -1;
    return index;
  }

  col(name, values, strict) {
    if (typeof(name) !== "string")
      throw new Error("Invalid column name \"" + name + "\"");

    let index = this._colIndex(name);

    if (arguments.length === 1) {
      if (index < 0)
        return null;
      else
        return recycle(this.columns[index], this.effectiveLength);
    }

    if (index < 0) {
      index = this.colnames.length;
      this.colnames.push(name);
    }
    this.columns[index] = asArray(values);
    this.colstrict[index] = !!strict;

    // TODO: Validate strictness (ensure lengths match up with other stricts)

    this._updateCachedProperties();

    return this;
  }

  cbind(obj, strict) {
    Object.keys(obj).forEach((name) => {
      let coldata = obj[name];
      this.col(name, coldata);
    });
    return this;
  }

  get(row, col, missingOK) {
    if (row > this.effectiveLength)
      throw new Error("Row argument was out of bounds: " + row + " > " + this.effectiveLength);

    let colIndex = -1;
    if (typeof(col) === "undefined") {
      let rowData = {};
      this.colnames.forEach((name, i) => {
        rowData[name] = this.columns[i][row % this.columns[i].length];
      });
      return rowData;
    } else if (typeof(col) === "string") {
      colIndex = this._colIndex(col);
    } else if (typeof(col) === "number") {
      colIndex = col;
    }
    if (colIndex < 0 || colIndex > this.columns.length) {
      if (missingOK)
        return void 0;
      else
        throw new Error("Unknown column index: " + col);
    }

    return this.columns[colIndex][row % this.columns[colIndex].length];
  }

  nrow() {
    return this.effectiveLength;
  }
}
