import 'package:flutter/material.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/values/colors.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isValidMove;
  final bool isSelected;
  final void Function()? onTap;

  const Square({super.key ,
    required this.isWhite,
    required this.piece ,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;


    //if selected ,square is green

    if(isSelected){
      squareColor =Colors.green;
    }
    else if (isValidMove) {
      squareColor =Colors.green[300];
    }

    //otherwise,it`s white or grey
    else {
      squareColor = isWhite ? foregroundColor: backgroundColor;
    }



    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 8 : 0),
        child: piece != null
            ? Image.asset(
            piece!.imagePath,
          color: piece! .isWhite? Colors.white :Colors.black,

        )
            :null,

      ),
    );
  }
}