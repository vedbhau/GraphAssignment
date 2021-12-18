pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TicTacToe is Ownable {

    enum Result{created, active, player1Won, player2Won, draw, notPlayed}
    enum Box{none, X, O}

    struct Game {
        address player1;
        address player2;
        uint player1Bet;
        uint player2Bet;
        bool player1DrawDeclared;
        bool player2DrawDeclared;
        Result result;
        Box[3][3] board;
        Box nextMove;
    }

    mapping(uint => Game) games;
    uint private totalGames;

    event NewGame(uint gameId, address indexed creator);
    event PlayerJoined(uint gameId, address indexed joinee);
    event MoveMade(uint gameId, uint8 _x, uint8 _y);
    event GameFinished(uint gameId, Result result);
    event declareDraw(uint gameId, address indexed player);

    modifier betGreaterThanZero() {
        require(msg.value > 0, "Betting value is not enough");
        _;
    }

    modifier doesGameExists(uint _gameId) {
        require(_gameId <= totalGames, "Game does not exists");
        _;
    }

    modifier isGameAvailable(uint _gameId) {
        require(games[_gameId].result == Result.created, "The Game is not available");
        _;
    }

    modifier isGameActive(uint _gameId) {
        require(games[_gameId].result == Result.active, "The Game is not active");
        _;
    }

    modifier isMoveCorrect(uint _gameId, uint8 _x, uint8 _y) {
        require(games[_gameId].board[_x][_y] == Box.none, "Invalid move");
        if(games[_gameId].nextMove == Box.X) {
            require(msg.sender == games[_gameId].player2, "Not your chance");
        } else {
            require(msg.sender == games[_gameId].player1, "Not your chance");
        }
        _;
    }

    function newGame() external payable betGreaterThanZero returns(uint) {
        totalGames++;
        uint gameId = totalGames;
        games[gameId].player1 = msg.sender;
        games[gameId].player1Bet = msg.value;
        games[gameId].result = Result.created;
        games[gameId].nextMove = Box.none;
        emit NewGame(gameId, msg.sender);
        return gameId;
    }

    function joinGame(uint _gameId, uint8 _x, uint8 _y) external payable doesGameExists(_gameId) isGameAvailable(_gameId) returns(bool) {
        require(msg.value == games[_gameId].player1Bet, "Bet not matched");
        require(msg.sender != games[_gameId].player1, "Cannot play with yourself");
        games[_gameId].player2 = msg.sender;
        games[_gameId].player2Bet = msg.value;
        games[_gameId].result = Result.active;
        games[_gameId].nextMove = Box.X;
        makeMove(_gameId, _x, _y);
        emit PlayerJoined(_gameId, msg.sender);

        return true;
    }

    function makeMove(uint _gameId, uint8 _x, uint8 _y) public doesGameExists(_gameId) isGameActive(_gameId) isMoveCorrect(_gameId, _x, _y) returns(bool) {

        Game storage game = games[_gameId];
        game.board[_x][_y] = game.nextMove;

        Box winner = checkWinner(game.board);
        if(winner == Box.none && isDraw(game.board)) {
            game.result = Result.draw;
            game.nextMove = Box.none;
            payable(game.player1).transfer(game.player1Bet);
            payable(game.player2).transfer(game.player2Bet);
            emit GameFinished(_gameId, Result.draw);
        } else if(winner != Box.none) {
            if(winner == Box.X) {
                game.result = Result.player2Won;
                payable(game.player2).transfer(game.player1Bet + game.player2Bet);
            } else if(winner == Box.O) {
                game.result = Result.player1Won;
                payable(game.player1).transfer(game.player1Bet + game.player2Bet);
            }
            game.nextMove = Box.none;
            emit GameFinished(_gameId, game.result);
        } else {
            if(game.nextMove == Box.X) {
                game.nextMove = Box.O;
            } else {
                game.nextMove = Box.X;
            }
            emit MoveMade(_gameId, _x, _y);
        }

        return true;
    }

    function declareDraw(uint _gameId) external doesGameExists(_gameId) isGameActive(_gameId) returns(bool) {
        require(msg.sender == games[_gameId].player1 || msg.sender == games[_gameId].player2, "You are not a party to the game");
        if(games[_gameId].player1 == msg.sender) {
                games[_gameId].player1DrawDeclared = true;
            } else {
                games[_gameId].player2DrawDeclared = true;
            }
        if( games[_gameId].player1DrawDeclared && games[_gameId].player2DrawDeclared) {
            payable(games[_gameId].player1).transfer(games[_gameId].player1Bet);
            payable(games[_gameId].player2).transfer(games[_gameId].player2Bet);
            emit GameFinished(_gameId, Result.draw);
            return true;
        }
        emit declareDraw(_gameId, msg.sender);
        return false;
    }

    function getRefund(uint _gameId) external doesGameExists(_gameId) isGameAvailable(_gameId) {
      require(msg.sender == games[_gameId].player1)
      payable(games[_gameId].player1).transfer(games[_gameId].player1Bet);
      emit GameFinished(_gameId, Result.notPlayed);
    }

    function checkWinner(Box[3][3] memory _board) private pure returns(Box) {
        Box winner = checkRows(_board);
        if(winner != Box.none){
        return winner;
        }

        winner = checkColumns(_board);
        if(winner != Box.none){
        return winner;
        }

        winner = checkDiagonals(_board);
        if(winner != Box.none){
        return winner;
        }
        return Box.none;
    }

    function checkRows(Box[3][3] memory _board) private pure returns(Box) {
        for(uint8 i=0; i<3; i++) {
            if(_board[i][0] != Box.none && _board[i][0] == _board[i][1] && _board[i][1] == _board[i][2]) {
                return _board[i][0];
            }
        }
        return Box.none;
    }

    function checkColumns(Box[3][3] memory _board) private pure returns(Box) {
        for(uint8 i=0; i<3; i++) {
            if(_board[0][i] != Box.none && _board[0][i] == _board[1][i] && _board[1][i] == _board[2][i]) {
                return _board[0][i];
            }
        }
        return Box.none;
    }

    function checkDiagonals(Box[3][3] memory _board) private pure returns(Box) {
        if((_board[1][1] != Box.none && _board[0][0] == _board[1][1] && _board[1][1] == _board[2][2]) || (_board[1][1] != Box.none && _board[2][0] == _board[1][1] && _board[1][1] == _board[0][2])) {
            return _board[1][1];
        }
        return Box.none;
    }

    function isDraw(Box[3][3] memory _board) private pure returns(bool) {
        for(uint8 i=0; i<3; i++) {
            for(uint8 j=0; j<3; j++) {
                if(_board[i][j] == Box.none) {
                    return false;
                }
            }
        }
        return true;
    }
}
