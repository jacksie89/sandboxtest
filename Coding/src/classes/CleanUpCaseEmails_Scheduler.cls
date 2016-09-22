global class CleanUpCaseEmails_Scheduler implements Schedulable{

	global void execute (SchedulableContext SC){ 
		CleanUpCaseEmails cleanup = new CleanUpCaseEmails(); 
		database.executeBatch(cleanup); 
	}
}