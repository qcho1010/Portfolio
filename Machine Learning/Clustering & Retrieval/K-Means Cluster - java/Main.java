import java.util.Random;
import java.io.FileWriter;
import java.io.IOException;

public class Main {
	public static void main(String[] args) {
		// Load Data
		double[][] data = setValues(); 
		
		// Run k-means clustering
		String fileName;
		int [] clusterArr;
		kmeans km;
		
		km = new kmeans(data, 2, "euclidean");
		clusterArr = km.start();
		fileName = "E:\\Google Drive\\Class\\4342\\proj1\\euclidean2.csv";
		saveCSV(data, clusterArr, fileName);

		km = new kmeans(data, 4, "euclidean");
		clusterArr = km.start();
		fileName = "E:\\Google Drive\\Class\\4342\\proj1\\euclidean4.csv";
		saveCSV(data, clusterArr, fileName);
		
		km = new kmeans(data, 2, "manhattan");
		clusterArr = km.start();
		fileName = "E:\\Google Drive\\Class\\4342\\proj1\\manhattan2.csv";
		saveCSV(data, clusterArr, fileName);

		km = new kmeans(data, 4, "manhattan");
		clusterArr = km.start();
		fileName = "E:\\Google Drive\\Class\\4342\\proj1\\manhattan4.csv";
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
		int rowLength = 20;
		double [][] data = new double [rowLength][colLength];
		Random randnum = new Random(28);  // set seed

		for (int i = 0; i < rowLength; i++) {
			// Assign random numbers
			for (int j = 0; j < colLength; j++) {
				if (j == 0) data [i][j] = Math.floor(randnum.nextDouble() * 100.0)/ 100.0;
				else data [i][j] = Math.floor(randnum.nextDouble() * 100.0);
			}
		}
		
		// Print Data
		System.out.println("Initial Data");
		for (int j = 0; j < colLength; j++)
			System.out.print("col " + j + "\t");
		System.out.println("");
		for (int i = 0; i < rowLength; i++) {
			for (int j = 0; j < colLength; j++) {
				System.out.print(data[i][j]);
				System.out.print("\t");
			}
			System.out.println("");
		}
		System.out.println("");
		
		return data;
	}	
}
