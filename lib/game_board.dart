import 'package:chess/components/dead_pieces.dart';
import 'package:flutter/material.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:chess/values/colors.dart';


class HomeBoard extends StatefulWidget {
  const HomeBoard({super.key});

  @override
  State<HomeBoard> createState() => _HomeBoardState();
}

class _HomeBoardState extends State<HomeBoard> {

  late List<List<ChessPiece?>> board ;


  //The Currently selected piece on the chess board
  //if no piece is selected, this is null
  ChessPiece? selectedPiece;


  //The row index of the selected piece
  //default value -1 indicated no piece is currently selected
  int selectedRow = -1 ;

  //The col index of the selected piece
  //default value -1 indicated no piece is currently selected
  int selectedcol = -1 ;

  //A list of valid moves  for the currently selected  piece
  // each move is represented as alist with 2 elements : row and col
  List<List<int>>validMoves = [];

  // A list of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken = [];

  // A list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken = [];

  //A boolean to indicate who`s turn it is
  bool isWhiteTurn= true;

  //initial  position of kings {keep track of this to make it easier later to see if king is in check}
  List<int> whiteKingPosition = [7,3];
  List<int> blackKingPosition = [0,3];
  bool checkStatus=false;


  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }


  // initialize board
  void _initializeBoard (){
    List<List<ChessPiece?>> newBoard =List.generate(8, (index) => List.generate(8,(index)=>null));

    // //place random piece in middle to test
    // newBoard[3][3] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath:'lib/images/rook.png');



    //place pawn
    for(int i=0; i <8 ; i++){
      newBoard[1][i] =ChessPiece(type: ChessPieceType.pawn, isWhite: false, imagePath: 'lib/images/pawn.png');
      newBoard[6][i] =ChessPiece(type: ChessPieceType.pawn, isWhite: true, imagePath: 'lib/images/pawn.png');
    }

    //place rook
    newBoard[0][0] =ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'lib/images/rook.png');
    newBoard[0][7] =ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'lib/images/rook.png');
    newBoard[7][0] =ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images/rook.png');
    newBoard[7][7] =ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images/rook.png');

    //place knight
    newBoard[0][1] =ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'lib/images/knight.png');
    newBoard[0][6] =ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'lib/images/knight.png');
    newBoard[7][1] =ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'lib/images/knight.png');
    newBoard[7][6] =ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'lib/images/knight.png');


    //place bishop
    newBoard[0][2] =ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'lib/images/bishop.png');
    newBoard[0][5] =ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'lib/images/bishop.png');
    newBoard[7][2] =ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'lib/images/bishop.png');
    newBoard[7][5] =ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'lib/images/bishop.png');


    //place king

    newBoard[0][3] =ChessPiece(type: ChessPieceType.king, isWhite: false, imagePath: 'lib/images/king.png');
    newBoard[7][3] =ChessPiece(type: ChessPieceType.king, isWhite: true, imagePath: 'lib/images/king.png');


    //place queen

    newBoard[0][4] =ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: 'lib/images/queen.png');
    newBoard[7][4] =ChessPiece(type: ChessPieceType.queen, isWhite: true, imagePath: 'lib/images/queen.png');



    board = newBoard;

  }



  //User selected a piece
  void pieceSelected(int row , int col){
    setState(() {
      //No piece has selected yet , This is the first selection
      if(selectedPiece==null && board[row][col]!=null){
        if(board[row][col]!.isWhite ==isWhiteTurn){
          selectedPiece=board[row][col];
          selectedRow=row;
          selectedcol=col;
        }
      }


      //there is apiece already selected, but user can select another one of their pieces
      else if (board[row][col]!=null && board[row][col]!.isWhite == selectedPiece!.isWhite){
        selectedPiece=board[row][col];
        selectedRow=row;
        selectedcol=col;
      }

      //if there a piece selected and user taps on a square that is a valid move , move there
      else if (selectedPiece !=null && validMoves.any((element) => element[0]== row && element[1] == col)){
        movePiece(row, col);
      }

      // if a piece is selected , calculate it`s valid moves
      validMoves = calculateRealValidMoves(selectedRow,selectedcol,selectedPiece,true);
    });
  }



  //calculate raw valid moves
  List<List<int>> calculateRawValidMoves(int row ,int col ,ChessPiece? piece){
    List<List<int>> candidateMoves = [];

    if(piece == null){
      return [];
    }
    // different directions based on their color
    int direction = piece.isWhite? -1 : 1;
    switch(piece.type){
      case ChessPieceType.pawn:
        //pawn can move forward if the square is not occupied
          if (isInBoard(row+direction,col) && board[row+direction][col]==null){
            candidateMoves.add([row + direction,col]);
          }

        //pawns can move 2 squares forward if they are at  their initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && !piece.isWhite)){
          if(isInBoard(row + 2 * direction , col)&& board [row+2*direction][col]==null
          && board [row+direction][col]==null
          ){
            candidateMoves.add([row+2*direction,col]);
          }
        }

        //pawns can kill diagonally
          if (isInBoard(row + direction , col - 1) &&
              board[row+direction][col - 1]!=null &&
              board[row+direction][col - 1]!.isWhite != piece.isWhite
          ){
            candidateMoves.add([row + direction, col -1]);
          }
          if (isInBoard(row + direction , col + 1) &&
              board[row+direction][col + 1]!=null &&
              board[row+direction][col + 1]!.isWhite != piece.isWhite
          ){
            candidateMoves.add([row + direction, col + 1]);
          }


        break;
      case ChessPieceType.rook:
        //horizontal and vertical directions
        var directions = [
          [-1,0],   // up
          [1,0],   // down
          [0,-1], //left
          [0,1], // right
        ];

        for(var direction in directions){
          var i = 1;
          while (true){
            var newRow = row + i * direction[0];
            var newcol = col + i * direction[1];
            if(!isInBoard(newRow, newcol)){
              break;
            }
            if (board[newRow][newcol]!= null){
              if (board[newRow][newcol] !.isWhite !=piece.isWhite ){
                candidateMoves.add([newRow,newcol]); //kill
              }
              break; //blocked
            }
            candidateMoves.add([newRow,newcol]);
            i++;
          }
        }

        break;
      case ChessPieceType.knight:
        //all eight possible L shapes the knight can move
      var knightMove =[
        [-2,-1], //up 2 left 1
        [-2,1], //up 2 right 1
        [-1,-2], //up 1 left 2
        [-1,2],//up 1 right 2
        [1,-2], // down 1 left 2
        [1,2], // down 1 right 2
        [2,-1], //down 1 left 2
        [2,1], // down 1 right 2
      ];

      for (var move in knightMove){
        var newRow = row + move[0];
        var newCol = col + move[1];
        if (!isInBoard(newRow, newCol )){
          continue;
        }
        if (board[newRow][newCol]!=null){
          if(board[newRow][newCol] !.isWhite != piece.isWhite){
            candidateMoves.add([newRow,newCol]); // capture
          }
          continue; // kill
        }
        candidateMoves.add([newRow,newCol]);
      }


        break;
      case ChessPieceType.bishop:
        //diagonal direction
      var directions = [
        [-1,-1], //up left
        [-1,1], //up right
        [1,-1], //down left
        [1,1], //down right
      ];
      for (var direction in directions){
        var i =1 ;
        while(true){
          var newRow = row + i * direction[0];
          var newCol = col + i * direction[1];
          if (!isInBoard(newRow,newCol)){
            break;
          }
          if (board[newRow][newCol]!=null){
            if (board [newRow][newCol]!.isWhite !=piece.isWhite){
              candidateMoves.add([newRow,newCol]); // capture
            }
            break; //block
          }
          candidateMoves.add([newRow,newCol]);
          i++;
        }
      }


        break;
      case ChessPieceType.king:
        //all eight directions up,down,left,right
        var directions = [
          [-1,0], //up
          [1,0], //down
          [0,-1], //left
          [0,1], //right
          [-1,-1], //up left
          [-1,1], // up right
          [1,-1], // down left
          [1,1], // down right
        ];
        for (var direction in directions){
          var i = 1;
          while(true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow,newCol)){
              break;
            }
            if (board[newRow][newCol]!=null){
              if (board [newRow][newCol]!.isWhite !=piece.isWhite){
                candidateMoves.add([newRow,newCol]); // capture
              }
              break; //block
            }
            candidateMoves.add([newRow,newCol]);
            i++;
          }
        }


        break;
      case ChessPieceType.queen:
      //all eight directions
        var directions = [
          [-1,0], //up
          [1,0], //down
          [0,-1], //left
          [0,1], //right
          [-1,-1], //up left
          [-1,1], // up right
          [1,-1], // down left
          [1,1], // down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol]!=null){
            if (board [newRow][newCol]!.isWhite !=piece.isWhite){
              candidateMoves.add([newRow,newCol]); // capture
            }
            continue; //block
          }
          candidateMoves.add([newRow,newCol]);
        }

        break;
      default:
    }

    return candidateMoves;

  }




  //calculate real valid move
  List<List<int>> calculateRealValidMoves(int row ,int col ,ChessPiece? piece,bool checkSimulation){
    List<List<int>> realValidMove=[];
    List<List<int>> candidateMove= calculateRawValidMoves(row, col, piece);

    //after generating all candidate moves , filter out any that would result in a check
    if (checkSimulation){
      for (var move in candidateMove){
        int endRow = move[0];
        int endCol = move[1];


        //this is will simulate the future move to see if it`s safe
        if (simulatedMoveIsSafe(piece!,row,col,endRow,endCol)){
          realValidMove.add(move);
        }
      }
    }else{
      realValidMove =candidateMove;
    }
    return realValidMove;
  }




  //move piece
  void movePiece(int newRow, int newCol){

    //if the new spot has an enemy piece
    if(board[newRow][newCol]!=null){
      // add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if(capturedPiece!.isWhite){
        whitePiecesTaken.add(capturedPiece);
      }else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    //Check if the piece being moved in a king
    if (selectedPiece!.type ==ChessPieceType.king){
      //update the appropriate king position
      if(selectedPiece!.isWhite){
        whiteKingPosition=[newRow,newCol];
      }else{
        blackKingPosition=[newRow,newCol];
      }
    }




    //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedcol] = null ;


    //see if any kings are under attack
    if(isKingInCheck(isWhiteTurn)){
      checkStatus = true;

    }else{
      checkStatus=false;
    }



    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedcol = -1;
      validMoves = [];
    });

    //check if it`s checkmate
    if (isCheckMate(!isWhiteTurn))  {
      showDialog(context: context,
          builder: (context)=> AlertDialog(
            title: const Text("CHECK MATE!"),
            actions: [
              //play again button
              TextButton(onPressed: resetGame,
                  child: const Text("Play Again")),
            ],
          ));
    }


    //change turn
    isWhiteTurn=!isWhiteTurn;


  }



  // Is King In Check?
  bool isKingInCheck(bool isWhiteKing){
    //get the position of the king
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition ;

    //check if any enemy can attack the king
    for(int i = 0 ; i < 8 ; i++ ){
      for(int j = 0 ; j < 8 ; j++){
        //skip empty squares and pieces of the same color as the king
        if(board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j],false);

        //check if the king`s position is in this piece`s valid moves
        if(pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] ==kingPosition[1] )){
          return true;
        }

      }
    }

    return false;
  }



  //Simulate a future move to see if it`s Safe or (Does`nt put your king under attack)
  bool simulatedMoveIsSafe(ChessPiece piece , int startRow , int startCol , int endRow , int endCol){
    //save the current board state
    ChessPiece? originalDestinationPiece =board[endRow][endCol];

    //if the piece is the king , save it`s current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type== ChessPieceType.queen){
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

      //update the king position
      if (piece.isWhite){
        whiteKingPosition =[endRow,endCol];
      }else{
        blackKingPosition =[endRow,endCol];
      }
    }

    //simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check if our own king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);


    //restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;


    //if the piece was the king , restore it to original position
    if (piece.type == ChessPieceType.queen){
      if (piece.isWhite){
        whiteKingPosition = originalKingPosition!;
      }else {
        blackKingPosition = originalKingPosition!;
      }

    }

    //if king is in check = true , means it`s not safe move. safe move = false
    return !kingInCheck;
  }


  //is it check mate
  bool isCheckMate(bool isWhiteKing){
    //if the king is not in check , then it`s not checkmate
    if (!isKingInCheck(isWhiteKing)){
      return false;
    }

    //if there is at least one legal move for any of the player`s pieces then it`s not a checkmate
    for (int i = 0 ; i < 8 ; i++){
      for (int j =0 ; j < 8 ; j++){
        //skip empty squares and pieces of the other color
        if (board[i][j]==null || board[i][j]!.isWhite !=isWhiteKing){
          continue;
        }
        List<List<int>>pieceValidMove = calculateRealValidMoves(i, j, board[i][j], true);

        //if this piece has any valid moves , then it`s not checkmate
        if(pieceValidMove.isNotEmpty){
          return false;
        }
      }
    }

    //if none of the above conditions are met , then there are no legal moves left to make it`s checkmate
    return true;


  }


  //reset to new game
  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus=false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7,3];
    blackKingPosition = [0,3];
    setState(() {

    });

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: backgroundColor,
      body: Column(
        children: [
          //white pieces taken
          Expanded(
              child:
          GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context,index)=> DeadPieces(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
          ),
          ),


          //Game status
          Text(
            checkStatus ? "CHECK!" : ""
          ),



          //chess board
          Expanded(
            flex: 3,
              child: Container(
                decoration:  BoxDecoration(
                  border: Border.all(color: Colors.black,
                    width: 5,
                  ),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 40),
                    itemCount: 8 * 8,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                    itemBuilder: (context , index){

                      //get the row and col position of this square
                      int row = index ~/ 8 ;
                      int col = index % 8 ;

                      //check if this square is selected
                      bool isSelected = selectedRow == row && selectedcol ==col;

                      //check if this square is a valid move
                      bool isValidMove =false;
                      for (var position in validMoves){

                      //compare row and col
                        if (position[0] == row && position[1] == col){
                          isValidMove =true;
                        }
                      }

                      return Square(
                        isWhite: isWhite(index),
                        piece:board[row][col] ,
                        isSelected: isSelected ,
                        onTap: () =>pieceSelected(row, col),
                        isValidMove:isValidMove ,

                      );
                    }
                ),
              ),

          ),

          //black pieces taken
          Expanded(child:
          GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context,index)=> DeadPieces(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ))
          )

        ],
      ),
    );
  }
}