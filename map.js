window.initMap = function initMap() {
	var zoomLevel = 8;
  var map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: -33.8688, lng: 151.2195},
    zoom: zoomLevel
  });

  var input = document.getElementById('input-autocomplete');

  var autocomplete = new google.maps.places.Autocomplete(input);

  // Specify just the place data fields that you need.
  autocomplete.setFields(['place_id', 'geometry']);


  autocomplete.addListener('place_changed', function() {
    var marker = new google.maps.Marker({map: map});
    var place = autocomplete.getPlace();

    if (!place.geometry) {
      return;
    }
    
    map.setCenter(place.geometry.location);
    marker.setPlace({
      placeId: place.place_id,
      location: place.geometry.location
    });

    marker.setVisible(true);
  });
}
