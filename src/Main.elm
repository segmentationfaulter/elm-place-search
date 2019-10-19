module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, text)
import Json.Decode exposing (Decoder, decodeValue, field, string)
import Maps exposing (onPlaceChange)
import Json.Encode as Encode
import Maybe exposing (..)


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

type alias Place =
    {
        name: String
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
        PlaceChanged place -> case (getPlaceName place) of
            Just placeName -> (PlaceFound { name = placeName }, Cmd.none)
            Nothing -> (ErrorDecodingPlace, Cmd.none)

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


-- Helpers

getPlaceName: Encode.Value -> Maybe String
getPlaceName value =
    case (decodeValue placeNameDecoder value) of
        Ok placeName -> Just placeName
        Err _ -> Nothing


renderPlaceName: Model -> Html Msg
renderPlaceName model =
    case model of
        WaitingForFirstQuery -> text "We are ready to receive search requests"
        ErrorDecodingPlace -> text "There is an error encountered getting place name"
        PlaceFound place -> text ("Hey, you have flown to " ++ place.name)
