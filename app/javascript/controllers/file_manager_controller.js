import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String, uploadUrl: String };


  connect() {
    this.sortable = new Sortable(this.element, {
      animation: 150,
      onEnd: () => this.saveOrder(),
      swapThreshold: 0.8,
      direction: "vertical",
    });

    console.log(this)

    this.dropzone = document.querySelector(".dropzone");
    this.fileInput = document.createElement("input");
    this.fileInput.type = "file";
    this.fileInput.multiple = true;
    this.fileInput.addEventListener("change", () => this.uploadFiles(this.fileInput.files));

    this.dropzone.addEventListener("dragover", e => {
      e.preventDefault();
      this.dropzone.classList.add("hover");
    });
    this.dropzone.addEventListener("dragleave", () => this.dropzone.classList.remove("hover"));
    this.dropzone.addEventListener("drop", e => this.handleDrop(e));
    this.dropzone.addEventListener("click", () => this.fileInput.click());
  }

  saveOrder() {
    const ids = Array.from(this.element.querySelectorAll("li")).map(li => li.dataset.id)
    fetch(this.urlValue, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.getMetaValue("csrf-token") },
      body: JSON.stringify({ order: ids })
    });
  }

  handleDrop(e) {
    e.preventDefault();
    this.dropzone.classList.remove("hover");
    if (e.dataTransfer.files.length > 0) {
      this.uploadFiles(e.dataTransfer.files)
    };
  };

  uploadFiles(files) {
    const formData = new FormData()
    Array.from(files).forEach(file => formData.append("files[]", file));

    fetch(this.uploadUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": this.getMetaValue("csrf-token") },
      body: formData
    })
      .then(res => res.text())
      .then(html => {
        this.element.outerHTML = html
        this.connect()
      });
  };

  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element?.getAttribute("content");
  };
}
// import { Controller } from "@hotwired/stimulus"
// import Sortable from "sortablejs"

// export default class extends Controller {
//   static values = { url: String, uploadUrl: String };


//   connect() {
//     new Sortable(element, {
//       animation: 150,
//       onEnd: () => saveOrder()
//     });

//     console.log(this)

//     const dropzone = document.querySelector(".dropzone");
//     const fileInput = document.createElement("input");
//     fileInput.type = "file";
//     fileInput.multiple = true;
//     fileInput.addEventListener("change", () => uploadFiles(fileInput.files));

//     dropzone.addEventListener("dragover", e => {
//       e.preventDefault();
//       dropzone.classList.add("hover");
//     });
//     dropzone.addEventListener("dragleave", () => dropzone.classList.remove("hover"));
//     dropzone.addEventListener("drop", e => handleDrop(e));
//     dropzone.addEventListener("click", () => fileInput.click());
//   }

//   saveOrder() {
//     const ids = Array.from(this.element.querySelectorAll("li")).map(li => li.dataset.id)
//     fetch(urlValue, {
//       method: "PATCH",
//       headers: { "Content-Type": "application/json", "X-CSRF-Token": this.getMetaValue("csrf-token") },
//       body: JSON.stringify({ order: ids })
//     });
//   }

//   handleDrop(e) {
//     e.preventDefault();
//     dropzone.classList.remove("hover");
//     if (e.dataTransfer.files.length > 0) {
//       uploadFiles(e.dataTransfer.files)
//     };
//   };

//   uploadFiles(files) {
//     const formData = new FormData()
//     Array.from(files).forEach(file => formData.append("files[]", file));

//     fetch(uploadUrlValue, {
//       method: "POST",
//       headers: { "X-CSRF-Token": getMetaValue("csrf-token") },
//       body: formData
//     })
//       .then(res => res.text())
//       .then(html => {
//         element.outerHTML = html
//         connect()
//       });
//   };

//   getMetaValue(name) {
//     const element = document.head.querySelector(`meta[name="${name}"]`)
//     return element?.getAttribute("content");
//   };
// }