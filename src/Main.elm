module Main exposing (Model, Msg(..), PlacePrediction, getAutoCompleteSuggestions, getPlacesApiEndpoint, init, initialModel, main, placePredictionDecoder, placesPredictionsDecoder, subscriptions, update, view)

import Browser
import Html exposing (Attribute, Html, div, input, h1, text)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onInput)
import Http
import Json.Decode exposing (Decoder, decodeString, field, list, map2, string)
import String


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


type alias Model =
    { query : String
    }


initialModel : Model
initialModel =
    { query = ""
    }



-- Update


type Msg
    = QueryChanged String
    | PlacesPredictionsReceived (Result Http.Error (List PlacePrediction))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        QueryChanged query ->
            ( { query = query }, getAutoCompleteSuggestions (getPlacesApiEndpoint query) )

        PlacesPredictionsReceived predictionsResult ->
            case predictionsResult of
                Result.Ok result ->
                    ( initialModel, Cmd.none )

                Result.Err _ ->
                    ( initialModel, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [
            h1 [] [text "Find a place"]
        ]



-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Helpers


getPlacesApiEndpoint : String -> String
getPlacesApiEndpoint query =
    let
        key =
            "AIzaSyClde8PpxKB0E6r5xoFf2LfDIpLNv047gw"
    in
    "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=" ++ key ++ "&input=" ++ query


getAutoCompleteSuggestions : String -> Cmd Msg
getAutoCompleteSuggestions url =
    Http.get
        { url = url
        , expect = Http.expectJson PlacesPredictionsReceived placesPredictionsDecoder
        }


type alias PlacePrediction =
    { description : String
    , place_id : String
    }


placesPredictionsDecoder : Decoder (List PlacePrediction)
placesPredictionsDecoder =
    field "predictions" (list placePredictionDecoder)


placePredictionDecoder : Decoder PlacePrediction
placePredictionDecoder =
    map2 PlacePrediction (field "place_id" string) (field "description" string)
