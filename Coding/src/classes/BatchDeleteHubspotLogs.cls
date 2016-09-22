global class BatchDeleteHubspotLogs implements Database.Batchable<sObject>{
	
	global String email = 'bcasey@newsweaver.com';
	global String query;
    global BatchDeleteHubspotLogs(String q){
    	query = q; //Read in the query
    }
    
    global Database.querylocator start(Database.BatchableContext BC){    	
        //query = 'Select Id, Name, OwnerId, CreatedDate From HubSpot_Inc__HubSpot_Log__c Where CreatedDate = TODAY';
        return Database.getQueryLocator(query);   
    }
        
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		List<HubSpot_Inc__HubSpot_Log__c> allHubspotLogsToDelete = new List<HubSpot_Inc__HubSpot_Log__c>();
		System.debug('Debug 2...');
		for(sObject s : scope){
           HubSpot_Inc__HubSpot_Log__c hubLog = (HubSpot_Inc__HubSpot_Log__c)s;
           allHubspotLogsToDelete.add(hubLog);
        }
        System.debug('Total HubspotLogs to Delete: ' + allHubspotLogsToDelete.size());
        delete allHubspotLogsToDelete;			
    }
    
    global void finish(Database.BatchableContext BC){        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('bcasey@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Delete Hubspot Logs Completed');
        mail.setPlainTextBody('Delete Hubspot Logs Process has completed.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}