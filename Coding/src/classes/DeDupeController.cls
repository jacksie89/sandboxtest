public with sharing class DeDupeController {

	 // initialize a variable to hold state
	private static boolean alreadyRun = false;
	
	// get the state
	public static boolean isAlreadyRun() {
		return alreadyRun;
	}
	 
	// set this to true to keep track of and avoid recursive updates. Generally set after first time through
	// a trigger. We can access this in the trigger and avoid recursive updates...
	
	public static void setAlreadyRun() {
		alreadyRun = true;
	}
	
	public static void setNotAlreadyRun() {
		alreadyRun = false;
	}
}