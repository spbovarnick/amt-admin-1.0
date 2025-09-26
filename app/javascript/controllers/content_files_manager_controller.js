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

  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element?.getAttribute("content");
  };
}