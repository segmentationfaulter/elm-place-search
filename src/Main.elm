module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, text)
import Json.Decode exposing (Decoder, decodeValue, field, string, float, map2, map3)
import Maps exposing (onPlaceChange)
import Json.Encode as Encode
import Maybe


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Init


init : () -> ( Model, Cmd msg )
init () =
    ( initialModel, Cmd.none )



-- Modal

type alias Location =
    {
        lat: Float,
        lng: Float
    }

type alias Place =
    {
        name: String,
        placeId: String,
        location: Location
    }

type Model = ErrorDecodingPlace
    | PlaceFound Place
    | WaitingForFirstQuery
    


initialModel : Model
initialModel = WaitingForFirstQuery


-- Update


type Msg =
    PlaceChanged Encode.Value

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaceChanged placeResult -> case (getPlace placeResult) of
            Maybe.Just place -> (PlaceFound place, Cmd.none)
            Maybe.Nothing -> (ErrorDecodingPlace, Cmd.none)

-- View


view : Model -> Html Msg
view model =
    div []
        [
            h1 [] [text "Find a place"],
            renderPlaceName model
        ]



-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    onPlaceChange PlaceChanged


-- Decoders

placeNameDecoder: Decoder String
placeNameDecoder = field "name" string

placeIdDecoder: Decoder String
placeIdDecoder = field "place_id" string

locationDecoder: Decoder Location
locationDecoder = field "location" (map2 Location (field "lat" float) (field "lng" float))

placeDecoder: Decoder Place
placeDecoder = map3 Place placeNameDecoder placeIdDecoder locationDecoder


-- Helpers

getPlace: Encode.Value -> Maybe.Maybe Place
getPlace value =
    case (decodeValue placeDecoder value) of
        Ok placeName -> Just placeName
        Err _ -> Nothing


renderPlaceName: Model -> Html Msg
renderPlaceName model =
    case model of
        WaitingForFirstQuery -> text "We are ready to receive search requests"
        ErrorDecodingPlace -> text "There is an error encountered getting place name"
        PlaceFound place -> text ("Hey, you have flown to " ++ place.name ++ " having ID: " ++ place.placeId)
