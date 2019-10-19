export function initMap(app) {
  return function() {
    var map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: -33.8688, lng: 151.2195 },
      zoom: 10
    });
    var input = document.getElementById("input-autocomplete");

    var autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.setFields(["place_id", "geometry", "name"]);
    autocomplete.addListener("place_changed", function() {
      var place = autocomplete.getPlace();
      app.ports.onPlaceChange.send(place)
      if (!place.geometry) {
        return;
      }
      map.setCenter(place.geometry.location);

      var marker = new google.maps.Marker({ map: map });
      marker.setPlace({
        placeId: place.place_id,
        location: place.geometry.location
      });
      marker.setVisible(true);
    });
  };
}
