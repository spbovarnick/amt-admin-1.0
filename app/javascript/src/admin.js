// Run function after dom has loaded.
document.addEventListener("turbo:load", function () {
  // tagInput();
  listenForClearSearch();
});

// Listen for clicking clear on search forms
function listenForClearSearch() {
  const ALL_BUTTONS = document.querySelectorAll(".js-search-clear");
  ALL_BUTTONS?.forEach((button) => {
    button.addEventListener("click", (event) => {
      event.preventDefault();
      const redirectPath = event.target.dataset.clearPath;
      window.location.href = redirectPath;
    });
  });
}
