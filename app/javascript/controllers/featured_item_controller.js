import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const featuredItemInput = document.querySelector(".featured-item-select")
    featuredItemSelectUI(featuredItemInput)

    function featuredItemSelectUI(input) {
      input.style.backgroundColor = input.value === "true" ? "#e8dc5a" : "#313131";
      input.addEventListener("change", function () {
        input.style.backgroundColor = input.value === "true" ? "#e8dc5a" : "#313131";
        input.style.color = input.value === "true" ? "black" : "white";
      })
    }
  }
}