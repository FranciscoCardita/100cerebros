package aula2.prob1;

import aula1.prob2.Data;

public class Staff extends Client {

	// Fields
	private final int staffID;
	private final int nif;

	// Constructors
	public Staff(String name, int cc, Data bDate, int clientID, Data signUpDate, int staffID, int nif) {
		super(name, cc, bDate, clientID, signUpDate);
		this.staffID = staffID;
		this.nif = nif;
	}
	
	// Methods
	public boolean equals(Staff s) {
		return super.equals(s) && (staffID == s.staffID) && (nif == s.nif);
	}
	
	@Override
	public String toString() {
		return super.toString() + "\nStaff ID: " + staffID + "\nNIF: " + nif;
	}

}
