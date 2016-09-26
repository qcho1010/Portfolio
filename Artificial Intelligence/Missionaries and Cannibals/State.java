package proj1;

import java.util.ArrayList;
import java.util.List;

public class State {
	private int[] currentState;
	private State parentNode;
	
	public State(int[] currentState) {
		this.currentState = currentState;		
	}
	// Check if every one is moved to right side
	public boolean isGoal() {
		return (currentState[0] == 0 && currentState[1] == 0);
	}
	// This function is building tree
	public List<State> buildTree() {
		List<State> tree = new ArrayList<State>();
		int actions[];
		actions = new int [3];
		actions[0] = 1; actions[1] = 0; actions[2] = 1;
		addNode(tree, actions);
		actions[0] = 2; actions[1] = 0; actions[2] = 1;
		addNode(tree, actions);
		actions[0] = 0; actions[1] = 1; actions[2] = 1;
		addNode(tree, actions);
		actions[0] = 0; actions[1] = 2; actions[2] = 1;
		addNode(tree, actions);
		actions[0] = 1; actions[1] = 1; actions[2] = 1;
		addNode(tree, actions);
		return tree;
	}
	// This function is adding a valid node after the validation
	private void addNode(List<State> tree, int[] actions) {
		int boat = currentState[2];
		int missR; int cannR; int missL; int cannL;
		missR = cannR = 0;
		if (boat == 1) {			// if boat at the right side
			missR = currentState[0] - actions[0];
			cannR = currentState[1] - actions[1];
			boat = 0;
		} else if (boat == 0) {		// if boat at the left side
			missR = currentState[0] + actions[0];
			cannR = currentState[1] + actions[1];
			boat = 1;
		}
		missL = 3 - missR;	cannL = 3 - cannR;
		// validating all possible outcomes
		if(missR >= 0 && cannR >= 0 && missL >= 0 && cannL >= 0) {
			if ((missR == 0 || missR > cannR) && (missL == 0 || missL > cannL) ||
					(missR == cannR)) {
				int newState[] = new int [3];
				newState[0] = missR; newState[1] = cannR; newState[2] = boat;
				State newNode = new State(newState);			
				newNode.setParentNode(this);
				tree.add(newNode);
			}
		}
	}
	public State getParentNode() {
		return parentNode;
	}
	private void setParentNode(State parentNode) {
		this.parentNode = parentNode;
	}
	public int[] getcurrentState() {
		return currentState;
	}
	public void setcurrentState(int[] currentState) {
		this.currentState = currentState;
	}
}