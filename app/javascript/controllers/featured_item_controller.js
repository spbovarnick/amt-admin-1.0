import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const featuredItemInput = document.querySelector(".featured-item-select")
    featuredItemSelectUI(featuredItemInput)
    console.log('fuck')

    function featuredItemSelectUI(input) {
      input.style.backgroundColor = input.value === "true" ? "#e8dc5a" : "#313131";
      input.addEventListener("change", function () {
        input.style.backgroundColor = input.value === "true" ? "#e8dc5a" : "#313131";
      })
    }
  }
}