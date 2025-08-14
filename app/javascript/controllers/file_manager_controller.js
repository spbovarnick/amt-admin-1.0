import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String, uploadUrl: String };


  connect() {
    this.sortable = new Sortable(this.element, {
      animation: 150,
      onEnd: () => this.saveOrder()
    });

    this.dropzone = this.element.parentElement.querySelector(".dropzone");
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