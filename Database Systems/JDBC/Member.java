package netapp;

public class Member {
	String firstName;
	String SecondName;
	String email;
	
	public Member(String firstName, String secondName, String email) {
		super();
		this.firstName = firstName;
		SecondName = secondName;
		this.email = email;
	}

	public String getFirstName() {
		return firstName;
	}

	public String getSecondName() {
		return SecondName;
	}

	public String getEmail() {
		return email;
	}
	
	@Override
	public String toString() {
		return firstName+" "+SecondName+ " ("+email+")";
	}
}
