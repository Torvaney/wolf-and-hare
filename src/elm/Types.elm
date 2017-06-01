module Types exposing (..)


type Msg
  = Select Player
  | Move Player Square
  | GameWon Player
  | MakeTurn Player
  | Restart
  | DoNothing


type Player
  = Hare
  | Wolf WolfPlayer


type WolfPlayer
  = Wolf1
  | Wolf2
  | Wolf3


type SquareState
  = Occupied Player
  | Available Player
  | Unoccupied


type alias Square =
  { state : SquareState
  , x : Int
  , y : Int
  }


type alias Board = List Square


type BoardState
  = ToMove Player
  | GameStart
  | GameOver Player


type alias Model =
  { board : List Square
  , turn : BoardState
  }
