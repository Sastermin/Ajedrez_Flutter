import 'package:ajedrez_flutter/components/piece.dart';
import 'package:ajedrez_flutter/components/square.dart';
import 'package:ajedrez_flutter/helper/helper_methods.dart';
import 'package:ajedrez_flutter/values/colors.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  // A 2-dimensional list representing the chessboard,
  //with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  //The currently selected piece on the chess board
  //if no piece is selected, this is null
  ChessPiece? selectedPiece;

  //The row index of the selected piece
  //Default value -1 indicated no piece is currently selected;
  int selectedRow = -1;

  //The column index of the selected piece
  //Default value -1 indicated no piece is currently selected;
  int selectedCol = -1;

  //A list of valid moves for the currently selected piece
  //each move is represented as a list with 2 elements: row and col
  List<List<int>> validMoves = [];

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //INITIALIZE BOARD
  void _initializeBoard(){
    //Initialize the board with the nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard = 
      List.generate(8, (index) => List.generate(8, (index) => null));

    
    //Place pawns  
    for (int i = 0; i < 8; i++){
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn, 
        isWhite: false, 
        imagePath: 'lib/images/black-pawn.png'
        );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn, 
        isWhite: true, 
        imagePath: 'lib/images/black-pawn.png'
        );
    }

    //Place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook, 
      isWhite: false, 
      imagePath: 'lib/images/black-rook.png'
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook, 
      isWhite: false, 
      imagePath: 'lib/images/black-rook.png'
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook, 
      isWhite: true, 
      imagePath: 'lib/images/black-rook.png'
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook, 
      isWhite: true, 
      imagePath: 'lib/images/black-rook.png'
    );
    //Place knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: false, 
      imagePath: 'lib/images/black-knight.png'
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: false, 
      imagePath: 'lib/images/black-knight.png'
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: true, 
      imagePath: 'lib/images/black-knight.png'
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: true, 
      imagePath: 'lib/images/black-knight.png'
    );
    //Place bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: false, 
      imagePath: 'lib/images/black-bishop.png'
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: false, 
      imagePath: 'lib/images/black-bishop.png'
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: true, 
      imagePath: 'lib/images/black-bishop.png'
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: true, 
      imagePath: 'lib/images/black-bishop.png'
    );
    //Place queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen, 
      isWhite: false, 
      imagePath: 'lib/images/black-queen.png'
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.queen, 
      isWhite: true, 
      imagePath: 'lib/images/black-queen.png'
    );
    //Place Kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king, 
      isWhite: false, 
      imagePath: 'lib/images/black-king.png'
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen, 
      isWhite: true, 
      imagePath: 'lib/images/black-king.png'
    );

    board = newBoard;
  }

  //USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      //selected a piece if there is a piece in that position
      if (board[row][col] != null){
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      //if there is a piece selected and user taps on a square that is a valid move, move there
      else if (selectedPiece != null && 
          validMoves.any((element) => element[0] == row && element[1] == col)){
        movePiece(row, col);
      }

      //if a piece is selected, calculate it's move
      validMoves = calculateRawValidMoves(selectedRow, selectedCol, selectedPiece);
    });
  }

  //Calculate Raw valid moves
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece){
    List<List<int>> candidateMoves = [];

    if (piece == null){
      return[];
    }

    //different directions based on their color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        //pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
              candidateMoves.add([row + direction, col]);
            }

        //pawns can move 2 squares forward if they are at their initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)){
          if (isInBoard(row + 2 * direction, col) && 
              board[row + 2 * direction][col] == null && 
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction,col]);
          }
        }

        //pawns can kill diagonally
        if (isInBoard(row + direction, col - 1) && 
            board[row + direction][col - 1] != null && 
            board[row + direction][col - 1]!.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) && 
            board[row + direction][col + 1] != null && 
            board[row + direction][col + 1]!.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        //horizontal and vertical directions
        var directions = [
          [-1,0], //up
          [1,0], //down
          [0,-1], //left
          [0,1], //right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true){
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newRow, newCol]); //kill
              }
              break; //blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
      //all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], //down 1 right 2
          [2, -1], //down 2 left 1
          [2, 1], //down 2 right 1  
        ];

        for (var move in knightMoves){
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
        // diagonal directions
        var directions = [
          [-1, -1], // up left
          [-1, 1],  // up right
          [1, -1],  // down left
          [1, 1]    // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        // all eight directions: up, down, left, right, and 4 diagonals
        var directions = [
          [-1, 0],   // up
          [1, 0],  // down
          [0, -1],  // left
          [0, 1],   // right
          [-1, -1], // up left
          [-1, 1],  // up right
          [1, -1],  // down left
          [1, 1]    // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;     
      case ChessPieceType.king:
        //all eight directions
        var directions = [
          [-1, 0],   // up
          [1, 0],  // down
          [0, -1],  // left
          [0, 1],   // right
          [-1, -1], // up left
          [-1, 1],  // up right
          [1, -1],  // down left
          [1, 1]    // down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null){
            if (board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        } 


        break;   
      default:
    }

    return candidateMoves;
  }

  //MOVE PIECE
  void movePiece(int newRow, int newCol){
    //move the piece and clear de old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
        itemCount: 8 * 8,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemBuilder: (context, index){

          // get the row and col position of the square
          int row = index ~/ 8;
          int col = index % 8;

          //check if this square is selected
          bool isSelected = selectedRow == row && selectedCol == col;

          //check if this square is a valid move
          bool isValidMove = false;
          for (var position in validMoves){
            //compare row and col
            if (position[0] == row && position[1] == col){
              isValidMove = true;
            }
          }

          return Square(
            isWhite: isWhite(index),
            piece: board[row][col],
            isSelected: isSelected,
            isValidMove: isValidMove,
            onTap: () => pieceSelected(row, col),
          );
        },
      ),
    );
  }
}