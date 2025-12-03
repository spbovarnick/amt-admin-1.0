import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String, hiddenInput: String };


  connect() {
    this.saveOrder = this.debounce(this.saveOrder.bind(this), 300);
    this.sortable = new Sortable(this.element, {
      animation: 150,
      onEnd: () => this.saveOrder(),
      swapThreshold: 0.8,
      direction: "vertical",
      draggable: "li",
    });
  }

  debounce(fn, wait) {
    let t;
    return (...args) => {
      clearTimeout(t);
      t = setTimeout(() => fn(...args), wait);
    }
  }

  async saveOrder() {
    const ids = Array.from(this.element.querySelectorAll("li[data-id]")).map(li => li.dataset.id);

    if (this.hasUrlValue) {
      const res = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.getMetaValue("csrf-token"),
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ order: ids })
      });
      if (!res.ok) {
        console.error("Failed to save order");
      }
    } else {
      const hiddenOrderInput = document.querySelector(this.hiddenInputValue);
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

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy();
      this.sortable = null;
    }
  }
}