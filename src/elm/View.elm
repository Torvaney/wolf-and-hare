module View exposing (..)

import Html exposing (Html, div, hr)
import Html.Attributes as Attr
import Html.Events as Events
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)
import Markdown

import Types exposing (..)


view : Model -> Html.Html Msg
view model =
  div [ Attr.class "row"]
    [ divN 1
    , div [ Attr.class "col-md-10 text-center" ]
          [ Html.h1 [ Attr.class "text-center" ] [ text headerText ]
          , Markdown.toHtml [ Attr.class "text-left" ] introText
          , div [ Attr.class "row" ]
            [ div [ Attr.class "col-md-12" ]
              [ svg
                [ width <| toString <| squareSize * 7
                , height <| toString <| squareSize * 10
                ]
                ( drawSquares model )
              , showMessage model.turn
              , showButtons model.turn
              , hr [] []
              ]
            ]
          , Markdown.toHtml [ Attr.class "text-left" ] appendixText
          ]
    , divN 1
    ]


divN : Int -> Html.Html msg
divN n =
  div [ Attr.class ("col-md-" ++ (toString n)) ] []


squareSize : Float
squareSize =
  40


isEven : Int -> Bool
isEven i =
  (rem i 2) == 0


playerName : Player -> String
playerName player =
  case player of
    Hare ->
      "Hare"
    Wolf a ->
      "Wolf"


showMessage : BoardState -> Html.Html Msg
showMessage turn =
  case turn of
    ToMove player ->
      Html.p [] [ Html.text ((playerName player) ++ "'s turn to move...") ]

    GameStart ->
      Html.p [] [ Html.text "Pick a player to start" ]

    GameOver player ->
      Html.p [] [ Html.text ((playerName player) ++ " wins!") ]


showButtons : BoardState -> Html.Html Msg
showButtons turn =
  case turn of
    ToMove a ->
      Html.div [] []

    GameStart ->
      Html.div
        [ Attr.class "btn-group" ]
        [ Html.a
           [ Attr.class "btn btn-secondary"
           , Events.onClick (MakeTurn Hare)
           ]
           [ Html.text "Start with hare"]
        , Html.button
           [ Attr.class "btn btn-secondary"
           , Events.onClick (MakeTurn (Wolf Wolf1))
           ]
           [ Html.text "Start with wolf"]
        ]

    GameOver a ->
      Html.div
        []
        [ Html.button
           [ Events.onClick Restart ]
           [ Html.text "Restart"]
        ]


toColorCode : Square -> String
toColorCode square =
  case square.state of
    Occupied player ->
      -- playerColour player
      if isEven (square.x + square.y) then
        "#525252"
      else
        "#dddddd"
    Available player ->
      "#ffde36"
    Unoccupied ->
      if isEven (square.x + square.y) then
        "#525252"
      else
        "#dddddd"


playerColour : Player -> String
playerColour player =
  case player of
    Hare ->
      "#48acde"
    Wolf wolf ->
      "#fb5454"


drawSquares : Model -> List (Svg Msg)
drawSquares model =
  List.concatMap (drawSquare model.turn) model.board


drawSquare : BoardState -> Square -> List (Svg Msg)
drawSquare turn square =
  case square.state of
    Occupied player ->
      drawPlayer turn player square

    Available player ->
      drawSelected player square

    Unoccupied ->
      drawBlank square


drawBlank : Square -> List (Svg Msg)
drawBlank square =
  [ rect
      [ x <| toString <| (*) squareSize <| toFloat square.x
      , y <| toString <| (*) squareSize <| toFloat square.y
      , width <| toString squareSize
      , height <| toString squareSize
      , fill <| toColorCode square
      , stroke "lightgray"
      ]
      []
  ]


drawSelected : Player -> Square -> List (Svg Msg)
drawSelected player square =
  [ rect
      [ x <| toString <| (*) squareSize <| toFloat square.x
      , y <| toString <| (*) squareSize <| toFloat square.y
      , width <| toString squareSize
      , height <| toString squareSize
      , fill <| toColorCode square
      , stroke "none"
      , onClick (Move player square)
      ]
      []
  ]


drawPlayer : BoardState -> Player -> Square -> List (Svg Msg)
drawPlayer turn player square =
  [ rect
      [ x <| toString <| (*) squareSize <| toFloat <| square.x
      , y <| toString <| (*) squareSize <| toFloat <| square.y
      , width <| toString squareSize
      , height <| toString squareSize
      , fill <| toColorCode square
      , stroke <| "none"
      , onClick <| playerMsg turn player
      ]
      []
  , circle
      [ cx <| toString <| (+) (squareSize / 2) <| (*) squareSize <| toFloat square.x
      , cy <| toString <| (+) (squareSize / 2) <| (*) squareSize <| toFloat square.y
      , r <| toString <| squareSize / 3
      , fill <| playerColour player
      , stroke <| "black"
      , onClick <| playerMsg turn player
      ]
      []
  ]


playerMsg : BoardState -> Player -> Msg
playerMsg turn player =
  case turn of
    ToMove turnPlayer ->
      if (samePlayer player turnPlayer) then
        Select player
      else
        DoNothing

    GameStart ->
      DoNothing

    GameOver a ->
      DoNothing


samePlayer : Player -> Player -> Bool
samePlayer player1 player2 =
  if (isHare player1) == (isHare player2) then
    True
  else
    False


isHare : Player -> Bool
isHare player =
  case player of
    Hare ->
      True
    Wolf a ->
      False


-- TEXT

headerText = "Wolf and Hare"


introText = """
A 2 player version of the game outlined
[here](http://www.ucl.ac.uk/~uctpmw0/HaseWolf/hw_main.html)
 by Martin Weidner.

## The rules
 * Players take turns to move.
 * The Wolf (red) can move one of its three pieces diagonally and forwards.
 * The Hare (blue) can move diagonally in all directions.
 * Players cannot move into a space alrady occupied by another piece.
 * The goal of the Hare is to reach the bottom of the board.
 * The goal of the Wolves is to trap the Hare so that it cannot make any moves.

The game comes with an additional twist: the player starting the game cannot win unless the opponent makes a mistake...
"""


appendixText = """
Code lives here: https://github.com/Torvaney/wolf-and-hare
"""
