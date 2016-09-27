import java.util.ArrayList;
import java.util.List;

public class AlphaBeta {
	private int displayAlpaBeta; 		// trace results
	private int stepSize;				// steps to look ahead.
	private static final int NEGINF = -1000;
	private static final int POSINF = 1000;
	private int alpha = NEGINF;
	private int beta = POSINF;

	public void run(Othello state, int difficulty, int display) {
		System.out.println("Difficul " + difficulty);
		this.stepSize =  (difficulty + 3);
		this.displayAlpaBeta = display;
		System.out.println("  ... Computing ... ");
		Othello solution = abSearch(state, stepSize, alpha, beta, "X");
		displayBoard(solution);
		
		List<Othello> path = new ArrayList<Othello>();
		while(solution != null) {	// put all the states into the list
			path.add(solution);
			solution = solution.getParentNode();
		}
		
		// A.I has no more turn
		if(path.size() > 1) {
			int nextMoveIdx = path.size() - 2;
			Othello nextMove = path.get(nextMoveIdx);
			System.out.println("     A.I. Input\n  [X : " + (nextMove.x+1) + 
					" | Y : " + (nextMove.y+1) + "]\n");
			state.updateBoard(nextMove.x, nextMove.y ,"X");	
		} 
	}

	private Othello abSearch(Othello state, int depth, int alpha, int beta, String turn) {
		List<Othello> subTree = state.buildSubTree(turn, depth); // build subtree for each level
		if (depth == 0 || subTree.isEmpty()) { 		// bottom of the tree
			return state; 
		} else if (turn.equals("X")) { 				// Maximizer turn
			for (Othello child : subTree) {
				Othello state2 = abSearch(child, depth-1, alpha, beta, "O"); // making X children
				if (state2.getV() > alpha) {
					state = state2;
					alpha = state2.getV();
				}
				if (beta <= alpha) 
					break; 							// prune: Minimizer won't take it
			}  return state;
		} else { 									// Minimizer turn
			for (Othello child : subTree) {
				Othello state2 = abSearch(child, depth-1, alpha, beta, "X");
				if (state2.getV() < beta) {
					state = state2;
					beta = state2.getV();
				} 
				if (alpha >= beta) 
					break;							// prune: Maximizer won't take it
			} return state;
		}
	}

	private void displayBoard(Othello solution) {
		if (displayAlpaBeta == 1) {
			// trace back to the root
			List<Othello> path = new ArrayList<Othello>();
			while(solution != null) {	// put all the states into the stack
				path.add(solution);
				solution = solution.getParentNode();
			}
			System.out.println("\n#### Alpha-Beta Rsearch Result START ####");
			System.out.println("   Look ahead steps : " + (path.size()-2));
			for (Othello elmt : path) {
				System.out.println("-----------------------");
				System.out.println("   Turn[" + elmt.turn + "]");
				System.out.println("   Fit Score[" + elmt.getV() + "]");
				System.out.print(" x ");
				for (int j = 0; j < elmt.boardSZ; j++)
					System.out.print((j+1) + " ");
				System.out.println("y");
				for (int i = 0; i < elmt.boardSZ; i++) {
					System.out.print("  ");
					for (int j = 0; j < elmt.boardSZ; j++) {
						System.out.print("|");
						System.out.print(elmt.board[i][j]);
					} System.out.println("|" + (i+1));
				} 
			} System.out.println("#### Alpha-Beta Search Result END ####\n");
		}
	}
}

