/*
Kyu Cho
CS3130
March.3.15
Project 2
Description : This program will calculate the time to run each different sorting algorithm with different size of values and types of values.
There are three different size of values; 100, 1000, and 10000
There are three different types of values
1. All random values
2. Partially sorted values
3. All sorted values
There are six different types of sorting algorithms
Insertion, Selection, Bubble with swap, bubble without swap, Merge, and Quick sort. 
*/

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;

public class Main {    
	//Scanner and File Objects
	static Scanner s; 
	static File f;

	  public static void main(String[] args) throws IOException {			
		  callFunction();
	  }

	  public static void quickSort(int [] list, int p, int r) {
	        int i = p;                        
	        int k = r;                            

	        if (r - p >= 1)                 
	        {
                int pivot = list[p];       
                while (k > i)                   
                {
                    while (list[i] <= pivot && i <= r && k > i)  
                        i++;                                    
                    while (list[k] > pivot && k >= p && k >= i) 
                        k--; 
                    if (k > i)                                      
                            swap(list, i, k); 
                }
                swap(list, p, k);          
                quickSort(list, p, k - 1); 
                quickSort(list, k + 1, r);  
	        }
	        else   
                return; 
	    }
	  
	  public static void swap(int[] a, int i, int j) {
	        int temp = a[i];
	        a[i] = a[j];
	        a[j] = temp;
	    }
	    
	  public static void mergeSort(int[] list) {		  
		    if (list.length <= 1) 
		    	return;
		    
	        int[] left = new int[list.length / 2];
	        int[] right = new int[list.length - left.length];
	        System.arraycopy(list, 0, left, 0, left.length);
	        System.arraycopy(list, left.length, right, 0, right.length);
	        
	        // Sort each half
	        mergeSort(left);
	        mergeSort(right);
	        // Mege
	        merge(left, right, list);		      
		  }	  
	  
	  public static void merge(int[] left,int[] right, int[] list) {
		    int p = 0; 
		    int r = 0; 
		    int k = 0; 		
		    while (p < left.length && r < right.length) {
		      if (left[p] < right[r])
		    	  list[k++] = left[p++];
		      else
		    	  list[k++] = right[r++];
		    }
		
		    while (p < left.length)
		    	list[k++] = left[p++];
		
		    while (r < right.length)
		    	list[k++] = right[r++];  		  
	  }
	  
	  public static void bubbleSort(int[] list) {
		    boolean needNextPass = true;		    
		    for (int k = 1; k < list.length && needNextPass; k++) {
		      // Array may be sorted and next pass not needed
		      needNextPass = false;
		      for (int i = 0; i < list.length - k; i++) {
		        if (list[i] > list[i + 1]) {
		          // Swap list[i] with list[i + 1]
		          int temp = list[i];
		          list[i] = list[i + 1];
		          list[i + 1] = temp;
		          
		          needNextPass = true; // Next pass still needed
		        }
		      }
		    }
		  }
	  
	  public static void bubbleSort2(int[] list) {		    
		    for (int k = 1; k < list.length; k++) {
		      for (int i = 0; i < list.length - k; i++) {
		        if (list[i] > list[i + 1]) {
		          // Swap list[i] with list[i + 1]
		          int temp = list[i];
		          list[i] = list[i + 1];
		          list[i + 1] = temp;
		        }
		      }
		    }
		  }
	  
	  public static void insertionSort(int[] list) {
		    for (int i = 1; i < list.length; i++) {
		      /* insert list[i] into a sorted sublist list[0..i-1] so that
		           list[0..i] is sorted. */
		      int currentElement = list[i];
		      int k;
		      for (k = i - 1; k >= 0 && list[k] > currentElement; k--) {
		        list[k + 1] = list[k];
		      }

		      // Insert the current element into list[k+1]
		      list[k + 1] = currentElement;
		    }
		  }
	  
	  public static void selectionSort(int[] list) {
		    for (int i = 0; i < list.length - 1; i++) {
		      // Find the minimum in the list[i..list.length-1]
		      int currentMin = list[i];
		      int currentMinIndex = i;

		      for (int j = i + 1; j < list.length; j++) {
		        if (currentMin > list[j]) {
		          currentMin = list[j];
		          currentMinIndex = j;
		        }
		      }

		      // Swap list[i] with list[currentMinIndex] if necessary;
		      if (currentMinIndex != i) {
		        list[currentMinIndex] = list[i];
		        list[i] = currentMin;
		      }
		    }
		  }
	  
