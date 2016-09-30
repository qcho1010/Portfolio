import java.util.Random;

public class kmeans {
	public int k;
	public int rowLength;
	public int colLength;
	public int[] cluster;
	public double[][] data;
	public double[][] centroidDist;
	public double[][] intraDist;
	public double[][] centroid;
	public double[][] clustrMean;
	public double sumIntraDist;
	public boolean globalConverge;
	public String method;
	
	public kmeans (double[][] data, int k, String method) {
		this.data = data;
		this.k = k;
		this.method = method;
		this.rowLength = data.length;
		this.colLength = data[0].length;
		this.centroid = new double [k][colLength];
		this.centroidDist = new double [rowLength][k];
		this.cluster = new int [rowLength];
	}
	
	public int[] start() {
		centroidInit();
		while (!globalConverge){
			System.out.println("----------------------------------------");
			calcDist(method);
			assignCluster();
			calcCentroid();
			System.out.println("\nSum of intra-cluster distance \nbetween clusters :" + sumIntraDist);
		}
		return cluster;
	}

	// Select random row as centroid
	private void centroidInit() {
		for (int i = 0; i < k; i++) {
			int idx;
			for (int j = 0; j < colLength; j++) {
				Random randnum = new Random(i*2); 
				idx = randnum.nextInt(rowLength - 1) + 0;
				centroid[i][j] = data[idx][j];
			}
		}
	}
	
	// Caclulate centroidDists
	private void calcDist(String method) {
		for (int z = 0; z < k; z++) {
			for (int i = 0; i < rowLength; i++) {
				double d = 0.0;
				if (method == "euclidean") {
					for (int j = 0; j < colLength; j++) 
						d += Math.pow(data[i][j] - centroid[z][j], 2);
					d = Math.floor(Math.sqrt(d) * 100.0)/ 100.0;
				} else if (method == "manhattan") {
					for (int j = 0; j < colLength; j++)
						d += (data[i][j] - centroid[z][j]);
					d = Math.abs(Math.floor(d * 100.0)/ 100.0);
				}
				centroidDist[i][z] = d;
			}
		}
	}

	// Assign closer points into cluster
	private void assignCluster() {
		boolean localConverge = true;
		for (int i = 0; i < rowLength; i++) {
			double min = centroidDist[i][0];
			int minColIdx = 0;
			for(int j = 0; j < k; j++) {
				if (min > centroidDist[i][j]) {
					min = centroidDist[i][j];
					minColIdx = j;
				}
			}
			if (cluster[i] != minColIdx) {
				cluster[i] = minColIdx;
				localConverge = false;
			}
		}
		if (localConverge)
			globalConverge = true;
	}

	// Cacluate mean between points w/ same cluster
	private void calcCentroid() {
		sumIntraDist = 0;
		for (int z = 0; z < k; z++) {
			double [][] temp  = new double[rowLength][colLength];
			int tmpRowLength = 0;
			for (int j = 0; j < colLength; j++) {
				int idxI = 0;
				double sum = 0.0;
				double mean = 0.0;
				double counter = 0.0;
				for (int i = 0; i < rowLength; i++) {
					if (cluster[i] == z) {
						sum += data[i][j];
						counter++;
						
						temp[idxI][j] = data[i][j]; // store points in each cluster
						idxI++;
					}
				}
				mean = sum/counter;
				centroid[z][j] = Math.floor(mean * 100.0)/ 100.0; // assigned new centroid pts
				tmpRowLength = idxI;
			}
			calcIntraDist(temp, method, tmpRowLength, z); // calculate intra cluster dist
			System.out.println();
		}
	}
	
	// Cacluate intra cluster distance between points w/ same cluster
	private void calcIntraDist(double[][] temp, String method, int tmpRowLength, int z) {
		double min = 10*100;
		double max = 0;
		double sum = 0;
		System.out.println("Intra-Cluster distances in cluster " + z);

		// finding intra cluster min, max, sum
		for (int i = 0; i < tmpRowLength; i++) {
			double d = 0.0;
			if (method == "euclidean") {
				for (int j = 0; j < colLength; j++) 
					d += Math.pow(temp[i][j] - centroid[z][j], 2);
				d = Math.floor(Math.sqrt(d) * 100.0)/ 100.0;
			} else if (method == "manhattan") {
				for (int j = 0; j < colLength; j++)
					d += (data[i][j] - centroid[z][j]);
				d = Math.abs(Math.floor(d * 100.0)/ 100.0);
			}
			if (min > d) min = d; 
			if (max < d) max = d; 
			sum += d;
		}
		sum = Math.floor(sum * 100.0)/ 100.0;
		System.out.println("Min : " + min + ", Max : " + max + ", Sum : " + sum);
		sumIntraDist += sum;
		sumIntraDist = Math.floor(sumIntraDist * 100.0)/ 100.0;
	}
}
