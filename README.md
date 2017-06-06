# Wolf and Hare

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

## Try it out

[Link](https://torvaney.github.io/projects/wolf-and-hare)

## Compile

Compile to javascript with `elm-make`
```
elm-make src/elm/Main.elm --output src/static/js/main.js
```

...and then view `index.html` in a browser.
