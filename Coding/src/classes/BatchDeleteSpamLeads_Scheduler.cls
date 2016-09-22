global class BatchDeleteSpamLeads_Scheduler implements Schedulable{

	global void execute (SchedulableContext SC){ 
		BatchDeleteSpamLeads spamLeadsDelete = new BatchDeleteSpamLeads(); 
		database.executeBatch(spamLeadsDelete); 
	}
}