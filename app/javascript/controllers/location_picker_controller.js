import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["map", "lat", "lng", "status"]
  static values  = { lat: Number, lng: Number }

  connect() {
    const lat      = this.latValue || 41.9
    const lng      = this.lngValue || 12.5
    const hasCoords = this.latValue !== 0 && this.lngValue !== 0
    requestAnimationFrame(() => this.initMap(lat, lng, hasCoords))
  }

  disconnect() {
    if (this.map) this.map.remove()
  }

  initMap(lat, lng, hasCoords) {
    const L = window.L
    if (!L || !this.hasMapTarget) return

    this.map = L.map(this.mapTarget).setView([lat, lng], hasCoords ? 15 : 6)

    L.tileLayer("https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png", {
      attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> · © <a href="https://carto.com/">CARTO</a>',
      maxZoom: 19,
      subdomains: "abcd"
    }).addTo(this.map)

    if (hasCoords) {
      this.marker = L.marker([lat, lng], { draggable: true }).addTo(this.map)
      this.marker.on("dragend", () => this.onMarkerMoved())
      this.updateStatus(lat, lng)
    }

    this.map.on("click", (e) => {
      const { lat, lng } = e.latlng
      if (this.marker) {
        this.marker.setLatLng([lat, lng])
      } else {
        this.marker = L.marker([lat, lng], { draggable: true }).addTo(this.map)
        this.marker.on("dragend", () => this.onMarkerMoved())
      }
      this.writeCoords(lat, lng)
    })

    this.map.invalidateSize()
  }

  onMarkerMoved() {
    const { lat, lng } = this.marker.getLatLng()
    this.writeCoords(lat, lng)
  }

  writeCoords(lat, lng) {
    this.latTarget.value = lat.toFixed(6)
    this.lngTarget.value = lng.toFixed(6)
    this.updateStatus(lat, lng)
  }

  updateStatus(lat, lng) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = `${parseFloat(lat).toFixed(5)}, ${parseFloat(lng).toFixed(5)}`
    }
  }

  clearPin() {
    if (this.marker) {
      this.map.removeLayer(this.marker)
      this.marker = null
    }
    this.latTarget.value = ""
    this.lngTarget.value = ""
    if (this.hasStatusTarget) this.statusTarget.textContent = "No pin set"
  }
}
