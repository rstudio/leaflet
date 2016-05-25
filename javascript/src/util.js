export function log(message) {
  /* eslint-disable no-console */
  if (console && console.log) console.log(message);
  /* eslint-enable no-console */
}

export function recycle(values, length, inPlace) {
  if (length === 0 && !inPlace)
    return [];

  if (!(values instanceof Array)) {
    if (inPlace) {
      throw new Error("Can't do in-place recycling of a non-Array value");
    }
    values = [values];
  }
  if (typeof(length) === "undefined")
    length = values.length;

  let dest = inPlace ? values : [];
  let origLength = values.length;
  while (dest.length < length) {
    dest.push(values[dest.length % origLength]);
  }
  if (dest.length > length) {
    dest.splice(length, dest.length - length);
  }
  return dest;
}

export function asArray(value) {
  if (value instanceof Array)
    return value;
  else
    return [value];
}
