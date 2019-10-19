import { Elm } from "./src/Main.elm";
import { initMap } from './map'

const app = Elm.Main.init({
  node: document.getElementById("app")
});

window.initMap = initMap(app)
