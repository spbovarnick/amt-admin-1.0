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
        const posterRow = document.querySelector("#poster-image-row");

        linksList.style.display = "block";
        linksList.disabled = false;

        filesList.style.display = "none";
        filesList.disabled = true;

        if (input.value !== "film" || input.value !== "audio" || input.value !== "article" || input.value !== "printed material" && posterRow){
          posterRow.classList.remove("hidden");
        }

      } else {
        const posterRow = document.querySelector("#poster-image-row");

        linksList.style.display = "none";
        linksList.disabled = true;

        filesList.style.display = "block";
        filesList.disabled = false;

        if (input.value !== "film" || input.value !== "audio" || input.value !== "article" || input.value !== "printed material" && posterRow) {
          posterRow.classList.add("hidden");
        }
      }
    })
  }
}