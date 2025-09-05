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

    this.dropzone = document.querySelector(".cf-dropzone");
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
        headers: {
          "X-CSRF-Token": this.getMetaValue("csrf-token"),
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ order: ids })
      });
    } else {
      const hiddenOrderInput = document.querySelector("#content-files-order");
      hiddenOrderInput.value = JSON.stringify(ids);
    }
  }

  handleRemove(e) {
    e.preventDefault();
    e.target.parentElement.remove();
  }

  handleDrop(e) {
    e.preventDefault();
    this.dropzone.classList.remove("hover");
    if (e.dataTransfer.files.length > 0) {
      this.uploadFiles(e.dataTransfer.files)
    };
  };

  uploadFiles(files) {
    if (this.hasUploadUrlValue) {
      const formData = new FormData();
      Array.from(files).forEach(file => formData.append("files[]", file))

      fetch(this.uploadUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.getMetaValue("csrf-token")
        },
        body: formData
      })
        .then(res => res.text())
        .then(html => {
          this.element.outerHTML = html;
          this.connect();
        })
    } else {
      const input = document.querySelector("#new-content-files-input");
      const dataTransfer = new DataTransfer();

      Array.from(input.files).forEach(file => dataTransfer.items.add(file));
      Array.from(files).forEach(file => dataTransfer.items.add(file));
      input.files = dataTransfer.files;

      Array.from(files).forEach(file => {
        const li = document.createElement("li");
        li.dataset.id = file.name;
        li.classList.add("preview-thumbs");

        if (file.type.startsWith("image/")) {
          const reader = new FileReader();
          reader.onload = e => {
            li.innerHTML = `
              <div class="removable-image-container">
                <span class="clear_one_attachment_button" data-action="click->content-files-manager#handleRemove">X Remove File</span>
                <img src=${e.target.result} class="admin-form-image" />
              </div>
            `;
          };
          reader.readAsDataURL(file);
        } else {
          li.innerHTML = `
            <div class="no-thumbnail-content-file">
              <a
                href="${URL.createObjectURL(file)}"
                target="_blank"
                class="download-link"
              >View ${file.name}</a>
              <span class="no_thumbnail_new_record_del_one download-link" data-action="click->content-files-manager#handleRemove">X Remove File</span>
            </div>
          `;
        };
        this.element.insertBefore(li, this.dropzone);
      });

      this.saveOrder();
    };
  };

  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element?.getAttribute("content");
  };
}