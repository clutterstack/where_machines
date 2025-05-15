// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}
Hooks.CountUpTimer = {
  mounted() {
    this.running = false;
    this.elapsed = 0;
    
    this.handleEvent("timer-start", () => {
      this.start();
    });
    
    this.handleEvent("timer-stop", () => {
      this.stop();
    });
    
    this.handleEvent("timer-reset", () => {
      this.reset();
    });
  },
  
  start() {
    if (!this.running) {
      this.running = true;
      this.startTime = Date.now() - (this.elapsed * 1000);
      this.timer = setInterval(() => this.update(), 100);
    }
  },
  
  stop() {
    this.running = false;
    clearInterval(this.timer);
  },
  
  reset() {
    this.stop();
    this.elapsed = 0.0;
    this.update();
  },
  
  update() {
    if (this.running) {
      this.elapsed = Date.now() - this.startTime;
    }
    const minutes = Math.floor(this.elapsed / 60000);
    const seconds = Math.floor((this.elapsed % 60000) / 1000);
    const tenths = Math.floor((this.elapsed % 1000) / 100);
    this.el.innerText = `${minutes}:${seconds.toString().padStart(2, '0')}.${tenths}`;
  },
  
  destroyed() {
    clearInterval(this.timer);
  }
}


let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

