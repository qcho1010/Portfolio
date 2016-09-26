//subclass extends from SpaceShip 
public class CargoShip extends SpaceShip {	
	private int capacity = 0;
	private String type = "CargoShip";
	
	public CargoShip (String name, int date, int capacity) {
		super.setSpaceShip(name,date);
		setCapacity(capacity);
	}	
	@Override
	public String toString() {
		return "Name: " + super.getName() + " | Year: " + super.getDate() + " | Type: " + type + " | Capacity: " + this.capacity + " tons";
	}	
	public int checkType() {		
		return 2;
	}	
	public int getCapacity() {
		return capacity;
	}
	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	@Override
	public int getPassNum() {
		// TODO Auto-generated method stub
		return 0;
	}	
}
