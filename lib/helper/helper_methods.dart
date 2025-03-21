bool isWhite(int index) {
  int x = index ~/ 8; //this gives us the integer division row
  int y = index % 8; //this gives us the remainer column

  //alternar colores por cada cuadro
  bool isWhite = (x + y) % 2 ==0;

  return isWhite;
}

//Alterna los colores de las casillas en un patrón de tablero de ajedrez
bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8; //verifica que todo dentro del tablero
}