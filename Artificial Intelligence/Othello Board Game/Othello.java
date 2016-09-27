import java.util.ArrayList;
import java.util.List;


public class Othello {
	public int boardSZ;
	public String [][] board = new String [boardSZ][boardSZ];
	public int oScore, xScore, oScore2, xScore2;
	public int x, y;
	public String turn;
	public boolean validPlace = false;
	public boolean validCheck = false;
	public boolean validRemain = false;
	public boolean cornerScore = false;
	public int sideScore;
	private Othello parentNode;

	public Othello (String[][] board, String turn) {
		this.board = board;
		this.turn = turn;
		this.boardSZ = board.length;
	}

	public void updateBoard (int x, int y, String turn) {
		this.turn = turn;
		this.x = x;
		this.y = y;
		
		board[y][x] = turn;
		checkFlip(x, y, turn);
		updateScore();
	}
	
	private void checkFlip(int x, int y, String turn) {
		// vertical down
		int tmpY = y;
		int tmpX = x;
		String oppTurn;
		if (turn.equals("X")) oppTurn = "O";
		else oppTurn = "X";
		
		// vertical down
		while (++tmpY < (boardSZ-1) && board[tmpY][tmpX].equals(oppTurn)) {
			if (board[tmpY+1][tmpX].equals(turn)) {
				if (validCheck) {
					validPlace = true;
					break;
				}
				if (isCorner()) 
					cornerScore = true;
				while (tmpY >= y) {
					if (isSide(tmpX, tmpY)) 
						sideScore++;
					board[tmpY--][tmpX] = turn;
				} break;
			} 
		}
		// vertical up
		tmpY = y;
		tmpX = x;
		while (--tmpY > 0 && board[tmpY][tmpX].equals(oppTurn)) { 
			if (board[tmpY-1][tmpX].equals(turn)) {
				if (validCheck) {
					validPlace = true;
					break;
				}
				if (isCorner()) 
					cornerScore = true;
				while (tmpY <= y) {
					if (isSide(tmpX, tmpY)) 
						sideScore++;
					board[tmpY++][tmpX] = turn;
				} break;
			}
		}
		// horizontal right
		tmpY = y;
		tmpX = x;
		while (++tmpX < (boardSZ-1) && board[tmpY][tmpX].equals(oppTurn)) {
			if (board[tmpY][tmpX+1].equals(turn)) {
				if (validCheck) {
					validPlace = true;
					break;
				}
				if (isCorner()) 
					cornerScore = true;
				while (tmpX >= x) {
					if (isSide(tmpX, tmpY)) 
						sideScore++;
					board[tmpY][tmpX--] = turn;
				} break;  
			} 
		}
		// horizontal left
		tmpY = y;
		tmpX = x;
		while (--tmpX > 0 && board[tmpY][tmpX].equals(oppTurn)) {
			if (board[tmpY][tmpX-1].equals(turn)) {
				if (validCheck) {
					validPlace = true;
					break;
				}
				if (isCorner()) 
					cornerScore = true;
				while (tmpX <= x) {
					if (isSide(tmpX, tmpY)) 
						sideScore++;
					board[tmpY][tmpX++] = turn;
				} break;
			} 
		}
		// diagonal right down
		tmpY = y;
		tmpX = x;
		while (++tmpX < (boardSZ-1) && ++tmpY < (boardSZ-1) 
				&& board[tmpY][tmpX].equals(oppTurn)) {
			if (board[tmpY+1][tmpX+1].equals(turn)) {
				if (validCheck) {
					validPlace = true;
					break;
				}
				if (isCorner()) 
					cornerScore = true;
				while (tmpY >= y && tmpX >= x) {
					if (isSide(tmpX, tmpY)) 
						sideScore++;
					board[tmpY--][tmpX--] = turn;
				} break;
			} 
		}
		// diagonal left down
		tmpY = y;
		tmpX = x;
		while (--tmpX > 0 && ++tmpY < (boardSZ-1) 
				&& board[tmpY][tmpX].equals(oppTurn)) {
			if (board[tmpY+1][tmpX-1].equals(turn)) {
				if (validCheck) {
					validPlace = true;
					break;
				}
				if (isCorner()) 
					cornerScore = true;
				while (tmpY >= y && tmpX <= x) {
					if (isSide(tmpX, tmpY)) 
						sideScore++;
					board[tmpY--][tmpX++] = turn;
				} break;
			} 
		}
		// diagonal right up
		tmpY = y;
		tmpX = x;
		while (++tmpX < (boardSZ-1) && --tmpY > 0 
				&& board[tmpY][tmpX].equals(oppTurn)) {
			if (board[tmpY-1][tmpX+1].equals(turn)) {
				if (validCheck) {
					validPlace = true;
					break;
				}
				if (isCorner()) 
					cornerScore = true;
				while (tmpY <= y && tmpX >= x) {
					if (isSide(tmpX, tmpY)) 
						sideScore++;
					board[tmpY++][tmpX--] = turn;
				} break;
			} 
		}
		// diagonal left up
		tmpY = y;
		tmpX = x;
		while (--tmpX > 0 && --tmpY > 0 
				&& board[tmpY][tmpX].equals(oppTurn)) {
			if (board[tmpY-1][tmpX-1].equals(turn)) {
				if (validCheck) {
					validPlace = true;
					break;
				}
				if (isCorner()) 
					cornerScore = true;
				while (tmpY <= y && tmpX <= x) {
					if (isSide(tmpX, tmpY)) 
						sideScore++;
					board[tmpY++][tmpX++] = turn;
				} break;
			} 
		}
	}
	
