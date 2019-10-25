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
    { textInput : String
    , predictions : Result Error (List Prediction)
    }


type Model
    = ReadyForFirstQuery
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
        InputChanged input ->
            case model of
                ReadyForFirstQuery ->
                    ( UserIsInteracting (AfterQueryState input (Ok [])), askForPlacePredictions (Encode.string input) )

                UserIsInteracting { predictions } ->
                    case input of
                        "" ->
                            case predictions of
                                Ok _ ->
                                    ( UserIsInteracting { textInput = input, predictions = Ok [] }, Cmd.none )

                                Err _ ->
                                    ( UserIsInteracting { textInput = input, predictions = predictions }, Cmd.none )

                        _ ->
                            ( UserIsInteracting { textInput = input, predictions = predictions }, askForPlacePredictions (Encode.string input) )

        GotPlacesPredictions predictionsValue ->
            case model of
                ReadyForFirstQuery ->
                    ( ReadyForFirstQuery, Cmd.none )

                UserIsInteracting afterQueryState ->
                    ( UserIsInteracting { afterQueryState | predictions = getPredictionsResult predictionsValue }, Cmd.none )



-- View


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Find a place" ]
        , renderAutoCompleteInput model
        , renderPlacePredictions model
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
                    ReadyForFirstQuery ->
                        ""

                    UserIsInteracting { textInput, predictions } ->
                        textInput
                )
            ]
            []
        ]


renderPlacePredictions : Model -> Html.Html Msg
renderPlacePredictions model =
    case model of
        ReadyForFirstQuery ->
            Html.text ""

        UserIsInteracting { predictions, textInput } ->
            case predictions of
                Ok predictionsList ->
                    if String.length textInput > 0 then
                        Html.div [ Attr.class "predictions-list" ] (List.map (\{ description } -> Html.div [ Attr.class "predictions-item" ] [ Html.text description ]) predictionsList)

                    else
                        Html.text ""

                Err _ ->
                    Html.text "Houston, we have a problem!"



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
