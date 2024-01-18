# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/src", under: "src", to: "src"
pin "trix", to: "https://ga.jspm.io/npm:trix@2.0.8/dist/trix.esm.min.js", preload: true
pin "@rails/actiontext", to: "actiontext.js"
# subsequent modules are pinned here to be used in specific form partials where they're used/needed
pin "admin", preload: true
pin "archive_items_form", preload: true
pin "user_registration_form", preload: true