	private void updateScore() {
		int xCount = 0;
		int oCount = 0;
		for (int i = 0; i < boardSZ; i++) {
			for (int j = 0; j < boardSZ; j++) {
				if (board[i][j].equals("X"))
					xCount++;
				if (board[i][j].equals("O"))
					oCount++;
			}
		}
		xScore = xCount;
		oScore = oCount;
		updateExtraScore();
	}

	private void updateExtraScore() {
		if (turn.equals("X")) {
			if (cornerScore) 
				xScore2 = xScore2 + 10;
			for (int i = 0; i < sideScore; i++)
				xScore2 = xScore2 + 4;
			cornerScore = false;
			sideScore = 0;
		} else {
			if (cornerScore) 
				oScore2 = oScore2 + 10;
			for (int i = 0; i < sideScore; i++)
				oScore2 = oScore2 + 4;
			cornerScore = false;
			sideScore = 0;
		}
	}

	public void displayScore() {
		System.out.println("=====================");
		System.out.printf("   X : %d | O : %d\n", xScore, oScore);
		System.out.println("=====================");
	}
	
	public void displayBoard (String turn) {
		System.out.print(" x ");
		for (int j = 0; j < boardSZ; j++)
			System.out.print((j+1) + " ");
		System.out.println("y");

		validCheck = true; // Only checking, set 'true' to avoid fliping
		for (int i = 0; i < boardSZ; i++) {
			System.out.print("  ");
			for (int j = 0; j < boardSZ; j++) {
				if (board[i][j].equals("*"))
					board[i][j] = " ";
				if (board[i][j].equals(" "))
					checkFlip(j, i, turn);
				if (validPlace && board[i][j].equals(" ")) {
					board[i][j] = "*";
					validPlace = false;  // to avoid redundancy
					validRemain = true;
				}
				System.out.print("|");
				System.out.print(board[i][j]);
			} 
			System.out.println("|" + (i+1));
		} validCheck = false;
	}

	public void findNextMoves (String turn) {
		validCheck = true; // Only checking, set 'true' to avoid fliping
		for (int i = 0; i < boardSZ; i++) {
			for (int j = 0; j < boardSZ; j++) {
				if (board[i][j].equals("*"))
					board[i][j] = " ";
				if (board[i][j].equals(" ")) {
					if(turn.equals("X")) checkFlip(j, i, "O");
					else checkFlip(j, i, "X");
				}
				if (validPlace && board[i][j].equals(" ")) {
					board[i][j] = "*";
					validPlace = false;  // to avoid redundancy
					validRemain = true;
				}
			} 
		} validCheck = false;
	}
	
