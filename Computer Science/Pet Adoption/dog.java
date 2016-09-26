package p3;

//Subclass dog extends from mammal superclass
public class dog extends mammal {	
	// Randomly generating dog's attributes
	private int hunger = (int) (Math.random()*((int)60-(int)40 + 1)+40);
	private int fun = (int) (Math.random()*((int)60-(int)40 + 1)+40);
	private int cleanliness = (int) (Math.random()*((int)60-(int)40 + 1)+40);
	private int loyalty = (int) (Math.random()*((int)60-(int)40 + 1)+40);
	private int id = 0;

	public dog(String name, int id) {		
		if (.5 < Math.random()){ // Randomly generate dog's gender
			super.sex = "m";
		} else {
			super.sex = "f";
		}		
		super.weight = (double) (Math.random()*((double)100-(double)30 + 1)+30); // Randomly generate dog's weight
		
		super.name = name;		
		this.id = id;
	}	
	// Display all dog's attributes
	public void info (){ 
		System.out.printf("%s %5s %s %8s %3s %2s %2s %6.2f %s %4d %3s %3d %1s %6d %6s %4s %4s\n","|","Dog #"+ (id+1),"|" ,
				super.name, "|",super.sex,"|",super.weight,"|",this.hunger,"|",this.fun,"|",this.cleanliness,"|",this.loyalty,"|");	
		System.out.println("|________|____________|_____|________|________|_____|_____________|_________|");
	}	
	//----------------------------------------------------------------------------------------------------
	// Flowing methods are setter and getter function to access and modify the private attributes.
	//----------------------------------------------------------------------------------------------------
	public int getFun() {
		return fun;
	}
	public void setFun(int fun) {
		this.fun += fun;
		if (this.fun > 100) {
			this.fun = 100;
		} else if (this.fun < 0) {
			this.fun = 0;
		}		
	}
	//----------------------------------------------------------------------------------------------------
	public int getLoyalty() {
		return loyalty;
	}
	public void setLoyalty() {
		if (fun > 100-hunger) {
			this.loyalty = fun;
		} else if (fun > 100-hunger) {
			this.loyalty = 100-hunger;
		}		
	}
	//----------------------------------------------------------------------------------------------------		
	public int getHunger() {
		return hunger;
	}
	public void setHunger(int hunger) {
		this.hunger += hunger;
		if (this.hunger > 100) {
			this.fun = 100;
		} else if (this.hunger < 0) {
			System.out.println(name + " : I'm too full!");
			this.hunger = 0;
		}
	}	
	//----------------------------------------------------------------------------------------------------
	public int getCleanliness() {
		return cleanliness;
	}
	public void setCleanliness(int cleanliness) {
		this.cleanliness += cleanliness;
		if (this.cleanliness > 100) {
			this.cleanliness = 100;
		} else if (this.cleanliness < 0) {	
			System.out.println(name + " : I need to bath!");
			this.cleanliness = 0;
		}
	}
	//----------------------------------------------------------------------------------------------------
	// Flowing methods are to display dog's messages based on human's performed action.
	//----------------------------------------------------------------------------------------------------
	public void walkMsg() { 
		int ranNum = (int)(Math.random()*((int)100-(int)0 + 1)); // Randomly generate dog's msg
		if (ranNum < 25) {
			System.out.println(name + " : I can't wait to walk again!");
		} else if (ranNum < 50) {
			System.out.println(name + " : I love walking with my Master!");
		} else if (ranNum < 75) {
			System.out.println(name + " : Always feel great to brething fresh air!");
		} else if (ranNum <= 100) {
			System.out.println(name + " : It was FUN!!");
		}
	}	
	public void bathMsg() {
		int ranNum = (int)(Math.random()*((int)100-(int)0 + 1));
		if (ranNum < 25) {
			System.out.println(name + " : I feel so fresh!!");
		} else if (ranNum < 50) {
			System.out.println(name + " : I don't like getting wet");
		} else if (ranNum < 75) {
			System.out.println(name + " : Warm water makes me chill~");
		} else if (ranNum <= 100) {
			System.out.println(name + " : I almost got drowned!");
		}
	}	
	public void feedMsg() {
		int ranNum = (int)(Math.random()*((int)100-(int)0 + 1));
		if (ranNum < 25) {
			System.out.println(name + " : Finally eatting!");
		} else if (ranNum < 50) {
			System.out.println(name + " : Thank you Master!");
		} else if (ranNum < 75) {
			System.out.println(name + " : Always feel great to eat yummy foods!");
		} else if (ranNum <= 100) {
			System.out.println(name + " : Yummy I'm so full");
		}
	}	
	public void timePassMsg() { 
		int ranNum = (int)(Math.random()*((int)100-(int)0 + 1));
		if (ranNum < 25) {
			System.out.println(name + " : Staying home alone is Boring..");
		} else if (ranNum < 50) {
			System.out.println(name + " : I'm getting hungry..");
		} else if (ranNum < 75) {
			System.out.println(name + " : Where's my master at?.. I miss him");
		} else if (ranNum <= 100) {
			System.out.println(name + " : I want to play...!!");
		}
	}
}

