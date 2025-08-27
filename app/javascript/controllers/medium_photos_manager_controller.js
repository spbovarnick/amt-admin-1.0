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


    this.dropzone = document.querySelector(".mp-dropzone");
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
    const ids = Array.from(this.element.querySelectorAll("li[data-id]")).map(li => li.dataset.id);

    if (this.hasUrlValue) {
      fetch(this.urlValue, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.getMetaValue("csrf-token") },
        body: JSON.stringify({ order: ids })
      });
    } else {
      const hiddenOrderInput = document.querySelector("#medium-photos-order");
      hiddenOrderInput.value = JSON.stringify(ids);
    }
  };

  handleRemove(e) {
    e.preventDefault();
    e.target.parentElement.remove();
  }

  handleDrop(e) {
    e.preventDefault();
    this.dropzone.classList.remove("hover");
    if (e.dataTransfer.files.length > 0) {
      this.uploadFiles(e.dataTransfer.files);
    };
  }

  uploadFiles(files) {
    const imageFiles = Array.from(files).filter(file => file.type.startsWith("image/"));

    if (imageFiles.length === 0) {
      alert("Only image files are allowed as medium photos.");
      return;
    }

    if (this.hasUploadUrlValue)  {
      const formData = new FormData();
      Array.from(imageFiles).forEach(file => formData.append("files[]", file));

      fetch(this.uploadUrlValue, {
        method: "POST",
        headers: { "X-CSRF-Token": this.getMetaValue("csrf-token") },
        body: formData,
      })
        .then(res => res.text())
        .then(html => {
          this.element.outerHTML = html
          this.connect()
        });
    } else {
      const input = document.querySelector("#new-medium-photos-input");
      const dataTransfer = new DataTransfer();

      Array.from(input.files).forEach(file => dataTransfer.items.add(file));
      Array.from(imageFiles).forEach(file => dataTransfer.items.add(file));
      input.files = dataTransfer.files;

      Array.from(imageFiles).forEach(file => {
        const li = document.createElement("li");
        li.dataset.id = file.name;
        li.classList.add("preview-thumbs");

        const reader = new FileReader();
        reader.onload = e => {
          li.innerHTML = `
            <div class="removable-image-container">
              <span class="clear_one_attachment_button" data-action="click->medium-photos-manager#handleRemove">X Remove File</span>
              <img src=${e.target.result} class="admin-form-image" />
            </div>
          `;
        };
        reader.readAsDataURL(file);
        this.element.insertBefore(li, this.dropzone);
      });

      this.saveOrder();
    };
  };

  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`);
    return element?.getAttribute("content");
  }
}