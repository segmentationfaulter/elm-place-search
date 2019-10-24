export function initMap(app) {
  return function() {
    const map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: -33.8688, lng: 151.2195 },
      zoom: 10
    });
    const marker = new google.maps.Marker({ map: map });
    const autoCompleteService = new google.maps.places.AutocompleteService();

    app.ports.askForPlacePredictions.subscribe(input => {
      getPredictions(input).then(predictions => {
        console.log(predictions);
      });
    });

    function centerMap(location) {
      map.setCenter(location);
      marker.setPosition(location);
    }

    function getPredictions(input) {
      return new Promise(resolve => {
        autoCompleteService.getPlacePredictions({ input }, predictions => {
          resolve(predictions);
        });
      });
    }
  };
}
