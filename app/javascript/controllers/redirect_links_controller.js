// app/javascript/controllers/links_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["container", "template", "row"]
  static values = { handle: String }

  connect() {
    this.ensureDraftRow();

    this.element.closest("form").addEventListener("submit", () => {
      this.cleanupEmptyDrafts();
    });

    this.sortable = new Sortable(this.containerTarget, {
      animation: 150,
      handle: this.hanldeValue || ".link-row",
      onEnd: () => this.reindex()
    });

    const delBtn = this.containerTarget.querySelector(".remove_redirect-set");

    delBtn.style.display = "none";
  }

  add() {
    const draft = this.containerTarget.querySelector(".link-row[data-draft='true']");
    const delBtns = this.containerTarget.querySelectorAll(".remove_redirect-set")
    if (draft && this.rowHasAnyInput(draft)) this.lock(draft);
    if (delBtns.length >= 1) {delBtns[0].style.display = "block" }
    this.ensureDraftRow();
    this.reindex();
  }

  remove(event) {
    const row = event.target.closest(".link-row");
    const delBtns = this.containerTarget.querySelectorAll(".remove_redirect-set")
    const destroy = row.querySelector('input[name*="[_destroy]"]');
    if (destroy) { destroy.checked = true };
    if (delBtns.length <= 2) {
      delBtns[0].style.display = "none"

    }
    row.style.display = "none";
    this.reindex();
  }

  maybeCommit(event) {
    const row = event.target.closest(".link-row");
    if (!row || row.dataset.draft !== "true") return;
    if (this.rowHasAnyInput(row)) {
      this.lock(row);
      this.ensureDraftRow();
      this.reindex();
    }
  }

  ensureDraftRow() {
    if (this.containerTarget.querySelector(".link-row[data-draft='true']")) return;
    const row = this.buildRow();
    row.dataset.draft = "true";
    this.containerTarget.appendChild(row);
    const first = row.querySelector("input[name*='[label]'], input[name*='[text]'], input[name*='[url]']");
    first && first.focus();
  }

  buildRow() {
    const frag = this.templateTarget.content.cloneNode(true);
    const newKey = `${Date.now()}`;
    frag.querySelectorAll("[name], [id], label[for]").forEach(el => {
      if (el.name) el.name = el.name.replace(/NEW_RECORD/g, newKey);
      if (el.id) el.id = el.id.replace(/NEW_RECORD/g, newKey);
      if (el.getAttribute("for")) el.setAttribute("for", el.getAttribute("for").replace(/NEW_RECORD/g, newKey));
    });
    const row = frag.querySelector(".link-row");
    return row;
  }

  lock(row) {
    row.dataset.draft = "false";
    row.querySelectorAll("input, textarea, select").forEach(el => {
      const name = el.name || ""
      if (name.includes("[_destroy]") || name.includes("[position]")) return;
      if (el.type === "hidden" ) return;
      el.readOnly = true;
      el.classList.add("is-locked");
    });
  }

  rowHasAnyInput(row) {
    const label = row.querySelector("input[name*='[label]'], input[name*='[text]']");
    const url = row.querySelector("input[name*='[url]']");
    return !!((label && label.value.trim()) || (url && url.value.trim()));
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

  cleanupEmptyDrafts() {
    const drafts = this.containerTarget.querySelectorAll(".link-row[data-draft='true']");

    drafts.forEach(row => {
      if (!this.rowHasAnyInput(row)) {
        row.remove();
      }
    });
  }

  disconnect() {
    this.sortable && this.sortable.destroy();
  }
}
