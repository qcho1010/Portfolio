import java.util.Random;

public class SAcluster {
	public int k;
	public int rowLength;
	public int colLength;
	public int[] cluster;
	public double[][] data;
	public double[][] centroidDist;
	public double[][] intraDist;
	public double[][] clustrMean;
	public double[][] centroid;
	public double[][] prevCentroid;
	public double sumIntraDist;
	public double prevSumIntraDist;
	public boolean globalConverge;
	public double temp;
	public double coolingRate;
	public String method;

	public SAcluster (double[][] data, int k, double temp, double coolingRate, String method) {
		this.data = data;
		this.k = k;
		this.temp = temp;
		this.coolingRate = coolingRate;
		this.method = method;
		
		this.rowLength = data.length;
		this.colLength = data[0].length;
		this.centroid = new double [k][colLength];
		this.prevCentroid = new double [k][colLength];
		this.centroidDist = new double [rowLength][k];
		this.cluster = new int [rowLength];
	}

	public int[] start() {
		centroidInit();
		while (temp > 1){
			System.out.println("----------------------------------------");
			System.out.println("\t Current Temperature : " + Math.floor(temp));
			calcDist(method);
			assignCluster();
			System.out.println("\t## Prev. Inter-Cluster-Distances ## ");
			calcCentroid();
			storeCurrentData();

			double rand = randomDouble();
			double probability = acceptanceProbability(prevSumIntraDist, sumIntraDist, temp);
//			System.out.println("Acceptance Probability\nRandome Threashold\n\t" + probability + ", " + rand);
			if (probability > rand) {
				// randomize the centroid again.
				centroidInit();
				calcDist(method);
				assignCluster();
				System.out.println("\n\t##  Random applied  ##\n\t## New Inter-Cluster-Distances ##");
				calcCentroid();
				System.out.println("\n\tPrev. Intra-Cluster-Dist: " + prevSumIntraDist);
				System.out.println("\tNew. Intra-Cluster-Dist: " + sumIntraDist);
			}
			
			if (prevSumIntraDist < sumIntraDist) {
				// previous cluster was better, restore old data
				resotrePrevData();
			}
			// decrement temp
			temp *= (1 - coolingRate);
			System.out.println("\tFinal Intra-Cluster Distance " + sumIntraDist);
		}
		return cluster;
	}
	
	// Caclulating acceptance probability
	private double acceptanceProbability(double prevSumIntraDist, double sumIntraDist, double temperature) {
		// if the new solution is better, accept it
		if (sumIntraDist < prevSumIntraDist) {
			return 1.0;
		}
		return Math.exp((prevSumIntraDist - sumIntraDist) / temperature);
	}
	
	private double randomDouble() {
		Random r = new Random();
		return r.nextInt(100) / 1000.0;
	}
	
	// Copy current data
	private void storeCurrentData() {
		prevSumIntraDist = sumIntraDist;
		for (int i = 0; i < centroid.length; i++) {
			for (int j = 0; j < centroid[0].length; j++) {
				prevCentroid[i][j] = centroid[i][j];
			}
		}
	}
	
	// Restore previous data
	private void resotrePrevData() {
		sumIntraDist = prevSumIntraDist;
		for (int i = 0; i < prevCentroid.length; i++) {
			for (int j = 0; j < prevCentroid[0].length; j++) {
				centroid[i][j] = prevCentroid[i][j];
			}
		}
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
//			System.out.print("Min : " + min);
//			System.out.println("\tCluster : " + cluster[i]);
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
//			System.out.println();
		}
	}
	
	// Cacluate intra cluster distance between points w/ same cluster
	private void calcIntraDist(double[][] temp, String method, int tmpRowLength, int z) {
		System.out.println("Inter-Cluster distances in cluster " + z);
//		for (int i = 0; i < tmpRowLength; i++) {
//			for (int j = 0; j < colLength; j++) {
//				System.out.print(temp[i][j]);
//				System.out.print("\t");
//			}
//			System.out.println("");
//		}
		
		// finding intra cluster min, max, sum
		double min = 10*100;
		double max = 0;
		double sum = 0;
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
//			System.out.println("Dist : " + d);
			if (min > d) min = d; 
			if (max < d) max = d; 
			sum += d;
		}
		sum = Math.floor(sum * 100.0)/ 100.0;
		System.out.println("Min : " + min + ", Max : " + max + ", Sum : " + sum);
		sumIntraDist += sum;
		sumIntraDist = Math.floor(sumIntraDist * 100.0)/ 100.0;
	}

	// Print distnaces
	private void printCentroidDist() {
		System.out.println("\ncentroidDist to Each Cluster");
		for (int j = 0; j < k; j++)
			System.out.print("clustr" + j + "\t");
		System.out.println("");
		for(int i = 0; i < rowLength; i++) {
			for(int j = 0; j < k; j++) {
				System.out.print(centroidDist[i][j]);
				System.out.print("\t");
			}
			System.out.println("");
		}
	}

	// Print centroid points
	private void printCentroid() {
		System.out.println("\nCentroid Points");
		for (int j = 0; j < colLength; j++)
			System.out.print("col " + j + "\t");
		System.out.println("");
		for (int i = 0; i < centroid.length; i++) {
			for (int j = 0; j < centroid[0].length; j++) {
				System.out.print(centroid[i][j]);
				System.out.print("\t");
			}
			System.out.println("");
		}
	}
}

