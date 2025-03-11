enum ChessPieceType {pawn, rook, knight, bishop, queen, king} //enum sirve para especificar diferente tipos de cosas

class ChessPiece{
  final ChessPieceType type; 
  final bool isWhite;
  final String imagePath;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  }); //constructor
}
