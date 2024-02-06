document.addEventListener("turbo:load", function () {
  const mediumInput = document.querySelector("#archive_item_medium");
  if (!mediumInput) {
    return;
  }
  showOrHidePoster(mediumInput);
  trackMedium(mediumInput);
  listenForClear();
});

function trackMedium(input) {
  input.addEventListener("change", function () {
    showOrHidePoster(input);
  });
}

function showOrHidePoster(input) {
  const posterRow = document.querySelector("#poster-image-row");

  if (input.value === "film" || input.value === "audio" || input.value == "article" || input.value == "printed material" ) {
    posterRow.classList.remove("hidden");
  } else {
    posterRow.classList.add("hidden");
  }
}

function listenForClear() {
  const allClearButtons = document.querySelectorAll(
    ".clear_attachement_button"
  );
  allClearButtons.forEach((button) => {
    const uploadInput = document.querySelector(
      `#${button.dataset.baseInputId}`
    );
    const input = document.querySelector(`#${button.dataset.input}`);
    const preview = document.querySelector(`#${button.dataset.preview}`);

    uploadInput.addEventListener("change", function () {
      // prevent attachement from being purged if new item is uploaded
      input.value = "false";
    });

    button.addEventListener("click", function () {
      // pass "true" to controller, so it knows to purge the attachement
      input.value = "true";
      // hide the preview
      preview.style.display = "none";
      button.style.display = "none";
    });
  });
}
