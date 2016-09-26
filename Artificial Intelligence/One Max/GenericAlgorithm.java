package proj2;

import java.util.ArrayList;
import java.util.Random;

public class GenericAlgorithm {
	public ArrayList<ArrayList<Integer>> newPopulation = new ArrayList<ArrayList<Integer>>();
	public ArrayList<ArrayList<Integer>> population = new ArrayList<ArrayList<Integer>>();
	public int popSize;
	public int strSize;
	public int minIdx;
	public int maxIdx;
	public int localMaximum;
	public int localMinimum;
	public double localAverage;
	public double prevLocalAverage;
	private boolean goal = false;
	
	public GenericAlgorithm (int popSize, int strSize) {
		this.popSize = popSize;
		this.strSize = strSize;
	}

	public void start() { 
		// Entering Initial Population Phase 
		for (int i = 0; i < popSize; i++)
			population.add(buildString());	
		
		// Loop until the conditions are satisfied
		int genNum = 1;
		do { 
			System.out.println("\n---- Generation " + genNum++ + " ----");
			prevLocalAverage = localAverage;
			nextGeneration();
		} while(!goal && prevLocalAverage < localAverage);
	}

	// Generate next generation from the previous population
	public void nextGeneration() {
		while(newPopulation.size() < popSize) {
			ArrayList<Integer> x = randomSelection();	// Entering Selection Phase 
			ArrayList<Integer> y = randomSelection();
			if(Math.random() <= 0.6) {		// 60% chance of doing crossover operation
				crossOver(x, y);	// Entering Crossover Phase 
			} else { 						// 40% chance of copying its parent
				newPopulation.add(x);
				newPopulation.add(y);
			}
		}
		mutate();	// Entering Mutation Phase 

		// This loop will create the space in the new population 
		// to insert the highest parent fit 
		while(newPopulation.size() + 1 > population.size()) {
			findMinMax();
			newPopulation.remove(minIdx); // remove the lowest fit from the new population
		} 
		newPopulation.add(population.get(maxIdx)); // insert the highest fit from the parents

		// Print result
		System.out.println("Minimum fitness : " + localMinimum);
		System.out.println("Average fitness : " + localAverage);
		System.out.println("Maximum fitness : " + localMaximum);
		findMinMax();
		System.out.println(newPopulation.get(maxIdx).toString());

		// replace old population with new population
		population.clear();
		population.addAll(newPopulation);
		newPopulation.clear();
	}

	// Find highest fit from the parents
	public void findMinMax(){
		int max = 0;
		int min = strSize;
		double globFit = 0.0;
		
		for (ArrayList<Integer> individual : newPopulation) {
			int fit = 0;
			for (int i = 0; i < individual.size(); i++) {
				if (individual.get(i) == 1) {
					fit++;
					globFit++;
				}
			}
			if (fit > max) {
				max = fit;
				maxIdx = newPopulation.indexOf(individual);
			} 
			if (fit < min) {
				min = fit;
				minIdx = newPopulation.indexOf(individual);
			}
		}
		if (max == strSize && !goal) {
			System.out.println("!!!!! Global Optimum is found !!!!!");
			goal = true;
		}
		localMaximum = max;
		localMinimum = min;
		localAverage = globFit/newPopulation.size();
	}
	
	// Uniform crossover operation
	public void crossOver(ArrayList<Integer> x, ArrayList<Integer> y) {
		ArrayList<Integer> newX = new ArrayList<Integer>();
		ArrayList<Integer> newY = new ArrayList<Integer>();
		for (int i = 0; i < strSize; i++) {
			if (Math.random() <= 0.5) {
				newX.add(y.get(i));
				newY.add(x.get(i));
			} else {
				newX.add(x.get(i));
				newY.add(y.get(i));
			}
		}
		newPopulation.add(newX);
		newPopulation.add(newY);
	}

	// Mutate operation
	private void mutate() {
		for (ArrayList<Integer> individual : newPopulation) {
			for (int i = 0; i < individual.size(); i++) {
				if (Math.random() <= 1/strSize) {  // mutate probability
					if (individual.get(i) == 1)
						individual.set(Integer.valueOf(i), 0);
					 else 
						individual.set(Integer.valueOf(i), 1);
				}
			}
		}
	}

	// Randomly select two parents
	public ArrayList<Integer> randomSelection() {
		Random rand = new Random();
		int randNum = rand.nextInt(((popSize - 1) - 0) + 1) + 0;
		return population.get(randNum);
	}

	// Randomly generate binary string, size defined by user
	public ArrayList<Integer> buildString() {
		Random rand = new Random();
		ArrayList<Integer> binaryString = new ArrayList<Integer>();
		for (int i = 0; i < strSize; i++) {
			int randNum = rand.nextInt((1 - 0) + 1) + 0;
			binaryString.add(randNum);  
		}
	    return binaryString;
	}
}
