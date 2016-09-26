/* Kyu Cho
2261 project3
10/20/14
Description: Mini Sims
1. Creates human array objects in main
2. Creates dog array objects in side of the each human array object
3. Both human and dogs objects are extended from mammal objects to share its attributes
4. Main request to perform the action.
5. Human objects responds it and changes the depending attribute in dog's objects and human's objects
6. Dog's attributes can only be changed through getter and setter functions */

package p3;
import java.util.Scanner;

public class main {	
	public static void main (String [] args) {
		int key = 1; // Variable for loop control
		
		System.out.println("How many humans should exist? (MAX 9 Human)"); // Getting total number of human
		Scanner input = new Scanner(System.in);
		int numberHumans = input.nextInt();			
		
		human [] humanArr = assignArr(numberHumans); // Received array objects from assignArr.
		do { // Loop continues till receive return value 0;
			displayChart(humanArr);
			key = control(humanArr,numberHumans);
		} while (key != 0);		
	}	
	//Assigning human array objects
	public static human [] assignArr (int numberHumans) {
		Scanner input = new Scanner(System.in);
		human[] humanArr= new human[numberHumans]; // Declaring object array
		
		for(int id = 0 ; id < numberHumans; id++) { // Loop continues till number of humans objects	
			System.out.println("Enter the name of human ID #"+ (id+1)+" (MAX 10 Char)");
			String name = input.next();			
			System.out.println("Enter the " + name + "'s gender (m=male, f=female)");
			String sex = input.next();
			
			humanArr[id] = new human(name, sex, id); // Assign human object array with value
		}
		return humanArr;
	}
	// Display each human's attributes 
	public static void displayChart(human [] humanArr) {
		for(int i = 0 ; i < humanArr.length ; i++) 		{
			humanArr[i].info(); 
		}
	}	
	// Perform the action based on action input
	public static int control(human [] humanArr,int numberHumans) {
		Scanner input = new Scanner(System.in);		
		int humanID = 1;
		int actionNum = 1;
		
		if (numberHumans > 1) { // Ask if user wants to choose different human, if there are more than 1 human
			do { // Loop for input validation
				System.out.println("Which user ID should be controlled?");
				humanID = input.nextInt();
				if(humanID > numberHumans) {
					System.out.println("Invalid input");
				}
			} while (humanID > numberHumans);
		}			
		do {			
			menu(); // Display action menu	
			System.out.println("___________________________________");
			System.out.println("Enter action number");
			actionNum = input.nextInt();
			
			switch(actionNum) { // Invoke action by action number
			case 1: humanArr[humanID-1].gotoWork();				
				break;
			case 2: humanArr[humanID-1].buyDogFood();
				break;
			case 3: humanArr[humanID-1].walks();
				break;
			case 4: humanArr[humanID-1].bathes();
				break;
			case 5: humanArr[humanID-1].feeds();
				break;
			case 6: humanArr[humanID-1].gotoSleep();
				break;
			case 0: System.out.println("Thank you for playing! Good bye!");
				return 0;
			default:
				System.out.println("Invalid input");
			}
		} while (actionNum > 6);
		return 1;
	}	
	// Display action menu
	public static void menu () {
		System.out.println("____________Action Menu_____________");
	System.out.println("(1) Go to work.\n(2) Buy food for dogs.($10.00 for 3 packs)\n(3) "
			+ "Walk with dogs.\n(4) Bath dogs.\n(5) Feed dogs.\n(6) Go to sleep.\n(0) To quit");
	}
}
