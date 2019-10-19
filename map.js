export function initMap(app) {
  return function() {
    const map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: -33.8688, lng: 151.2195 },
      zoom: 10
    });
    const input = document.getElementById("input-autocomplete");
    const marker = new google.maps.Marker({ map: map });

    app.ports.centerMap.subscribe(location => {
      map.setCenter(location);
      marker.setPosition(location);
    });

    const autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.setFields(["geometry", "name"]);
    autocomplete.addListener("place_changed", function() {
      const place = autocomplete.getPlace();
      app.ports.onPlaceChange.send({
        name: place.name,
        location: {
          lat: place.geometry.location.lat(),
          lng: place.geometry.location.lng()
        }
      });
    });
  };
}
