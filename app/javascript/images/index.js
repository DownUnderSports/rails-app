export const images = require.context('./', true, /[^.]+\.(ico|png|svg|jpg|gif)/)
export const imagePath = (name) => images(name, true)
