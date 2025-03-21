enum ChessPieceType {pawn, rook, knight, bishop, queen, king} //enum sirve para especificar diferente tipos de cosas

class ChessPiece{ //clase de las piezas
  final ChessPieceType type; //tipo
  final bool isWhite; //color
  final String imagePath; //imagen

  //constructor
  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  }); //constructor
}
