import 'dart:isolate';

import 'package:ajedrez_flutter/components/piece.dart';
import 'package:ajedrez_flutter/components/square.dart';
import 'package:ajedrez_flutter/helper/helper_methods.dart';
import 'package:ajedrez_flutter/values/colors.dart';
import 'package:flutter/material.dart';

import 'components/dead_piece.dart';

//Tablero
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
  int selectedRow = -1; //valor de -1 para inidar que no se ha seleccionado nada

  //The column index of the selected piece
  //Default value -1 indicated no piece is currently selected;
  int selectedCol = -1;

  //A list of valid moves for the currently selected piece
  //each move is represented as a list with 2 elements: row and col
  List<List<int>> validMoves = [];

  //Lista de piezas blancas que han muerto por el negro
  List<ChessPiece> whitePiecesTaken = [];

  //Lista de piezas negras que han muerto por el blanco
  List<ChessPiece> blackPiecesTaken = [];

  // A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  //initial position of kings (keep track of this to make it easier later to see if king in in check)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;


  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //INITIALIZE BOARD / INITIAL POSITIONS
  void _initializeBoard(){
    //Initialize the board with the nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard = 
      List.generate(8, (index) => List.generate(8, (index) => null));

    
    //Place pawns  
    for (int i = 0; i < 8; i++){ //bucle para los 8 peones
      newBoard[1][i] = ChessPiece( //colocar en la segunda fila
        type: ChessPieceType.pawn, 
        isWhite: false, 
        imagePath: 'lib/images/black-pawn.png'
        );
      newBoard[6][i] = ChessPiece( // colocar en la fila de abajo
        type: ChessPieceType.pawn, 
        isWhite: true, 
        imagePath: 'lib/images/black-pawn.png'
        );
    }

    //Place rooks
    newBoard[0][0] = ChessPiece( //posicion arriba izquierda
      type: ChessPieceType.rook, 
      isWhite: false, 
      imagePath: 'lib/images/black-rook.png'
    );
    newBoard[0][7] = ChessPiece( //arribaa derecha
      type: ChessPieceType.rook, 
      isWhite: false, 
      imagePath: 'lib/images/black-rook.png'
    );
    newBoard[7][0] = ChessPiece( //abajo izquiera
      type: ChessPieceType.rook, 
      isWhite: true, 
      imagePath: 'lib/images/black-rook.png'
    );
    newBoard[7][7] = ChessPiece( //abajo derecha
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
    newBoard[7][3] = ChessPiece(
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
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king, 
      isWhite: true, 
      imagePath: 'lib/images/black-king.png'
    );

    board = newBoard; //actulizar el nuevo tablero
  }
 
  //USER SELECTED A PIECE / Queremos saber que se está seleccionando
  void pieceSelected(int row, int col) {
    setState(() {
      //No piece has been selected yet, this is the first selection
      if (selectedPiece == null && board[row][col] != null){
        if (board[row][col]!.isWhite == isWhiteTurn){
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      //Ther is a piece already selected, but user can select another one of their pieces
      else if (board[row][col] != null && 
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
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
      validMoves = 
        calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
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
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) && 
            board[row + direction][col + 1] != null && 
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
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
          while (true){ //usar un while para obtener cada cuadrado hasta que le demos a algo
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
              candidateMoves.add([newRow, newCol]); //kill
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
                candidateMoves.add([newRow, newCol]); // kill
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
                candidateMoves.add([newRow, newCol]); //kill
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
              candidateMoves.add([newRow, newCol]); //kill
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        } 

        break;   
      
    }

    return candidateMoves;
  }

  
  //Calculate Real Valid Moves
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece); 

    //after generating all cadidate moves, filter out any that would result in a check
    if (checkSimulation){
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        //this will simulate the future move to see is its safe
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)){
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }
  
  //MOVE PIECE
  void movePiece(int newRow, int newCol){

    //if the new spot has an enemy piece
    if (board[newRow][newCol] != null){
      //add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite){
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    //check if the piece being moved is a king
    if (selectedPiece!.type == ChessPieceType.king){
      //update the appropriate king pos
      if (selectedPiece!.isWhite){
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    //move the piece and clear de old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //see if any kings are under attack
    if (isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    //check is its check mate
    if (isCheckMate(!isWhiteTurn)){
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: const Text("CHECK MATE!"),
          actions: [
            //play again button
            TextButton(
              onPressed: resetGame, 
              child: const Text("Play Again"),
            ),
          ],
        )
      );
    }

    //Change turns
    isWhiteTurn = !isWhiteTurn;
  }

  //IS KING IN CHECK?
  bool isKingInCheck(bool isWhiteKing){
    //get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    //check is any enemy piece can attack the king
    for (int i = 0; i < 8; i++){
      for (int j = 0; j < 8; j++){
        //skip empty squares and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves = 
          calculateRealValidMoves(i, j, board[i][j], false);

        //check if the kings position is in this pieces valid moves
        if (pieceValidMoves.any((move) => 
            move[0] == kingPosition[0] && move[1] == kingPosition[1])){
          return true;
        }
      }
    }

    return false;
  }

  
  //Simulate a future move to see if its safe (Doesnt put your own king under attack!)
  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol){
    //save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    //if th piece is the king, save its current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king){
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      //update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    //simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check if our king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    //restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    //if the piece was the king, restore it original position
    if (piece.type == ChessPieceType.king){
      if (piece.isWhite){
        whiteKingPosition = originalKingPosition!;
      } else{
        blackKingPosition = originalKingPosition!;
      }
    }

    //if king is in check = true, means its not a sofe move. safe move = false
    return !kingInCheck;
  }
  
  //IS IT CHECK MATE?
  bool isCheckMate(bool isWhiteKing){
    //if the king is not in check, then its not checkmate
    if (!isKingInCheck(isWhiteKing)){
      return false;
    }

    //if there is at least one legal move for any of the other players, then its not checkmate
    for (int i = 0; i < 8; i++){
      for (int j = 0; j < 8; j++){
        //skip empty squares and pieces of the other color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMOves =
            calculateRealValidMoves(i, j, board[i][j], true); 

        //if this piece has any valid moves, then its not checkmate
        if (pieceValidMOves.isNotEmpty){
          return false;
        }  
      }
    } 

    //if none of the above conditions are met, then there are no legal moves left to make
    // its check mate!
    return true;
  }

  //Reset to new game
  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          
          //WHITE PIECES TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: 
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),


          //GAME STATUS
          Text(checkStatus ? "CHECK!" : ""),

          //CHESS BOARD
          Expanded(
            flex: 6,
            child: GridView.builder(
              //8 x 8 = 64 casillas
              itemCount: 8 * 8,
              //Desactiva el desplaziento del grid
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              //Define la cuadrícula con 8 columnas
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index){
            
                //calcula la fila de la celda
                int row = index ~/ 8;
                //calcula la columna de la celda
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
          ),

          //BLACK PIECES TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              gridDelegate: 
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),   
          ),
        ],
      ),
    );
  }
}