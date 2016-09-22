global class BatchDeleteHubspotLogMessages_Scheduler implements Schedulable{

	global void execute (SchedulableContext SC){ 
		
		String query = 'Select Id From HubSpot_Inc__HubSpot_Log_Message__c Where CreatedDate < LAST_WEEK';
		
		BatchDeleteHubspotLogMessages hubspotLogMessagesDelete = new BatchDeleteHubspotLogMessages(query); 
		database.executeBatch(hubspotLogMessagesDelete); 
	}
}