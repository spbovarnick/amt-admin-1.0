import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect () {
    const uidCollection = document.querySelector("#uid-collection-str");
    const uidMedium = document.querySelector("#uid-medium-str");

    const mediumInput = document.querySelector("#archive_item_medium");
    const collectionInput = document.querySelector("#archive_item_collection_list")

    trackMedium(mediumInput);
    trackCollection(collectionInput)

    function trackCollection(input) {
      input.addEventListener("change", function () {
        const val = input.value.toString()
        const collectionID = val.slice(0, val.indexOf("_"))
        const collectionIDPadded = collectionID.padStart(3, 0);
        uidCollection.innerHTML = collectionIDPadded;
      });
    };

    function trackMedium(input) {

      const mediumCodes = {
        "photo": 1,
        "film": 2,
        "audio": 3,
        "article": 4,
        "printed material": 5
      };

      input.addEventListener("change", function () {
        const mediumID = mediumCodes[input.value].toString();
        const mediumIDPadded = mediumID.padStart(3, 0)
        uidMedium.innerHTML = mediumIDPadded;
      });
    };
  };
};