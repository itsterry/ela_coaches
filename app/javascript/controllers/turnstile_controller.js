import { Controller } from "@hotwired/stimulus"

const SCRIPT_URL = "https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit"

// Renders the widget explicitly so it survives Turbo visits and re-rendered
// forms, where the script's own automatic rendering only runs on first load.
export default class extends Controller {
  static values = { sitekey: String }

  connect() {
    this.loadScript().then(() => this.render())
  }

  disconnect() {
    if (this.widgetId) window.turnstile.remove(this.widgetId)
  }

  loadScript() {
    if (!window.turnstileLoaded) {
      window.turnstileLoaded = new Promise((resolve) => {
        const script = document.createElement("script")
        script.src = SCRIPT_URL
        script.async = true
        script.onload = resolve
        document.head.appendChild(script)
      })
    }

    return window.turnstileLoaded
  }

  render() {
    if (!this.element.isConnected) return

    this.widgetId = window.turnstile.render(this.element, { sitekey: this.sitekeyValue })
  }
}
