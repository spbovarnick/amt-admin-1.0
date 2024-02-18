// // Run function after dom has loaded.
// window.addEventListener("DOMContentLoaded", function () {
//   const isArchiveItemForm = document.querySelector(".archive-item-form");
//   const isPageForm = document.querySelector(".page-form");
//   const draftInput = document.querySelector(".draft-select");
//   if (isArchiveItemForm || isPageForm) {
//     draftSelectUI(draftInput);
//   }
// });

// function draftSelectUI(input) {
//   input.style.backgroundColor = input.value === "true" ? "#b74e55" : "#6da47c";
//   input.addEventListener("change", function () {
//     input.style.backgroundColor = input.value === "true" ? "#b74e55" : "#6da47c";
//     input.style.color = input.value === "true" ? "white" : "black";
//   });
// }