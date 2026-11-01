// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()


import "trix"
import "@rails/actiontext"

// Turbo morphs a 422 re-render of the same page. The morph removes the
// toolbar that Trix builds in the browser and empties the editor.
document.addEventListener("turbo:before-morph-element", (event) => {
  if (event.target.matches?.("trix-editor, trix-toolbar")) {
    event.preventDefault()
  }
})