	  public static void callFunction() throws IOException {
			int i;
			int j;
			
			//Creating All random numbers
			PrintWriter AllRandom = new PrintWriter(new BufferedWriter(new FileWriter("AllRandom.txt", false)));
			int ranNums;
			for (j = 0 ; j < 10000; j++){
				ranNums = (int) (Math.random() * 10000) + 0;
				AllRandom.println(ranNums);
			}
			AllRandom.close();
			
			//Creating part random numbers
			int ranNums2;		
			PrintWriter PartRandom = new PrintWriter(new BufferedWriter(new FileWriter("PartRandom.txt", false)));
			for (j = 0 ; j < 10000; j++){
				if(j%10 == 0 && j != 0) {
					ranNums2 = (int)(Math.random() * 10000) + 0;
					PartRandom.println(ranNums2);
				} else {	
					PartRandom.println(j);
				}		
			}
			PartRandom.close();
			
			//Creating sorted numbers
			PrintWriter AllSorted = new PrintWriter(new BufferedWriter(new FileWriter("AllSorted.txt", false)));
			for (j = 0 ; j < 10000; j++){
				AllSorted.println(j);
			}
			AllSorted.close();		
			
	        //Copying AllRandom.txt into Array 
	        Scanner scan = new Scanner(new File("AllRandom.txt"));         
	        int AllRandom10000[] = new int[10000];        
	        for(i=0 ; i < 10000 ; i++)
	          	AllRandom10000[i]=scan.nextInt(); //fill the array with the integers
	        
	        scan = new Scanner(new File("AllRandom.txt"));
	        int AllRandom1000[] = new int[1000];        
	        for(i=0 ; i < 1000 ; i++)
	        	AllRandom1000[i]=scan.nextInt(); //fill the array with the integers
	        
	        scan = new Scanner(new File("AllRandom.txt"));
	        int AllRandom100[] = new int[100];        
	        for(i=0 ; i < 100 ; i++)
	        	AllRandom100[i]=scan.nextInt(); //fill the array with the integers
	        scan.close();
	        
	      //Copying PartRandom.txt into Array
	        Scanner scan2 = new Scanner(new File("PartRandom.txt"));         
	        int PartRandom10000[] = new int[10000];        
	        for(i=0 ; i < 10000 ; i++)
	        	PartRandom10000[i]=scan2.nextInt(); //fill the array with the integers
	        
	        scan2 = new Scanner(new File("PartRandom.txt")); 
	        int PartRandom1000[] = new int[1000];        
	        for(i=0 ; i < 1000 ; i++)
	        	PartRandom1000[i]=scan2.nextInt(); //fill the array with the integers
	        
	        scan2 = new Scanner(new File("PartRandom.txt")); 
	        int PartRandom100[] = new int[100];        
	        for(i=0 ; i < 100 ; i++)
	        	PartRandom100[i]=scan2.nextInt(); //fill the array with the integers
	        scan2.close();
	        
	      //Copying AllSorted.txt into Array
	        Scanner scan3 = new Scanner(new File("AllSorted.txt"));         
	        int AllSorted10000[] = new int[10000];        
	        for(i=0 ; i < 10000 ; i++)
	        	AllSorted10000[i]=scan3.nextInt(); //fill the array with the integers
	        
	        scan3 = new Scanner(new File("AllSorted.txt"));
	        int AllSorted1000[] = new int[1000];        
	        for(i=0 ; i < 1000 ; i++)
	        	AllSorted1000[i]=scan3.nextInt(); //fill the array with the integers
	        
	        scan3 = new Scanner(new File("AllSorted.txt"));
	        int AllSorted100[] = new int[100];        
	        for(i=0 ; i < 100 ; i++)
	        	AllSorted100[i]=scan3.nextInt(); //fill the array with the integers        
	        scan3.close();
	        
	        long startTime;
	        long stopTime;
	        
	      //Selection Sort SIZE 10000
			startTime = System.nanoTime(); 
			selectionSort(AllRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
			startTime = System.nanoTime(); 
			selectionSort(PartRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			selectionSort(AllSorted10000);
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
	    	   
	        //Selection Sort SIZE 1000
		    startTime = System.nanoTime();
		    selectionSort(AllRandom1000);
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    selectionSort(PartRandom1000);	
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			selectionSort(AllSorted1000);
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
	        //Selection Sort SIZE 100
		    startTime = System.nanoTime();
		    selectionSort(AllRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    selectionSort(PartRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			selectionSort(AllSorted100);	
		    stopTime = System.nanoTime();
		    System.out.println("Selection Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    
		    System.out.println("--------------------------------------------------------------------------");	    
	        //Insertion Sort SIZE 10000
			startTime = System.nanoTime(); 
			insertionSort(AllRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
			startTime = System.nanoTime(); 
			insertionSort(PartRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			insertionSort(AllSorted10000);
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
	    	   
	        //Insertion Sort SIZE 1000
		    startTime = System.nanoTime();
		    insertionSort(AllRandom1000);
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    insertionSort(PartRandom1000);	
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			insertionSort(AllSorted1000);
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
	        //Insertion Sort SIZE 100
		    startTime = System.nanoTime();
		    insertionSort(AllRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    insertionSort(PartRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			insertionSort(AllSorted100);	
		    stopTime = System.nanoTime();
		    System.out.println("Insertion Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Sorted");

		    
		 
		    System.out.println("--------------------------------------------------------------------------");	    
	        //Bubble Sort without Swap SIZE 10000
			startTime = System.nanoTime(); 
			bubbleSort2(AllRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
			startTime = System.nanoTime(); 
			bubbleSort2(PartRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			bubbleSort2(AllSorted10000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
	    	   
		    //Bubble Sort with Swap SIZE 1000
		    startTime = System.nanoTime();
		    bubbleSort2(AllRandom1000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    bubbleSort2(PartRandom1000);	
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			bubbleSort2(AllSorted1000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    //Bubble Sort with Swap SIZE 100
		    startTime = System.nanoTime();
		    bubbleSort2(AllRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    bubbleSort2(PartRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			bubbleSort2(AllSorted100);	
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/o Swap | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    System.out.println("--------------------------------------------------------------------------");	    
	        //Bubble Sort with Swap SIZE 10000
			startTime = System.nanoTime(); 
			bubbleSort(AllRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
			startTime = System.nanoTime(); 
			bubbleSort(PartRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			bubbleSort(AllSorted10000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
	    	
		    
		    //Bubble Sort with Swap SIZE 1000
		    startTime = System.nanoTime();
		    bubbleSort(AllRandom1000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    bubbleSort(PartRandom1000);	
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			bubbleSort(AllSorted1000);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    //Bubble Sort with Swap SIZE 100
		    startTime = System.nanoTime();
		    bubbleSort(AllRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    bubbleSort(PartRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			bubbleSort(AllSorted100);	
		    stopTime = System.nanoTime();
		    System.out.println("Bubble Sort w/ Swap | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    
		 
	        
		    System.out.println("--------------------------------------------------------------------------");	    
	        //Merge Sort SIZE 10000
			startTime = System.nanoTime(); 
			mergeSort(AllRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
			startTime = System.nanoTime(); 
			mergeSort(PartRandom10000);
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			mergeSort(AllSorted10000);
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    //Merge Sort SIZE 1000
		    startTime = System.nanoTime();
		    mergeSort(AllRandom1000);
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    mergeSort(PartRandom1000);	
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			mergeSort(AllSorted1000);
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    //Merge Sort SIZE 100
		    startTime = System.nanoTime();
		    mergeSort(AllRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    mergeSort(PartRandom100);
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
			mergeSort(AllSorted100);	
		    stopTime = System.nanoTime();
		    System.out.println("Merge Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    System.out.println("--------------------------------------------------------------------------");	         
	        //Quick Sort SIZE 10000
		    startTime = System.nanoTime();
		    quickSort(AllRandom10000, 0, AllRandom100.length - 1);
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    quickSort(PartRandom10000, 0, PartRandom100.length - 1);
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
		    quickSort(AllSorted10000, 0, AllSorted100.length - 1);	
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 10000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
		    
		    //Quick Sort SIZE 1000
		    startTime = System.nanoTime();
		    quickSort(AllRandom1000, 0, AllRandom1000.length - 1);	
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    quickSort(PartRandom1000, 0, PartRandom1000.length - 1);	
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
		    quickSort(AllSorted1000, 0, AllSorted1000.length - 1);	
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 1000 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
	        
		    //Quick Sort SIZE 100
		    startTime = System.nanoTime();
		    quickSort(AllRandom100, 0, AllRandom100.length - 1);
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Random");
		    
		    startTime = System.nanoTime();
		    quickSort(PartRandom100, 0, PartRandom100.length - 1);
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | Partially Random");
		    
			startTime = System.nanoTime(); 
		    quickSort(AllSorted100, 0, AllSorted100.length - 1);	
		    stopTime = System.nanoTime();
		    System.out.println("Quick Sort | SIZE 100 | Time(ns) " + (stopTime - startTime) + " | All Sorted");
	  }
}