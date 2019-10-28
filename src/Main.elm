module Main exposing (..)

import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode
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


type alias Prediction =
    { description : String
    , place_id : String
    }


type alias StateAfterUserStartsInteraction =
    { textInput : String
    , predictions : Result Decode.Error (List Prediction)
    , showPredictions : Bool
    }


type Model
    = ReadyForFirstQuery
    | UserIsInteracting StateAfterUserStartsInteraction


initialModel : Model
initialModel =
    ReadyForFirstQuery



-- Update


type Msg
    = InputChanged String
    | GotPlacesPredictions Encode.Value
    | SetPredictionsVisibility Bool
    | SelectPrediction Prediction


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged input ->
            case model of
                ReadyForFirstQuery ->
                    ( UserIsInteracting (StateAfterUserStartsInteraction input (Ok []) True), askForPlacePredictions (Encode.string input) )

                UserIsInteracting stateAfterUserStartsInteraction ->
                    case input of
                        "" ->
                            case stateAfterUserStartsInteraction.predictions of
                                Ok _ ->
                                    ( UserIsInteracting (StateAfterUserStartsInteraction input (Ok []) True), Cmd.none )

                                Err _ ->
                                    ( UserIsInteracting { stateAfterUserStartsInteraction | textInput = input }, Cmd.none )

                        _ ->
                            ( UserIsInteracting { stateAfterUserStartsInteraction | textInput = input }, askForPlacePredictions (Encode.string input) )

        GotPlacesPredictions predictionsValue ->
            case model of
                ReadyForFirstQuery ->
                    ( ReadyForFirstQuery, Cmd.none )

                UserIsInteracting stateAfterUserStartsInteraction ->
                    ( UserIsInteracting { stateAfterUserStartsInteraction | predictions = getPredictionsResult predictionsValue }, Cmd.none )

        SetPredictionsVisibility visible ->
            case model of
                ReadyForFirstQuery ->
                    ( ReadyForFirstQuery, Cmd.none )

                UserIsInteracting stateAfterUserStartsInteraction ->
                    ( UserIsInteracting { stateAfterUserStartsInteraction | showPredictions = visible }, Cmd.none )

        SelectPrediction { description, place_id } ->
            case model of
                ReadyForFirstQuery ->
                    ( model, Cmd.none )

                UserIsInteracting stateAfterUserStartsInteraction ->
                    ( UserIsInteracting { stateAfterUserStartsInteraction | textInput = description, predictions = Ok [] }, centerMap (Encode.string place_id) )



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
            , Attr.autofocus True
            , Attr.autocomplete False
            , Events.onInput InputChanged
            , Events.onFocus (SetPredictionsVisibility True)
            , Events.onBlur (SetPredictionsVisibility False)
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

        UserIsInteracting { predictions, textInput, showPredictions } ->
            if showPredictions then
                case predictions of
                    Ok predictionsList ->
                        if String.length textInput > 0 then
                            Html.div
                                [ Attr.class "predictions-list" ]
                                (List.map (\{ description, place_id } -> Html.div [ Attr.class "predictions-item", Events.onMouseDown (SelectPrediction (Prediction description place_id)) ] [ Html.text description ]) predictionsList)

                        else
                            Html.text ""

                    Err _ ->
                        Html.text "Got some error fetching predictions :-("

            else
                Html.text ""



-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    fetchPlacesPredictions GotPlacesPredictions



-- Decoders


predictionsDecoder : Decode.Decoder (List Prediction)
predictionsDecoder =
    Decode.list (Decode.map2 Prediction (Decode.field "description" Decode.string) (Decode.field "place_id" Decode.string))



-- Helpers


getPredictionsResult : Encode.Value -> Result Decode.Error (List Prediction)
getPredictionsResult value =
    Decode.decodeValue predictionsDecoder value
