import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect(){

  }

  redirectSelectUI(input) {
    const selectorList = document.querySelector("")
    input.addEventListener("change", function () {
      if (input.value === true) {

      }
    })
  }
}