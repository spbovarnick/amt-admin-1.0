import { Controller } from "@hotwired/stimulus";

export default class extends Controller { 
  connect() {
    toggleAdminFields();
    toggleArchivistFields();
    passwordMatch();

    // selects and disables fields based on admin select true or false
    function toggleAdminFields() {
      const adminInput = document.querySelector("#user_admin");
      const boardMemberSelect = document.querySelector("#user_board_member");
      const archivistSelect = document.querySelector("#user_archivist");
      const pageInput = document.querySelector("#user_page");
      const nilValue = pageInput.querySelector("#nil-value");

      adminInput.value === "true" ? disabledFields(adminInput, boardMemberSelect, archivistSelect, pageInput) : null;

      adminInput.addEventListener("change", (event) => {
        if (event.target.value === "true") {
          disabledFields(adminInput, boardMemberSelect, archivistSelect, pageInput);
        } else if (event.target.value === "false") {
          boardMemberSelect.querySelector("option[value='false']").selected = true;
          boardMemberSelect.disabled = false;
          archivistSelect.querySelector("option[value='false']").selected = true;
          archivistSelect.disabled = false;
          nilValue.selected = true;
          if (archivistSelect.value === "false") {
            pageInput.disabled = true;
          }
        }
      });
    }

    function toggleArchivistFields() {
      const archivistSelect = document.querySelector("#user_archivist");
      const pageInput = document.querySelector("#user_page");
      const adminInput = document.querySelector("#user_admin");

      // controls page select access based on archivist/admin role assignment
      archivistSelect.value === "false" ? pageInput.disabled = true : null
      archivistSelect.addEventListener("change", (event) => {
        // if user not archivist, no page access granted, :page => nil
        if (event.target.value === "false") {
          pageInput.disabled = true;
          pageInput.querySelector("#nil-value").selected = true;
        } else {
          pageInput.disabled = false;
        }
      });
    }

    function disabledFields(adminInput, boardMemberSelect, archivistSelect, pageInput) {
      const globalOption = pageInput.querySelector("option[value='global']");
      if (adminInput.value === "true") {
        boardMemberSelect.querySelector("option[value='true']").selected = true;
        boardMemberSelect.disabled = true;
        archivistSelect.querySelector("option[value='true']").selected = true;
        archivistSelect.disabled = true;
        globalOption.selected = true;
        pageInput.disabled = true;
      }
    }

    // UI to mitigate error encounters when entering passwords
    function passwordMatch() {
      const password = document.getElementById("user_password");
      const pwdField = document.querySelector(".password-initial")
      const passwordConfirm = document.getElementById("user_password_confirmation");
      const pwdConfirmField = document.querySelector(".password-confirm");
      const matchWarning = document.createElement("div");
      matchWarning.innerText = "*Passwords must match";
      matchWarning.style.color = "red";
      matchWarning.classList.add("match-warning")
      passwordConfirm.disabled = true;
      const matchSuccess = document.createElement("div");
      matchSuccess.innerText = "Passwords match!";
      matchSuccess.style.color = "green";
      matchSuccess.classList.add("match-success");
      const lengthWarning = document.createElement("div");
      lengthWarning.innerText = "*Password must be at least 6 characters long";
      lengthWarning.style.color = "red";
      lengthWarning.classList.add("length-warning");

      // password_confirmation disabled unless password field populated
      // prevents unintentional errors when updating account w/o pwd changes
      password.addEventListener("input", (event) => {
        const warning = document.querySelector(".match-warning");
        const lengthAlert = document.querySelector(".length-warning")
        if (event.target.value.length < 6) {
          !lengthAlert ? pwdField.append(lengthWarning) : null;
        } else if (event.target.value.length >= 6) {
          lengthAlert ? lengthAlert.remove() : null;
        }
        event.target.value.length === 0 && lengthAlert ? lengthAlert.remove() : null;
        if (event.target.value.length === 0 && passwordConfirm.value.length === 0) {
          passwordConfirm.disabled = true;
          passwordConfirm.value.length === 0 ? passwordConfirm.style.border = "" : null;
          warning ? warning.remove() : null;
        } else {
          passwordConfirm.disabled = false;
          !warning ? pwdConfirmField.append(matchWarning) : null;
          passwordConfirm.style.border = "1px solid red";
        }
      });

      passwordConfirm.addEventListener("input", (event) => {
        const warning = document.querySelector(".match-warning");
        const success = document.querySelector(".match-success");
        password.value.length === 0 && event.target.value.length === 0 ? passwordConfirm.disabled = true : null;

        if (password.value.length > 0 && event.target.value !== password.value) {
          passwordConfirm.style.border = "1px solid red";
          !warning ? pwdConfirmField.append(matchWarning) : null;
          success ? success.remove() : null;
        } else if (password.value.length > 0 && event.target.value === password.value) {
          passwordConfirm.style.border = "1px solid green";
          warning ? warning.remove() : null;
          !success ? pwdConfirmField.append(matchSuccess) : null
        } else if (password.value.length === 0) {
          passwordConfirm.style.border = "";
          warning ? warning.remove() : null;
          success ? success.remove() : null;
        }
      });
    }
  }
}