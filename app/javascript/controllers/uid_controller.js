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
      // listen for changes to the collection input select
      input.addEventListener("change", function () {
        const val = input.value.toString()
        // value passed to input is concatenation of ID and collection name, ID is pulled from string
        const collectionID = val.slice(0, val.indexOf("_"))
        // ID is padded with 0s
        const collectionIDPadded = collectionID.padStart(3, 0);
        // #uid-collection-str <span> innerHTML is set with collection ID string
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
        // listen for changes to medium input select
        const mediumID = mediumCodes[input.value].toString();
        // medium ID value is padded with 0s
        const mediumIDPadded = mediumID.padStart(3, 0)
        // #uid-medium-str <span> innerHTML is set with collection ID string
        uidMedium.innerHTML = mediumIDPadded;
      });
    };
  };
};