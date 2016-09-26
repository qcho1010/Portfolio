package proj1;

import java.util.List;

public class DepthLimitedSearch{
	public State run(State problem, int limit) { // returns a solution, or failure/cutoff
		return recurDLS(problem, limit);
	}
	// This algorithm is from the book pg 88 (Artificial Intelligence A Modern Approach 3rd Edition)
	private State recurDLS(State state, int limit) {
		if (state.isGoal()) return state;			
		else if (limit == 0) return null; // recursion terminator at the bottom leaf, go back to parent
		else {
			List<State> tree = state.buildTree();
			for (State child : tree) {
				State result = recurDLS(child, limit - 1);
				if (null != result) return result; // if state hit the bottom leaf without using all the limit
			}
			return null;
		}
	}
}