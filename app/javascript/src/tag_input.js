// Run function after dom has loaded.
document.addEventListener("turbo:load", function () {
  const isArchiveItemForm = document.querySelector(".archive-item-form")
  const isPageCarouselForm = document.querySelector(".page-carousel-slide-form")
  if (isArchiveItemForm || isPageCarouselForm) {
    tagInput();
  }
});

function tagInput() {
  const userPageTag = document.querySelector(".user-page-tag-input") ? document.querySelector(".user-page-tag-input").innerText.trim() : null;
  const ALL_INPUTS = document.querySelectorAll(".js-tag-input");

  ALL_INPUTS.forEach((input) => {
    let currentHighlight = -1;
    let selectedValues = [];
    if (input.value) {
      selectedValues = input.value.split(", ");
    }
    if (userPageTag && input.classList.contains("archive-tags") && !selectedValues.includes(userPageTag)) {
      selectedValues.push(userPageTag)
    }
    const inputParent = input.parentNode;

    // Create searh wrapper
    const textInputWrapper = document.createElement("div");
    textInputWrapper.className = "tag-ui-text-input-wrapper";

    // listens for key events to navigate, select and exit archive_items_form dropdown menus
    textInputWrapper.addEventListener("keydown", (event) => {
      const menuEl = textInputWrapper.querySelector(".tag-ui-options-menu");
      let optionsArr = Array.from(menuEl.children).filter(
        (option) => option.style.display !== "none"
      );
      menuEl.style.display = "block";
      textInputWrapper.classList.add("--is-focused");

      if (event.key === "ArrowDown") {
        event.preventDefault();
        if (currentHighlight > -1) {
          optionsArr[currentHighlight].classList.remove("highlighted");
        }
        currentHighlight = (currentHighlight + 1) % optionsArr.length;
        optionsArr[currentHighlight].classList.add("highlighted");
        optionsArr[currentHighlight].scrollIntoView({ block: "nearest" })
      } else if (event.key === "ArrowUp") {
        event.preventDefault();
        if (currentHighlight > -1) {
          optionsArr[currentHighlight].classList.remove("highlighted");
        }
        currentHighlight = (currentHighlight - 1 + optionsArr.length) % optionsArr.length
        optionsArr[currentHighlight].classList.add("highlighted")
        optionsArr[currentHighlight].scrollIntoView({ block: "nearest" })
      } else if (event.key === "Enter" && currentHighlight >= 0) {
        event.preventDefault();
        optionsArr[currentHighlight].click()
        const wrapperEl = event.target.parentNode;
        wrapperEl.classList.remove("--is-focused");
        setTimeout(() => {
          menuEl.style.display = "none";
        }, 150); // Duration of animation
      } else if (event.key === "Escape") {
        event.preventDefault();
        const wrapperEl = event.target.parentNode;
        wrapperEl.classList.remove("--is-focused");
        const menuEl = wrapperEl.querySelector(".tag-ui-options-menu");
        setTimeout(() => {
          menuEl.style.display = "none";
        }, 150); // Duration of animation
      }
    })

    // Create search field
    const textInput = document.createElement("input");
    textInput.type = "text";
    textInput.className = "tag-ui-text-input";
    textInput.dataset.lpignore = "true";

    // Listen for focus events
    textInput.addEventListener("focus", (event) => {
      const wrapperEl = event.target.parentNode;
      const menuEl = wrapperEl.querySelector(".tag-ui-options-menu");
      menuEl.style.display = "block";
      setTimeout(() => {
        wrapperEl.classList.add("--is-focused");
      }, 10); // Nominal ammount of time
    });

    textInput.addEventListener("blur", (event) => {
      const wrapperEl = event.target.parentNode;
      wrapperEl.classList.remove("--is-focused");
      const menuEl = wrapperEl.querySelector(".tag-ui-options-menu");
      setTimeout(() => {
        menuEl.style.display = "none";
      }, 150); // Duration of animation
    });

    // Filter visibility of menu results based on input value
    textInput.oninput = function (event) {
      const wrapperEl = event.target.parentNode;
      const menuEl = wrapperEl.querySelector(".tag-ui-options-menu");

      Array.from(menuEl.children).forEach((option) => {
        if (
          option.textContent
            .toLowerCase()
            .includes(textInput.value.toLowerCase())
        ) {
          option.style.display = "block";
        } else {
          option.style.display = "none";
        }
      });
    };

    // Create options menu
    let tagOptions = input.dataset.tagOptions.split(", ").sort();
    const tagOptionsMenu = document.createElement("div");
    tagOptionsMenu.className = "tag-ui-options-menu";
    tagOptions.forEach((option) => {
      if (!selectedValues.includes(option)) {
        const optionButton = document.createElement("button");
        optionButton.className = "tag-ui-option";
        optionButton.textContent = option;

        // Listen for clicks
        optionButton.addEventListener("click", (event) => {
          event.preventDefault();
          addToTags(option, inputParent);

          // Clear input and reset filtered options
          const wrapperEl = event.target.parentNode.parentNode;
          const inputEl = wrapperEl.querySelector(".tag-ui-text-input");
          const menuEl = wrapperEl.querySelector(".tag-ui-options-menu");

          inputEl.value = "";

          Array.from(menuEl.children).forEach((option) => {
            option.style.display = "block";
          });
        });

        // Append to menu
        tagOptionsMenu.appendChild(optionButton);
      }
    });

    // Attach search and options menu to dom
    textInputWrapper.appendChild(textInput);
    textInputWrapper.appendChild(tagOptionsMenu);
    inputParent.appendChild(textInputWrapper);

    // Create div for tags
    const tagDiv = document.createElement("div");
    tagDiv.className = "tag-ui-button-wrapper";
    inputParent.appendChild(tagDiv);

    renderTags(selectedValues, tagDiv);
  });
}

