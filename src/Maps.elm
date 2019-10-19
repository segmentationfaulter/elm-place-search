port module Maps exposing (..)

import Json.Encode as Encode


port onPlaceChange : (Encode.Value -> msg) -> Sub msg


port centerMap : Encode.Value -> Cmd msg
