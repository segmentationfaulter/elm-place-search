export function initMap(app) {
  return function() {
    const map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: -33.8688, lng: 151.2195 },
      zoom: 10
    });
    const marker = new google.maps.Marker({ map: map });
    const autoCompleteService = new google.maps.places.AutocompleteService();
    const placesService = new google.maps.places.PlacesService(map);

    app.ports.askForPlacePredictions.subscribe(input => {
      getPredictions(input).then(predictions => {
        app.ports.fetchPlacesPredictions.send(predictions)
      });
    });

    app.ports.centerMap.subscribe(place_id => {
      getPlaceDetails(place_id)
      .then(centerMap)
    })

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

    function getPlaceDetails (placeId) {
      return new Promise((resolve, reject) => {
        placesService.getDetails({
          placeId,
          fields: ['geometry']
        }, (details) => {
          const location = details.geometry.location
          resolve(location)
        })
      })
    }
  };
}
