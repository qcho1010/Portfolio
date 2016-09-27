import java.util.Scanner;

public class Main {
	public static int boardSZ;
	public static String [][] board;
	public static String turn = "O";
	public static int start = 0, singleMulti = 0, difficulty = 0, display = 0;
	public static int x = 0, y = 0;
	public static int isOver = 1;
	
	public static void main(String[] args) {
		gameInit(); 		// initialization
		gameStart();		// start game
	}

	private static void gameInit() {
		Scanner in = new Scanner(System.in);

		// Setting board size
		do {
			System.out.println("   Enter Board Size\n   (6 ~ 10) ex) 6 for 6 x 6");
			try {boardSZ = Integer.parseInt(in.nextLine());} catch (Exception e){}
			if (boardSZ > 10 || 6 > boardSZ) 
				System.out.println("   Invalid Input");
			else {
				board = new String [boardSZ][boardSZ];
				boardInit();	// Initialize the board
			}
		} while(boardSZ > 10 || 6 > boardSZ);
		
		// Setting Single or Multiplay
		do {
			System.out.println("   Single Play : 1\n    Multi Play : 2");
			try {singleMulti = Integer.parseInt(in.nextLine());} catch (Exception e){}
			if (singleMulti > 2 ||  1 > singleMulti)
				System.out.println("   Invalid Input");
		} while(singleMulti > 2 ||  1 > singleMulti);

		// A.I. setting
		if (singleMulti == 1) {
			do {
				System.out.println("   Display A.I. result\n    yes : 1  no : 2");
				try {display = Integer.parseInt(in.nextLine());} catch (Exception e){}
				if (display > 2 ||  1 > display)
					System.out.println("   Invalid Input");
			} while(display > 2 ||  1 > display);
			do {
				System.out.println("   Human Start First? \n    yes : 1  no : 2");
				try {start = Integer.parseInt(in.nextLine());} catch (Exception e){}
				if (start == 1) turn = "O";
				else if (start == 2) turn = "X";
				else System.out.println("   Invalid Input");
			} while(start > 2 ||  1 > start);
			do {
				System.out.println("   Set A.I. difficulty\n   (1 ~ 5)");
				try {difficulty = Integer.parseInt(in.nextLine());} catch (Exception e){}
				if (difficulty > 5 || 1 > difficulty) 
					System.out.println("   Invalid Input");
			} while (difficulty > 5 || 1 > difficulty);
		}
	}

	private static void gameStart() {
		Scanner in = new Scanner(System.in);
		
		System.out.println("\n###########################");
		System.out.println("\tGAME START");
		System.out.println("###########################");
		
		Othello othello = new Othello(board, turn);
		AlphaBeta ABsearch = new AlphaBeta();
		othello.displayBoard(turn);
		while(isOver != 0) {
			System.out.println(" +++ Turn[" + turn + "] +++ \n");
			
			if (turn.equals("X")) {
				if (singleMulti == 1) {
					ABsearch.run(othello, difficulty, display);
				} else 
					nextMove(othello);
				othello.displayBoard("O");
			} else {
				nextMove(othello);
				othello.displayBoard("X");
			}
			
			// check if the game is over or tie
			isOver = othello.checkWin(turn);
			if (isOver == 1) {			// switch turn
				if (turn.equals("O")) turn = "X";
				else turn = "O"; 
			} else if (isOver == 2) { 	// No more place, keep turn
				othello.displayBoard(turn);
				isOver = othello.checkWin(turn);
				if (isOver == 2) {		// still no place, calculate the result
					othello.checkScore();
					isOver = 0;
				}
			} othello.displayScore();
		}
	}
	
	
	private static void nextMove(Othello othello) {
		Scanner in = new Scanner(System.in);
		do {
	        System.out.print("  Enter x  ");
	        try {x = Integer.parseInt(in.nextLine());} catch (Exception e){}
			System.out.print("  Enter y  ");
			try {y = Integer.parseInt(in.nextLine());} catch (Exception e){}
		} while(!othello.isValid((x-1), (y-1)));
		othello.updateBoard((x-1), (y-1), turn);
	}


	private static void boardInit () {
		for (int j = 0; j < boardSZ; j++)
			for (int i = 0; i < boardSZ; i++)
				board[i][j] = " ";
		board[(boardSZ/2)-1][(boardSZ/2)-1] = "O"; 
		board[(boardSZ/2)-1][boardSZ/2] = "X";
		board[boardSZ/2][(boardSZ/2)-1] = "X"; 
		board[boardSZ/2][boardSZ/2] = "O";
		board[1][1] = "*";
	}
}
