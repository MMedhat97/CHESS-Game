enum ChessPieceType{bishop,king,knight,rook,pawn,queen}

class ChessPiece{
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  ChessPiece({
   required this.type,
    required this.isWhite,
    required this.imagePath,
});
}