port module Maps exposing(onPlaceChange)

import Json.Encode as Encode

port onPlaceChange: (Encode.Value -> msg) -> Sub msg
