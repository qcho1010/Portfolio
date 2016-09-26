//subclass extends from SpaceShip 
public class ColonyShip extends SpaceShip {
	private int passNum = 0;
	private String type = "ColonyShip";
	
	public ColonyShip(String name, int date, int passNum) {
		super.setSpaceShip(name,date);
		setPassNum(passNum);
	}
	@Override
	public String toString() {
		return "Name: " + super.getName() + " | Year: " + super.getDate() + " | Type: " + type + " | Passanger: " + this.passNum;
	}
	public int checkType() {		
		return 1;
	}	
	public int getPassNum() {
		return passNum;
	}
	public void setPassNum(int passNum) {
		this.passNum = passNum;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	@Override
	public int getCapacity() {
		// TODO Auto-generated method stub
		return 0;
	}
}
