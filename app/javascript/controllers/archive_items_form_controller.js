import { Controller }  from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const mediumInput = document.querySelector("#archive_item_medium");

    showOrHidePoster(mediumInput);
    trackMedium(mediumInput);
    // REDUNDANT JS, SEE BELOW
    // listenForClear();

    function trackMedium(input) {
      input.addEventListener("change", function () {
        showOrHidePoster(input);
      });
    }

    function showOrHidePoster(input) {
      const posterRow = document.querySelector("#poster-image-row");

      if (input.value === "film" || input.value === "audio" || input.value == "article" || input.value == "printed material") {
        posterRow.classList.remove("hidden");
      } else {
        posterRow.classList.add("hidden");
      }
    }

    // REDUNDANT JS -> replaced by native turbo rails delete, saving for posterity, downroad UX updates
    // function listenForClear() {
    //   const allClearButtons = document.querySelectorAll(
    //     ".clear_attachement_button"
    //   );
    //   allClearButtons.forEach((button) => {
    //     const uploadInput = document.querySelector(
    //       `#${button.dataset.baseInputId}`
    //     );
    //     const input = document.querySelector(`#${button.dataset.input}`);
    //     const preview = document.querySelector(`#${button.dataset.preview}`);

    //     uploadInput.addEventListener("change", function () {
    //       // prevent attachement from being purged if new item is uploaded
    //       input.value = "false";
    //     });

    //     button.addEventListener("click", function () {
    //       // pass "true" to controller, so it knows to purge the attachement
    //       input.value = "true";
    //       // hide the preview
    //       preview.style.display = "none";
    //       button.style.display = "none";
    //     });
    //   });
    // }
  }
}