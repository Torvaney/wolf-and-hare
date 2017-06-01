module Board exposing (setSquare, createEmptyBoard,
                       addHare, addWolf, clearSquare)

import List.Extra as ListX

import Types exposing (..)


boardX : Int
boardX = 6


boardY : Int
boardY = 9


squareLoc : Board -> Int -> Int -> Int
squareLoc board x y =
  ListX.findIndex
    (\sq -> (&&) (sq.x == x) (sq.y == y))
    board |>
    Maybe.withDefault -1


createEmptyBoard : Board
createEmptyBoard =
  ListX.lift2
    (\x y -> Square Unoccupied x y)
    (List.range 1 boardX)
    (List.range 1 boardY)


setSquare : Square -> Board -> Board
setSquare square board =
  ListX.setAt
    (squareLoc board square.x square.y)
    square
    board |>
    Maybe.withDefault board


addHare : Int -> Int -> Board -> Board
addHare x y board =
  setSquare
    (Square (Occupied Hare) x y)
    board


addWolf : WolfPlayer -> Int -> Int -> Board -> Board
addWolf wolf x y board =
  setSquare
    (Square (Occupied (Wolf wolf)) x y)
    board


clearSquare : Int -> Int -> Board -> Board
clearSquare x y board =
  setSquare
    (Square Unoccupied x y)
    board
