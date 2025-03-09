bool isWhite(int index) {
  int x = index ~/ 8; //this gives us the integer division row
  int y = index % 8; //this gives us the remainer column

  //alternar colores por cada cuadro
  bool isWhite = (x + y) % 2 ==0;

  return isWhite;
}