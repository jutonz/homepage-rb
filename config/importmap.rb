# Pin npm packages by running ./bin/importmap

pin "application"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/util", under: "util"

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/activestorage", to: "@rails--activestorage.js" # @8.0.201
pin "just-debounce" # @1.1.0
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
