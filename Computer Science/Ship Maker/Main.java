/* Kyu Cho
2261 project4
11/12/14
Description: SpaceShip creator
1. Create number of spaceship based on user input in 'main' function
2. Inserting attributes in 'fillIn' function
3. If user wants to modify any values then it's done in 'changeShip' function
 	- If user wants to add then recall the 'fillIn' function
4. Loop continues until user wants to stop modify
5. Save the log every time the value is changed*/

import java.io.*;
import java.util.ArrayList;
import java.util.Scanner;

public class Main {	
	static java.util.Date date = new java.util.Date();	
	public static void main (String [] args) throws IOException {		
		int numberShips = 0;
		int answer = 1;
		boolean success = false;
		
		//Declare SpaceShip ArrayList
		ArrayList<SpaceShip> spaceShip = new ArrayList<SpaceShip>();

		do {
			try{				
				Scanner input = new Scanner(System.in);
				System.out.println("How many ships should exist?"); 				
				numberShips = input.nextInt();	
				success = true;
			} catch (Exception e) {
				System.out.println("Invalid input");
				success = false;
			}
		} while (!success);		
		
		//Insert the values and display
		spaceShip = fillUp(spaceShip,numberShips);
		displayShips(spaceShip);
		
		//Filtering possible wrong input from user by using try catch block
		do {
			try {
				do {			
					do {
						Scanner ip = new Scanner(System.in);
						System.out.println("Do you want to change any of the information?\n1. Yes\n2. No");
						answer = ip.nextInt();
						if (answer == 1) {
							spaceShip = changeShip(spaceShip,numberShips);
							displayShips(spaceShip);
						}
					} while (answer != 1 && answer != 2);	
				} while (answer == 1);
				success = true;
			} catch (Exception e) {
				System.out.println("Invalid input");
				success = false;
			}
		} while (!success);
	}
	
	//This function is to fill up the attributes and add it into the SpaceShip Array List
	public static ArrayList<SpaceShip> fillUp(ArrayList<SpaceShip> spaceShip,int numberShips) throws IOException {
		boolean success = false;
		int size = numberShips;
		int type = 0;

		for (int i = 0 ; i < size; i++) {
			do {
				try{
					Scanner input = new Scanner(System.in);	
					do {						
						System.out.println("Enter the type of the ship to create" + "\n1. ColonyShip\n2. CargoShip");
						type = input.nextInt();
					} while (type != 1 && type != 2);

					if (type == 1){
						System.out.println("Enter the name of the ship");
						String name = input.next();
						System.out.println("Enter the year the ship " + name +" was built");
						int date = input.nextInt();
						System.out.println("Enter the number of passangers in the ship " + name);
						int passNum = input.nextInt();
						
						SpaceShip colonyShip = new ColonyShip(name, date, passNum);				
						spaceShip.add(colonyShip);								
					} else if (type == 2) {
						System.out.println("Enter the name of the ship");
						String name = input.next();
						System.out.println("Enter the year the ship " + name +" was built");
						int date = input.nextInt();
						System.out.println("Enter the capacity of the ship " + name);
						int capacity = input.nextInt();
						
						CargoShip cargiShip = new CargoShip(name, date, capacity);				
						spaceShip.add(cargiShip);
					}
					success = true;
				} catch (Exception e) {
					System.out.println("Invalid input");
					success = false;
				}
			} while (!success);		
		}
		return spaceShip;
	}
	
