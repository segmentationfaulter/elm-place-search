export function initMap(app) {
  return function() {
    var map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: -33.8688, lng: 151.2195 },
      zoom: 10
    });
    var input = document.getElementById("input-autocomplete");
    var marker = new google.maps.Marker({ map: map });

    app.ports.centerMap.subscribe((location) => {
      map.setCenter(location);
      marker.setPosition(location)
    })

    var autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.setFields(["place_id", "geometry", "name"]);
    autocomplete.addListener("place_changed", function() {
      var place = autocomplete.getPlace();
      app.ports.onPlaceChange.send({
        name: place.name,
        place_id: place.place_id,
        location: {
          lat: place.geometry.location.lat(),
          lng: place.geometry.location.lng()
        }
      })
    });
  };
}
