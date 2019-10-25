port module Maps exposing (..)

import Json.Encode as Encode


port onPlaceChange : (Encode.Value -> msg) -> Sub msg


port centerMap : Encode.Value -> Cmd msg


port askForPlacePredictions : Encode.Value -> Cmd msg


port fetchPlacesPredictions : (Encode.Value -> msg) -> Sub msg
