package p3;
import java.util.Scanner;

// Subclass human extends from mammal superclass
public class human extends mammal {	
	// Randomly generating human's attributes
	private final int numberDogs = (int)(Math.random()*((int)4-(int)1 + 1)+1);	
	private int dogFood = (int)(Math.random()*((int)60-(int)20 + 1)+20);	
	private int energy = (int)(Math.random()*((int)80-(int)60 + 1)+60);
	private double money = (double)(Math.random()*((double)150-(double)50 + 1)+50);
	private int id = 0;
	dog[] dogArr= new dog[numberDogs]; // Declaring object array	
	Scanner input = new Scanner(System.in);	
	
	public human(String name, String sex, int id) {
		super.name = name;
		super.sex = sex;
		super.weight = (double)(Math.random()*((double)220-(double)140 + 1)+140); // Randomly generate human's weight
		this.id = id;
		
		System.out.println("_____"+name + " adopted "+ numberDogs+" dogs_____");		
		// Create and assign each dog object array that belong to human object
		for (int i = 0 ; i < numberDogs ; i++) { 	
			System.out.println("Enter the name of dog "+(i+1)+".");
			String nameDog = input.next();
			dogArr[i] = new dog(nameDog, i);
		}
	}
	//----------------------------------------------------------------------------------------------------
	public void info () { // Display all human's attributes
		System.out.println(" __Day "+super.day+"____________________________________________________________________");
		System.out.println("|        |    Name    | Sex | Weight |  Money | Energy | #Dogs | #Dog Foods |");
		System.out.printf("%s %5s %2s %8s %3s %2s %2s %6.2f %s %6.2f %s %4d %3s %3d %3s %6d %5s \n","|",  "ID #"+ (id+1),"|" ,
				super.name, "|",super.sex,"|",super.weight,"|",this.money,"|",this.energy,"|",this.numberDogs,"|",this.dogFood,"|");
		System.out.println("|________|____________|_____|________|________|________|_______|____________|");
		System.out.println("|        |    Name    | Sex | Weight | Hunger | Fun | Cleanliness | Loyalty |");			
		for(int i = 0 ; i < dogArr.length ; i++) {
			dogArr[i].info(); // Display all dog's attributes
		}
	}
	//----------------------------------------------------------------------------------------------------
	// Flowing methods are performing methods, modifying possible attributes either dogs or human or both.
	//----------------------------------------------------------------------------------------------------
	public void gotoWork() {		
		if(this.energy <= 50) {
			System.out.println("___________________________________");
			System.out.println(name + " : I'm too tired to go to work..\n I need some sleep :(");
		} else {			
			int energy = -(int)(Math.random()*((int)50-(int)40 + 1)+40); // Reduce energy value btw 40-20
			double money = 50;
			this.energy += energy;
			this.money += money; // Increase money			
			System.out.println("___________________________________");			
			System.out.println(".......Going work........[8AM]");
			System.out.println(".........Working.........[1PM]");
			System.out.println(".......Come to home......[4PM]");
			System.out.printf("%s%.2f\n","     ++ Money        = $",money);
			System.out.println("     -- Energy       = " + energy);			
			passTheTime();			
		}			
	}	
	public void buyDogFood() {
		if(this.energy < 10) {
			System.out.println("___________________________________");
			System.out.println(name + " : I'm too tired to go to shop..\n I need some sleep :(");
		} else {
			double expense = -10.00*this.numberDogs; // Expense is proportion to number of dogs
			
			if(-expense > this.money) {
				System.out.println("I'm broke to buy food for dogs.. I need to go to work :(");
				System.out.println("Price = $10.00 x Number of dogs = " + expense);
			} else if(expense <= this.money) {
				int energy = -10;
				int dogFood = numberDogs*3;
				this.money += expense;  // Decrease money
				this.energy += energy;  // Decrease energy
				this.dogFood += dogFood; // Food gains is proportion to number of dogs	
				System.out.println("___________________________________");
				System.out.println("Successfully bought " + 3*numberDogs +" packs. (3packs x #dogs = total pack bought)");
				System.out.println("Expense = $10.00 x #dogs = $" + expense);
				System.out.println("     ++ Dog Foods        = " + dogFood);
				System.out.printf("%s%.2f\n","     -- Money            = $",expense);
				System.out.println("     -- Energy           = " + energy);
			}		
		}			
	}
	public void gotoSleep (){
			int energy = +(int)(Math.random()*((int)100-(int)95 + 1)+95); // Reduce energy value btw 40-20	
			double money = 20;
			super.day += 1;	
			this.energy += energy;
			this.money += money; // Increase money	
			
			if(this.energy > 100) // Prevent overflow
				this.energy =  100;
			
			System.out.println("___________________________________");
			System.out.println(".......Going bed........[10PM]");
			System.out.println(".......Sleeping......zZz.[4AM]");
			System.out.println(".........Woke up.........[7PM]");
			System.out.println("     ++ Energy      = " + energy);
			System.out.printf("%s%.2f\n","     ++ Money       = $",money);
			passTheTime();				
	}	
	public void passTheTime () {			
		for (int i = 0; i < numberDogs; i++) { // Resetting values from each dog's object
			int fun = -(int)(Math.random()*((int)20-(int)10 + 1)+10);
			int hunger = +(int)(Math.random()*((int)25-(int)15 + 1)+15);
			int cleanliness = -(int)(Math.random()*((int)9-(int)4 + 1)+4);
			dogArr[i].setFun(fun);				
			dogArr[i].setHunger(hunger);				 
			dogArr[i].setCleanliness(cleanliness);				
			dogArr[i].setLoyalty();
			System.out.println("___________________________________");
			dogArr[i].timePassMsg();			
			System.out.println("     ++ hunger      = " + hunger);	
			System.out.println("     -- fun         = " + fun);
			System.out.println("     -- cleanliness = " + cleanliness);	
		}		
	}	
	public void walks (){
		if(this.energy <= 3.5*numberDogs) {
			System.out.println("___________________________________");
			System.out.println(name + " : I'm too tired to go walk ..\n I need some sleep :(");
		} else {
			int energy = (int) -(4*numberDogs); // Decrease human energy, proportion to number of dogs
			this.energy += energy;	
			
			System.out.println("___________________________________");
			System.out.println(name + " : Walking with my dog is always joyful! :)");
			System.out.println("     -- Energy      = " + energy);
			
			for (int i = 0; i < numberDogs; i++) { // Resetting values from each dog's object
				int fun = +(int)(Math.random()*((int)40-(int)20 + 1)+20);
				int hunger = +(int)(Math.random()*((int)20-(int)15 + 1)+15);
				int cleanliness = -(int)(Math.random()*((int)15-(int)10 + 1)+10);
				dogArr[i].setFun(fun);				
				dogArr[i].setHunger(hunger);				 
				dogArr[i].setCleanliness(cleanliness);				
				dogArr[i].setLoyalty();
				System.out.println("___________________________________");
				dogArr[i].walkMsg();
				System.out.println("     ++ fun         = " + fun);
				System.out.println("     ++ hunger      = " + hunger);				
				System.out.println("     -- cleanliness = " + cleanliness);	
			}
		}
	}	
	public void bathes (){
		if(this.energy <= 5*numberDogs) {
			System.out.println("___________________________________");
			System.out.println(name + " : I'm too tired to bath my dog..\n I need some sleep :(");
		} else {
			int energy = -(int) -(5*numberDogs); // Decrease human energy, proportion to number of dogs
			this.energy += energy;	
			
			System.out.println("___________________________________");
			System.out.println(name + " : It was bit hard but they smell good :)");
			System.out.println("     -- Energy       = " + energy);	
			
			for (int i = 0; i < numberDogs; i++) { // Resetting values from each dog's object
				int fun = -(int)(Math.random()*((int)20-(int)10 + 1)+10);
				int hunger = +(int)(Math.random()*((int)10-(int)5 + 1)+5);
				int cleanliness = +(int)(Math.random()*((int)100-(int)99 + 1)+99);
				dogArr[i].setFun(fun);				
				dogArr[i].setHunger(hunger);
				dogArr[i].setCleanliness(cleanliness);	
				dogArr[i].setLoyalty();
				System.out.println("___________________________________");
				dogArr[i].bathMsg();						
				System.out.println("     ++ cleanliness = " + cleanliness);
				System.out.println("     ++ hunger      = " + hunger);
				System.out.println("     -- fun         = " + fun);	
			}
		}		
	}		
	public void feeds () {
		if (this.dogFood < numberDogs) {
			System.out.println("___________________________________");
			System.out.println(name + " : I don't have enough foods for my dogs ..\n I need to go buy them :(");
		} else {
			System.out.println("___________________________________");
			System.out.println(name + " : Here you go. eat well :)");
			System.out.println("     -- Dog Foods   = " + -numberDogs);
			
			this.dogFood += -numberDogs;
			
			for (int i = 0; i < numberDogs; i++) { // Resetting values from each dog's object
				int fun = +(int)(Math.random()*((int)25-(int)15 + 1)+15);
				int hunger = -(int)(Math.random()*((int)60-(int)40 + 1)+20);
				dogArr[i].setFun(fun);				
				dogArr[i].setHunger(hunger);			
				dogArr[i].setLoyalty();
				System.out.println("___________________________________");
				dogArr[i].feedMsg();
				System.out.println("     ++ fun         = " + fun);
				System.out.println("     -- hunger      = " + hunger);	
			}
		}
	}
}
















