import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";
import Dropzone from "dropzone";

Dropzone.autoDiscover = false;

function getMetaValue(name) {
  const element = findElement(document.head, `meta[name="${name}"]`);
  if (element) {
    return element.getAttribute("content");
  }
}

function findElement(root, selector) {
  if (typeof root == "string") {
    selector = root;
    root = document;
  }
  return root.querySelector(selector);
}

function removeElement(el) {
  if (el && el.parentNode) {
    el.parentNode.removeChild(el);
  }
}

function insertAfter(el, referenceNode) {
  return referenceNode.parentNode.insertBefore(el, referenceNode.nextSibling);
}

export default class extends Controller {
  static targets = ["input", "previewsContainer"]

  connect() {
    this.dropzone = createDropzone(this);
    this.hideFileInput();
    this.bindEvents();
  };

  hideFileInput() {
    this.inputTarget.style.display = "none";
    this.inputTarget.disabled = true;
  };

  bindEvents() {
    this.dropzone.on("addedfile", (file) => {
      if (!/^image\//.test(file.type)) {
        file.previewElement?.classList.add("dz-non-image");
        file.previewElement?.querySelector(".dz-image")?.remove();
      }
      setTimeout(() => {
        file.accepted && createDirectUploadController(this, file).start();
      });

    });

    this.dropzone.on("processing", (file) => {
      const removeLink = findElement(file.previewTemplate, ".dz-remove");
      if (removeLink) removeLink.textContent = "Cancel upload";
    });

    this.dropzone.on("removedfile", (file) => {
      file.controller && removeElement(file.controller.hiddenInput);
    });

    this.dropzone.on("canceled", (file) => {
      file.controller && file.controller.xhr.abort();
    })

    this.dropzone.on("success", (file) => {
      const progressWrap = findElement(file.previewTemplate, ".dz-progress");
      if (progressWrap) progressWrap.style.display = "none";

      const nameEl = findElement(file.previewTemplate, "[data-dz-name]");
      if (nameEl && !nameEl.querySelector(".dz-check")) {
        const check = document.createElement("span");
        check.className = "dz-check";
        check.textContent = " ✅";
        nameEl.appendChild(check);
      }

      // change remove link label
      const removeLink = findElement(file.previewTemplate, ".dz-remove");
      if (removeLink) removeLink.textContent = "Remove file";
    });
  };

  get previewsContainer() {
    return this.previewsContainerTarget;
  };

  get headers() {
    return { "X-CSRF-Token": getMetaValue("csrf-token") };
  };

  get url() {
    return this.inputTarget.dataset.directUploadUrl;
  };

  get acceptedFiles() {
    return this.data.get("acceptedFiles");
  };

  get maxFiles() {
    return this.data.get("maxFiles") || 100;
  };

  get maxFileSize() {
    return this.data.get("maxFileSize") || 1000;
  };

  get form() {
    return this.element.closest("form");
  };

  get submitButton() {
    return findElement(this.form, "input[type=submit], button[type=submit]");
  };

  removeExisting(event) {
    this.removeElement(event.target.parentNode)
  };
}

class DirectUploadController {
  constructor(source, file) {
    this.directUpload = createDirectUpload(file, source.url, this);
    this.source = source;
    this.file = file;
  };

  start() {
    this.file.controller = this;
    this.hiddenInput = this.createHiddenInput();
    this.directUpload.create((error, attributes) => {
      if (error) {
        removeElement(this.hiddenInput);
        this.emitDropzoneError(error);
      } else {
        this.hiddenInput.value = attributes.signed_id;
        this.emitDropzoneSuccess();
      }
    })
  }

  createHiddenInput() {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = this.source.inputTarget.name;
    insertAfter(input, this.source.inputTarget);
    return input;
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.bindProgressEvent(xhr);
    this.emitDropzoneUploading();
  }

  bindProgressEvent(xhr) {
    this.xhr = xhr;
    this.xhr.upload.addEventListener("progress", (event) => {
      this.uploadRequestDidProgress(event)
    });
  }

  uploadRequestDidProgress(event) {
    const progress = (event.loaded / event.total) * 100;
    const progressBar = findElement(this.file.previewTemplate, ".dz-upload");
    progressBar.style.width = `${progress}%`;
  }

  emitDropzoneUploading() {
    this.file.status = Dropzone.UPLOADING;
    const progressBar = findElement(this.file.previewTemplate, ".dz-upload");
    progressBar.style = "height:12px; background-color:#2b55ca; border: solid white 1px; display: block; border-radius: 6px";
    this.source.dropzone.emit("processing", this.file);
  }

  emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR;
    this.source.dropzone.emit("error", this.file, error);
    this.source.dropzone.emit("complete", this.file);
  }

  emitDropzoneSuccess() {
    this.file.status = Dropzone.SUCCESS;
    this.source.dropzone.emit("success", this.file);
    this.source.dropzone.emit("complete", this.file);
  }
}

function createDirectUploadController(source, file) {
  return new DirectUploadController(source, file);
}

function createDirectUpload(file, url, controller) {
  return new DirectUpload(file, url, controller);
}

function createDropzone(controller) {
  let dropzone = new Dropzone(controller.element, {
    // url: controller.url,
    // headers: controller.headers,
    url: "#",
    maxFilesize: controller.maxFileSize,
    maxFiles: controller.maxFiles,
    acceptedFiles: controller.acceptedFiles,
    previewsContainer: controller.previewsContainer,
    addRemoveLinks: true,
    uploadMultiple: true,
    autoQueue: false,
    autoProcessQueue: false,
    parallelUploads: 1,
  });

  return dropzone;
}