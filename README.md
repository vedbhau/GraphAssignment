# Tic Tac Toe

> Game flow
1. Player1 creates the game by placing a bet.
2. Player1 can claim refund before second player joins the game.
3. Player2 joins the game by using gameId as input, they also have to play there first chance.
4. After each move the game checks for winner or draw.
5. Both player can offer to declare draw, once both player declare they get refund and draw is declared.
6. If winner is found they get both the bets as prize.

> Assumptions
1. Player2 will get the information about the gameId and bet from the player1.
2. Playe2 joins the game by stating their move.
3. Player1 can get refund only before player2 has joined.
4. After player2 has joined they have to finish the game to get the payment.
5. Result.created = The game is available to play, player1 ready.
6. Result.active = Both players have made their bets and game is being played.
7. Result.player1Won = Player1 won the game and prize.
8. Result.player2Won = Player2 won the game and prize.
9. Result.draw = Either the game is finished without a winner or draw has been declared.
10. Result.notPlayed = Player1 has claimed refund and game is not available.
11. Box.none = No player played.
12. Box.X = player2.
13. Box.O = player1.

> Thought process
1. After each move is played we need to check if any row, column or diagonal is filled with same Box value. If filled we declare the winner. 
2. If there is no winner we continue the play untill all boxes are filled.
3. While playing the game the players may realise that the game is heading towards draw and thus can offer to declare draw. This realisation of draw before all boxes are filled can not be done in code since we can not assume rationality on part of the players.

