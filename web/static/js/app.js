// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import 'phoenix_html';
import Elm from './main';


// Render Elm application
const elmDiv = document.querySelector('#elm-target');
if (elmDiv) {
  // Store JWT access token in local storage to persist across sessions
  const storageKey = 'accessToken';

  const elmApp = Elm.Main.embed(elmDiv);

  elmApp.ports.save.subscribe((value) => {
    localStorage.setItem(storageKey, value);
  });
  elmApp.ports.doload.subscribe(() => {
    elmApp.ports.load.send(localStorage.getItem(storageKey));
  });
  elmApp.ports.remove.subscribe(() => {
    localStorage.removeItem(storageKey);
  });
}

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
