export function railsEnv() {
  return document
    .querySelector("meta[name=rails_env]")
    ?.getAttribute("content")
}

export function isTest() {
  return railsEnv() === "test"
}
