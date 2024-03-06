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
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import darkModeHook from "../vendor/dark_mode"

let Hooks = {}
Hooks.DarkThemeToggle = darkModeHook
Hooks.DragDrop = {
  mounted() {
    const view = this;
    let dropArea = document.getElementById(this.el.id);
    // Disable default behaviour
    [("dragenter", "dragover", "dragleave", "drop")].forEach((eventName) => {
      dropArea.addEventListener(eventName, preventDefaults, false);
    });
    function preventDefaults(e) {
      e.preventDefault();
      e.stopPropagation();
    }
    // Add highlight behaviour when dragging of file over element
    ["dragenter", "dragover"].forEach((eventName) => {
      dropArea.addEventListener(eventName, highlight, false);
    });

    // Remove highlight behaviour when not dragging of file over element or file is dropped
    ["dragleave", "drop"].forEach((eventName) => {
      dropArea.addEventListener(eventName, unhighlight, false);
    });
    function highlight(e) {
      dropArea.classList.add("border-2");
      dropArea.classList.add("border-dashed");
      dropArea.placeholder = "Drag and drop image to upload"
    }

    function unhighlight(e) {
      dropArea.classList.remove("border-2");
      dropArea.classList.remove("border-dashed");
      dropArea.placeholder = "Body"
    }

    // Handle upload file behaviour after drag & drop
    dropArea.addEventListener("drop", uploadFile, false);
    function uploadFile(e) {
      e.preventDefault();
      const file = e.dataTransfer.files[0];
      view.pushEvent("drag-drop-image-upload", {
        file: {}, // Not redundant, necessary for validation on liveview side
        size: file.size,
        type: file.type
      }, (reply, _) => {
        if (!reply.valid) return
        dropArea.value += `![Uploading ${file.name}...]()`
        const reader = new FileReader();
        reader.onload = function () {
          const fileArray = reader.result;
          view.pushEvent("drag-drop-image-upload", { file: _arrayBufferToBase64(fileArray), type: file.type },
            (reply, _) => {
              if (reply.image_url === null) return;
              dropArea.value = dropArea.value.replace(`![Uploading ${file.name}...]()`, `![${file.name}](${reply.image_url})`)
            })
        }
        reader.readAsArrayBuffer(file);
      })
    }

    function _arrayBufferToBase64(buffer) {
      var binary = '';
      var bytes = new Uint8Array(buffer);
      var len = bytes.byteLength;
      for (var i = 0; i < len; i++) {
        binary += String.fromCharCode(bytes[i]);
      }
      return window.btoa(binary);
    }
  },
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks },)

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())
window.addEventListener("phx:window_alert", (e) => alert(e.detail.message))
window.addEventListener("phx:exec-attr-in-element", ({ detail }) => {
  document.querySelectorAll(detail.element_id).forEach(el => {
    liveSocket.execJS(el, el.getAttribute(detail.attr))
  })
})
// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

