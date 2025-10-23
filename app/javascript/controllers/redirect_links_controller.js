// app/javascript/controllers/links_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["container", "template"]

  connect() {
    console.log(this.containerTarget)
    // Optional: drag to reorder, then write positions
    this.sortable = new Sortable(this.containerTarget, {
      animation: 150,
      handle: ".link-row", // or add a grab handle
      onEnd: () => this.reindex()
    })
  }

  add() {
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now().toString())
    this.containerTarget.insertAdjacentHTML("beforeend", html)
    this.reindex()
  }

  remove(event) {
    const row = event.target.closest(".link-row")
    const destroy = row.querySelector('input[name*="[_destroy]"]')
    if (destroy) { destroy.checked = true }
    row.style.display = "none"
    this.reindex()
  }

  reindex() {
    // assign sequential positions for all visible rows
    Array.from(this.containerTarget.querySelectorAll(".link-row"))
      .filter(row => row.style.display !== "none")
      .forEach((row, idx) => {
        const pos = row.querySelector('input[name*="[position]"]')
        if (pos) pos.value = idx + 1
      })
  }
}
