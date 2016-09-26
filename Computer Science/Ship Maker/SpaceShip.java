//Super class that shares the attributes of date and name with ColonyShip and Cargo Ship
public abstract class SpaceShip {
	private String name = "";
	private int date = 0;
	
	public void setSpaceShip(String name, int date) {
		this.name = name;
		this.date = date;		
	}	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}	
	public int getDate() {
		return date;
	}
	public void setDate(int date) {
		this.date = date;
	}		
	public abstract String toString();
	public abstract int checkType();
	public abstract int getPassNum();
	public abstract int getCapacity();
}