	public boolean isValid (int x, int y) {
		if (x > (boardSZ-1) || y > (boardSZ-1) || x < 0 || y < 0
				|| !board[y][x].equals("*")) {
			System.out.println("Invalid Input");
			return false;
		} return true;
	}
	
	public int checkWin(String turn) {
		if ((xScore + oScore) == boardSZ*boardSZ) { // board full
			checkScore();
			return 0;
		} else if (countPlaces() == 0) { // no more place to put 
			System.out.println("###########################");
			if (turn.equals("X")) {
				System.out.println("    No more available \n    place for Turn[O]");
				System.out.println("  Switching to Turn[X] Again");
			} else if (turn.equals("O")) {
				System.out.println("    No more available \n    place for Turn[X]");
				System.out.println("  Switching to Turn[O] Again");
			}			
			System.out.println("###########################");
			return 2;
		} return 1;
	}
	
	public void checkScore() {
		System.out.println("###########################");
		System.out.println("\tGAME OVER");
		if (xScore > oScore) 
			System.out.println("\tX Wins !!");
		else if (xScore < oScore) 
			System.out.println("\tO Wins !!");
		else if (xScore == oScore) 
			System.out.println("\t Tie!!");
		System.out.println("###########################");
	}

	public List<Othello> buildSubTree(String turn, int limit) {
		List<Othello> subTree = new ArrayList<Othello>();
		int x = 0, y = 0;
		for (ArrayList<Integer> ValidXY : getValidXY()) {
			// create new node
			Othello newNode = new Othello(getBoard(), turn);
			newNode.setParentNode(this);

			// insert new node
			subTree.add(newNode);
			
			// update board
			x = ValidXY.get(0);
			y = ValidXY.get(1);
			newNode.updateBoard(x, y, turn);
			newNode.findNextMoves(turn);
		}
		return subTree;
	}
	
	// Deep copy the immutable String object - board
	public String[][] getBoard() {
		String [][] boardCopy = new String [boardSZ][boardSZ];
		for (int i = 0; i < boardSZ; i++) {
			for (int j = 0; j < boardSZ; j++) {
				boardCopy[j][i] = board[j][i];
			}
		} return boardCopy;
	}
	
	// Saving coordinates for the valid places
	public ArrayList<ArrayList<Integer>> getValidXY () {
		ArrayList<ArrayList<Integer>> validCoord = new ArrayList<ArrayList<Integer>>();
		for (int i = 0; i < boardSZ; i++) {
			for (int j = 0; j < boardSZ; j++) {
				if (board[i][j].equals("*")) {
					ArrayList<Integer> ValidXY = new ArrayList<Integer>();
					ValidXY.add(j);
					ValidXY.add(i);
					validCoord.add(ValidXY);
				}
			}
		} return validCoord;
	}
	
	private int countPlaces() {
		int count = 0;
		for (int i = 0; i < boardSZ; i++) {
			for (int j = 0; j < boardSZ; j++) {
				if (board[i][j].equals("*"))
					count++;
			}
		} return count;
	}

	private boolean isSide(int x, int y) {
		if (x == (boardSZ-1) || y == (boardSZ-1) || x == 0 || y == 0) {
			return true;
		} return false;
	}

	private boolean isCorner() {
		if ((x == (boardSZ-1) && y == 0) 
				|| (x == 0 && y == 0) || (x == 0 && y == (boardSZ-1)) 
				|| (x == (boardSZ-1) && y == (boardSZ-1))) {
			return true;
		} return false;
	}

	public int getV() {
		return ((xScore+oScore2) - (oScore+xScore2));
	}

	public Othello getParentNode() {
		return parentNode;
	}

	public void setParentNode(Othello parentNode) {
		this.parentNode = parentNode;
	}
}
