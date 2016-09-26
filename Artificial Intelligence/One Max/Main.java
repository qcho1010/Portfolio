package proj2;

import java.util.Scanner;

public class Main {
	public static void main(String[] args) {
		Scanner in = new Scanner(System.in);
		int popSize;	// population size
		int strSize;	// string size
		
		System.out.println("Enter population size");
		popSize= in.nextInt();
		
		System.out.println("Enter string size");
		strSize= in.nextInt();
		
		GenericAlgorithm GA = new GenericAlgorithm (popSize, strSize);
		GA.start();
	}
}
