import path from "path"

export const projectRoot = path.resolve(__dirname, "../../../")
export const appRoot = path.resolve(projectRoot, "app")
export const srcRoot = path.resolve(appRoot, "javascript")
export const testRoot = path.resolve(appRoot, "test")
export const jstestRoot = path.resolve(testRoot, "javascript")
