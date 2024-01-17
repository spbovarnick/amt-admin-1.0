document.addEventListener("turbo:load", function () {
  listenForClear();
});

function listenForClear() {
  const clearButton = document.querySelector(".clear_attachement_button");
  const uploadInput = document.querySelector(
    `#${clearButton.dataset.baseInputId}`
  );
  const input = document.querySelector(`#${clearButton.dataset.input}`);
  const preview = document.querySelector(`#${clearButton.dataset.preview}`);

  uploadInput.addEventListener("change", function () {
    // prevent attachement from being purged if new item is uploaded
    input.value = "false";
  });

  clearButton.addEventListener("click", function () {
    // pass "true" to controller, so it knows to purge the attachement
    input.value = "true";
    // hide the preview
    preview.style.display = "none";
    clearButton.style.display = "none";
  });
}
