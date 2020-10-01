export const isFunction =
  (x) =>
    /\[object (Async)?Function\]/.test(Object.prototype.toString.call(x))

export default isFunction
