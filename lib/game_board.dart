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

          return Square(
            isWhite: isWhite(index),
            piece: board[row][col],
            isSelected: isSelected,
            onTap: () => pieceSelected(row, col),
          );
        },
      ),
    );
  }
}