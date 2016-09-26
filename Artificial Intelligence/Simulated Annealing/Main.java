import java.util.Random;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintStream;

public class Main {
	public static void main(String[] args) throws FileNotFoundException {
		PrintStream myconsole = new PrintStream(new File("E:\\Google Drive\\Class\\4342\\proj2\\output5.txt"));
		System.setOut(myconsole);
		
		// Load Data
		double[][] data = setValues(); 
		
		// Run k-means clustering
		String fileName;
		int [] clusterArr;
		SAcluster sa;
		System.out.println("\n#############################################");
		System.out.println("Simulated Annealing Clustering k = 3");
		System.out.println("#############################################");
		
		int k = 3;
		double temp = 1000;
		double coolingRate = 0.03;
		
		sa = new SAcluster(data, k, temp, coolingRate, "euclidean");
		clusterArr = sastart();
		fileName = "E:\\Google Drive\\Class\\4342\\proj2\\SAresult5.csv";
		saveCSV(data, clusterArr, fileName);

	}

	// Save data into csv
	private static void saveCSV(double[][] data, int[] clusterArr, String fileName) {
	    try {
			FileWriter writer = new FileWriter(fileName);
			// write header
			for (int z = 0; z < data[0].length; z++) {
		    	writer.append("attribute" + z);
		    	writer.append(',');
		    }
		    writer.append("Cluster");
		    writer.append('\n');

		    // write observation
		    for (int i = 0; i < data.length; i++) {
		    	for (int j = 0; j < data[0].length; j++) {
		    		writer.append(String.valueOf(data[i][j]));
		    		writer.append(',');
		    	}
		    	writer.append(String.valueOf(clusterArr[i]));
		    	writer.append("\n");
		    }
		    writer.flush();
		    writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	// Arbitrarily generate random observations
	public static double[][] setValues() {
		int colLength = 2;
		int rowLength = 100;
		double [][] data = new double [rowLength][colLength];
		Random randnum = new Random(5);  // set seed

		for (int i = 0; i < rowLength; i++) {
			// Assign random numbers
			for (int j = 0; j < colLength; j++) {
				if (j == 0) data [i][j] = Math.floor(randnum.nextDouble() * 100.0)/ 100.0;
				else data [i][j] = Math.floor(randnum.nextDouble() * 100.0);
			}
		}
		
		// Print Data
//		System.out.println("Initial Data");
//		for (int j = 0; j < colLength; j++)
//			System.out.print("col " + j + "\t");
//		System.out.println("");
		for (int i = 0; i < rowLength; i++) {
			for (int j = 0; j < colLength; j++) {
//				System.out.print(data[i][j]);
//				System.out.print("\t");
			}
//			System.out.println("");
		}
//		System.out.println("");
		
		return data;
	}	
}