	//This function is to modify any value user wants
	public static ArrayList<SpaceShip> changeShip (ArrayList<SpaceShip> spaceShip, int numberShips) throws IOException {		
		Scanner input = new Scanner(System.in);
		PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("log1.txt", true)));
		boolean success = false;
		int answer = 0;
		
		//Prompt if user want to change current value or create one
		do {
			try{
				do {
					Scanner ip = new Scanner(System.in);
					System.out.println("1. Change information from existing ship\n2. Add more ship");
					answer = ip.nextInt();	
					success = true;
				} while (answer != 1 && answer != 2);
			} catch (Exception e) {
				System.out.println("Invalid input");
				success = false;
			}
		} while (!success);		
		success = false;		
		
		//It will change the Spaceship value then log the changes
		if(answer == 1) {
			do {			
				System.out.println("Enter the name of the ship to modify");
				String name = input.next();			
					for (int i = 0; i < spaceShip.size(); i++){
						if(spaceShip.get(i).getName().equals(name)) {
							success = true;
							if(spaceShip.get(i).checkType() == 1){						
								System.out.println("Which attribute do you want to modify?\n1. Name\n2. Type\n3. Year\n4. Number of Passager");
								int choice = input.nextInt();
								switch (choice) {
									case 1:										
										System.out.println("Enter new name");
										String newName = input.next();
										out.println(date +": " + spaceShip.get(i).getName() + " name was changed from " + name + " to " + newName);
										spaceShip.get(i).setName(newName);
										out.close();
										return spaceShip;							
									case 2:										
										out.println(date +": " + name + " type was changed from ColonyShip to CargoShip");
										((ColonyShip) spaceShip.get(i)).setType("CargoShip");
										out.close();
										return spaceShip;
									case 3:
										System.out.println("Enter new year");
										int newDate = input.nextInt();
										out.println(date +": " + name + " year was changed from " + spaceShip.get(i).getDate() + " to " + newDate);
										spaceShip.get(i).setDate(newDate);										
										out.close();
										return spaceShip;
									case 4:
										System.out.println("Enter new number of passanger");
										int newPass = input.nextInt();
										out.println(date +": " + name + " # of passanger was changed from " + spaceShip.get(i).getPassNum() + " to " + newPass);
										((ColonyShip) spaceShip.get(i)).setPassNum(newPass);										
										out.close();
										return spaceShip;
									default:
										break;
								}
							} else if (spaceShip.get(i).checkType() == 2) {
								System.out.println("Which attribute do you want to modify?\n1. Name\n2. Type\n3. Year\n4. Capacity");
								int choice = input.nextInt();
								switch (choice) {
									case 1:
										System.out.println("Enter new name");
										String newName = input.next();
										out.println(date +": " + spaceShip.get(i).getName() + " name was changed from " + name + " to " + newName);
										spaceShip.get(i).setName(newName);
										out.close();
										return spaceShip;
									case 2:										
										out.println(date +": " + name + " type was changed from CargoShip to ColonyShip");
										((ColonyShip) spaceShip.get(i)).setType("CargoShip");
										out.close();
										return spaceShip;
									case 3:
										System.out.println("Enter new year");
										int newDate = input.nextInt();
										out.println(date +": " + name + " year was changed from " + spaceShip.get(i).getDate() + " to " + newDate);
										spaceShip.get(i).setDate(newDate);										
										out.close();
										return spaceShip;
									case 4:
										System.out.println("Enter new capacity");
										int newCap = input.nextInt();
										((CargoShip) spaceShip.get(i)).setCapacity(newCap);
										out.println(date +": " + name + " capacity was changed from " + spaceShip.get(i).getCapacity() + " to " + newCap);
										out.close();
										return spaceShip;
									default:
										break;
								}
							}
						}		
					}		
				System.out.println("Invalid Input");
				success = false;	
			} while (success != true);
		} else if (answer == 2){
			out.println(date + " New ship is added");
			fillUp(spaceShip,1);
			out.close();
		}
		out.close();
		return spaceShip;
	}
	
	//This function will display and log the output
	public static void displayShips (ArrayList<SpaceShip> spaceShip) throws IOException {		
	    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("log1.txt", true)));
	    
		System.out.println("-------------------------------New List---------------------------------");
		out.println("-----------------------------New List--------------------------------------");
		for (int i = 0; i < spaceShip.size(); i++) {
			if (spaceShip.get(i).checkType() == 1){
				System.out.println(spaceShip.get(i).toString());
				out.println(spaceShip.get(i).toString());
			}
		}
		for (int i = 0; i < spaceShip.size(); i++) {
			if (spaceShip.get(i).checkType() == 2){
				System.out.println(spaceShip.get(i).toString());
				out.println(spaceShip.get(i).toString());
			}
		}
		System.out.println("----------------------------------------------------------------");
		out.println("---------------------------------------------------------------------------");
		out.close();
	}
}