function renderTags(tags, wrapperEl) {
  const userPageTag = document.querySelector(".user-page-tag-input") ? document.querySelector(".user-page-tag-input").innerText.trim() : null;
  tags.forEach((tag) => {
    const tagButton = document.createElement("button");
    tagButton.className = "tag-ui-button";
    tagButton.textContent = tag;
    tagButton.dataset.tagUiName = tag.replace(/["']/g, "");

    // Listen for clicks
    tagButton.addEventListener("click", (event) => {
      event.preventDefault();
      removeFromTags(tag, wrapperEl);
    });
    if (tag == userPageTag) {
      tagButton.disabled = true;
      tagButton.classList.add("current-user-page-tag")
    }

    wrapperEl.appendChild(tagButton);
  });
}

function addToTags(tag, parentEl) {
  const inputEl = parentEl.querySelector(".js-tag-input");
  let selectedValues = [];
  if (inputEl.value) {
    selectedValues = inputEl.value.split(", ");
  }

  // limit number of tags selectable to 1
  if (inputEl.classList.contains("restricted-input") && selectedValues.length >= 1) {
    return
  }

  // Check if tag already exists and add to input if not.
  if (!selectedValues.includes(tag)) {
    selectedValues.push(tag);
    if (selectedValues.length > 1) {
      inputEl.value = selectedValues.join(", ");
    } else {
      inputEl.value = selectedValues[0];
    }

    // Add button
    const wrapperEl = parentEl.querySelector(".tag-ui-button-wrapper");
    const tagButton = document.createElement("button");
    tagButton.className = "tag-ui-button";
    tagButton.textContent = tag;
    tagButton.dataset.tagUiName = tag.replace(/["']/g, "");

    // Listen for clicks
    tagButton.addEventListener("click", (event) => {
      event.preventDefault();
      removeFromTags(tag, wrapperEl);
    });

    wrapperEl.appendChild(tagButton);
  }
}

function removeFromTags(tag, wrapperEl) {
  const parentEl = wrapperEl.parentNode;
  const inputEl = parentEl.querySelector(".js-tag-input");
  const selectedValues = inputEl.value.split(", ");
  const index = selectedValues.indexOf(tag);

  if (index > -1) {
    selectedValues.splice(index, 1);
  }

  inputEl.value = selectedValues.join(", ");

  // Remove button
  const buttonEl = wrapperEl.querySelector(
    `[data-tag-ui-name='${tag.replace(/["']/g, "")}']`
  );
  buttonEl.remove();

  // Add back the option in dropdown
  const tagOptionsMenu = parentEl.querySelector(".tag-ui-options-menu");
  const optionButton = document.createElement("button");
  optionButton.className = "tag-ui-option";
  optionButton.textContent = tag;

  optionButton.addEventListener("click", (event) => {
    event.preventDefault();
    addToTags(tag, parentEl);

    // Clear input and reset filtered options
    const wrapperEl = event.target.parentNode.parentNode;
    const inputEl = wrapperEl.querySelector(".tag-ui-text-input");
    const menuEl = wrapperEl.querySelector(".tag-ui-options-menu");
    inputEl.value = "";
    Array.from(menuEl.children).forEach((option) => {
      option.style.display = "block";
    });
  });

  tagOptionsMenu.appendChild(optionButton);
}