export function sleepAsync(time) {
  if(time === undefined) time = 0
  return new Promise(r => setTimeout(r, Math.max(+time, 0)))
}
