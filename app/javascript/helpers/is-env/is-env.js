export const isDev = process.env.NODE_ENV === "development"
export const isTest = process.env.NODE_ENV === "test"
export const isProd = !isDev && !isTest
export const isDebug = !!process.env.DEBUG

export const isEnv = (value) => value === process.env.NODE_ENV

export const isDebugOrEnv = (value) => isDebug || isEnv(value)
