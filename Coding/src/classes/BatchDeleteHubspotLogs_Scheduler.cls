global class BatchDeleteHubspotLogs_Scheduler implements Schedulable{

	global void execute (SchedulableContext SC){ 
		
		String query = 'Select Id From HubSpot_Inc__HubSpot_Log__c Where CreatedDate < LAST_WEEK';
		
		BatchDeleteHubspotLogs hubspotLogsDelete = new BatchDeleteHubspotLogs(query); 
		database.executeBatch(hubspotLogsDelete); 
	}
}