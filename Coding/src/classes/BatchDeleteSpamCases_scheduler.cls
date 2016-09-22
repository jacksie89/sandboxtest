global class BatchDeleteSpamCases_scheduler implements Schedulable{

	global void execute (SchedulableContext SC){ 
		
		String query = 'Select Id From Case Where OwnerId = \'00G200000017XWWEA2\' And LastModifiedDate < LAST_MONTH';
		
		BatchDeleteSpamCases casesToDelete = new BatchDeleteSpamCases(query); 
		database.executeBatch(casesToDelete); 
	}
}