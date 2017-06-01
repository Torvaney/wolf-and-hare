module State exposing (init, update, subscriptions)

import List.Extra as ListX
import Update.Extra as UpdateX

import Board exposing (..)
import Types exposing (..)


-- INIT


initBoard : Board
initBoard =
  createEmptyBoard |>
    addHare 3 1 |>
    addWolf Wolf1 1 9 |>
    addWolf Wolf2 3 9 |>
    addWolf Wolf3 5 9


initModel : Model
initModel =
  { board = initBoard
  , turn = GameStart
  }


init : ( Model, Cmd Msg )
init = ( initModel, Cmd.none )


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Select player ->
      ( { model
        | board = selectPlayer player model
        }
      , Cmd.none
      )

    Move player newSquare ->
      ( { model
        | board = model.board |>
                    findSquare player |>
                    selectMove newSquare |>
                    replaceSquares player (deselectSquares model.board)
        }
      , Cmd.none
      ) |>
        UpdateX.andThen update (MakeTurn (otherPlayer player))

    MakeTurn player ->
      ( { model
        | turn = ToMove player
        }
      , Cmd.none
      ) |>
      UpdateX.andThen update (checkHareWin model) |>
      UpdateX.andThen update (checkWolfWin model)

    GameWon player ->
      ( { model
        | turn = GameOver player
        }
      , Cmd.none
      )

    Restart ->
      init

    DoNothing ->
      ( model, Cmd.none  )


squareIndex : SquareState -> Board -> Int
squareIndex state board =
  ListX.findIndex
    (\sq -> sq.state == state)
    board |>
    Maybe.withDefault -1


findSquare : Player -> Board -> Square
findSquare player board =
  ListX.find
    (\sq -> sq.state == (Occupied player))
    board |>
    Maybe.withDefault (Square Unoccupied -1 -1)


possibleMoves : Player -> Square -> List Square
possibleMoves player square =
  case player of
    Wolf wolf ->
      [ Square (Available player) (square.x + 1) (square.y - 1)
      , Square (Available player) (square.x - 1) (square.y - 1)
      ]
    Hare ->
      [ Square (Available player) (square.x + 1) (square.y - 1)
      , Square (Available player) (square.x - 1) (square.y - 1)
      , Square (Available player) (square.x + 1) (square.y + 1)
      , Square (Available player) (square.x - 1) (square.y + 1)
      ]


selectMove : Square -> Square -> List Square
selectMove newSquare oldSquare =
  [ { oldSquare | state = Unoccupied }
  , { newSquare | state = oldSquare.state }
  ]


deselectSquare : Square -> Square
deselectSquare square =
  case square.state of
    Occupied player ->
      square
    Available player ->
      { square
      | state = Unoccupied
      }
    Unoccupied ->
      square


selectPlayer : Player -> Model -> Board
selectPlayer player model =
  model.board |>
    findSquare player |>
    possibleMoves player |>
    replaceSquares player (deselectSquares model.board)


deselectSquares : Board -> Board
deselectSquares board =
  List.map deselectSquare board


replaceSquares : Player -> Board -> List Square -> Board
replaceSquares player board squares =
  List.foldr (replaceSquare player) board squares


replaceSquare : Player -> Square -> Board -> Board
replaceSquare player square board =
  let
    existingSquare =
      ListX.find
        (\sq -> (&&) (sq.x == square.x) (sq.y == square.y))
        board |>
        Maybe.withDefault (Square Unoccupied -1 -1)
  in
    case existingSquare.state of
      Occupied existingPlayer ->
        if existingPlayer == player then
          setSquare square board
        else
          board
      Available player ->
        setSquare square board
      Unoccupied ->
        setSquare square board


otherPlayer : Player -> Player
otherPlayer player =
  case player of
    Hare ->
      Wolf Wolf1
    Wolf a ->
      Hare


checkHareWin : Model -> Msg
checkHareWin model =
  let
    hare = findSquare Hare model.board
    wolves =
      List.map
      (\w -> findSquare (Wolf w) model.board)
      [ Wolf1
      , Wolf2
      , Wolf3
      ]
    maxWolfY = List.map (\w -> w.y) wolves |>
      List.maximum |>
      Maybe.withDefault -1

  in
    if hare.y >= maxWolfY then
      GameWon Hare
    else
      DoNothing


checkWolfWin : Model -> Msg
checkWolfWin model =
  let
    testModel = { model | turn = ToMove Hare }
  in
    if (Debug.log "test" (selectPlayer Hare testModel)) == (Debug.log "real" testModel.board) then
      GameWon (Wolf Wolf1)
    else
      DoNothing


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
