import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const redirectSelectInput = document.querySelector("#archive_item_content_redirect")
    redirectSelectUI(redirectSelectInput)

    function redirectSelectUI(input) {
      const selectorList = document.querySelector("#content-files-list-el")
      input.addEventListener("change", function () {
        if (input.value === true) {

        }
      })
    }
  }

}