module Main exposing (..)

import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode exposing (Decoder, Error, decodeValue, field, float, list, map2, string)
import Json.Encode as Encode
import Maps exposing (askForPlacePredictions, centerMap, fetchPlacesPredictions)


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
    { lat : Float
    , lng : Float
    }


type alias Place =
    { name : String
    , location : Location
    }


type alias Prediction =
    { description : String
    , place_id : String
    }

type alias AfterQueryState =
    {textInput: String
    , predictions: Result Error (List Prediction)
    }


type Model =
    ReadyForFirstQuery
    | UserIsInteracting AfterQueryState


initialModel : Model
initialModel =
    ReadyForFirstQuery



-- Update


type Msg
    = InputChanged String
    | GotPlacesPredictions Encode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged input -> case model of
            ReadyForFirstQuery -> (UserIsInteracting (AfterQueryState input (Ok [])), askForPlacePredictions (Encode.string input))
            UserIsInteracting afterQueryState -> (UserIsInteracting { afterQueryState | textInput = input }, askForPlacePredictions (Encode.string input))
        GotPlacesPredictions predictionsValue -> case model of
            ReadyForFirstQuery -> (ReadyForFirstQuery, Cmd.none)
            UserIsInteracting afterQueryState -> (UserIsInteracting { afterQueryState | predictions = getPredictionsResult predictionsValue}, Cmd.none)

            


-- View


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Find a place" ]
        , renderAutoCompleteInput model
        , Html.div [ Attr.id "map" ] []
        ]


renderAutoCompleteInput : Model -> Html.Html Msg
renderAutoCompleteInput model =
    Html.div []
        [ Html.input
            [ Attr.type_ "text"
            , Attr.placeholder "Enter a location"
            , Attr.id "input-autocomplete"
            , Events.onInput InputChanged
            , Attr.value
                (case model of
                    ReadyForFirstQuery -> ""
                    UserIsInteracting { textInput, predictions } -> textInput
                )
            ]
            []
        ]



{-

   renderPlaceName : Model -> Html.Html Msg
   renderPlaceName model =
       case model of
           WaitingForFirstQuery ->
               Html.text "We are ready to receive search requests, input your query in the text field below"

           ErrorDecodingPlace ->
               Html.text "There is an error encountered getting place name"

           PlaceFound place ->
               Html.text ("Hey, you have flown to " ++ place.name)

-}
-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    fetchPlacesPredictions GotPlacesPredictions



-- Decoders


placeNameDecoder : Decoder String
placeNameDecoder =
    field "name" string


locationDecoder : Decoder Location
locationDecoder =
    field "location" (map2 Location (field "lat" float) (field "lng" float))


placeDecoder : Decoder Place
placeDecoder =
    map2 Place placeNameDecoder locationDecoder


predictionsDecoder : Decoder (List Prediction)
predictionsDecoder =
    list (map2 Prediction (field "description" string) (field "place_id" string))



-- Encoders


encodeLocation : Location -> Encode.Value
encodeLocation location =
    Encode.object
        [ ( "lat", Encode.float location.lat )
        , ( "lng", Encode.float location.lng )
        ]



-- Helpers


getPlaceResult : Encode.Value -> Result Error Place
getPlaceResult value =
    decodeValue placeDecoder value


getPredictionsResult : Encode.Value -> Result Error (List Prediction)
getPredictionsResult value =
    decodeValue predictionsDecoder value
