import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect(){
    this.redirectSelectUI(this.selectTarget)
  }

  redirectSelectUI(input) {
    const linksList = document.querySelector("#redirect-links-list")
    const filesList = document.querySelector("#content-files-list")
    linksList.style.display = "none";
    input.addEventListener("change", function () {

      if (input.value === "true") {
        linksList.style.display = "block";
        linksList.disabled = false;

        filesList.style.display = "none";
        filesList.disabled = true;
      } else {
        linksList.style.display = "none";
        linksList.disabled = true;

        filesList.style.display = "block";
        filesList.disabled = false;
      }
    })
  }
}