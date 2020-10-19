export const images = require.context('./', true, /[^.]+\.(ico|png|svg|jpg|gif|webp)/)
export const imagePath = (name) => images(name, true)
