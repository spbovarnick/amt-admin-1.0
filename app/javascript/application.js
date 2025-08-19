// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "trix";
import "@rails/actiontext";
import "sortablejs";


// These modules are compiled and cached on build and imported at root-level layout rather than being imported to specific views as was the case in past versions of Rails.
// To prevent the console from flooding with errors, each of these modules wraps function calls in conditionals that check for the presence of a specific class or id in the DOM.
import "src/admin";