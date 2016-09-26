package proj1;

import java.util.ArrayList;
import java.util.List;

public class Main {
	public static void main(String[] args) {
		State state;
		state = initialization();
		state = start(state);
		displayResult(state);
	}	
	// Set up the initialized state function
	public static State initialization() {
		int stateArr[];
		stateArr = new int [3];
		stateArr[0] = 3; stateArr[1] = 3; stateArr[2] = 1;
		State initialState = new State(stateArr);
		return initialState;
	}
	// Set up the limit as 20 for Depth Limited Search Algorithm
	public static State start(State state) {
		DepthLimitedSearch search = new DepthLimitedSearch();
		int limit = 11;
		State solution = search.run(state, limit);
		return solution;
	}
	// Display the result
	private static void displayResult(State solution) {
		if(solution != null) {
			List<State> path = new ArrayList<State>();
			State state = solution;
			while(state != null) {	// put all the states into the stack
				path.add(state);
				state = state.getParentNode();
			}
			int[] currentState;
			int depth = path.size() - 1;
			System.out.println("Format: all on the right side\nMissionary, Cannibal, Boat(1)");
			for (int i = depth; i >= 0; i--) {
				state = path.get(i);
				currentState = state.getcurrentState();
				for (int j = 0; j < 3; j ++) {
					System.out.printf("%d ", currentState[j]);
				}
				System.out.println("");
			}
			System.out.printf("Total depth : %d", depth);
		} else System.out.print("\nNo solution found.");
	}
}
