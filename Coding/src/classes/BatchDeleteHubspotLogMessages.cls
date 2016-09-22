global class BatchDeleteHubspotLogMessages implements Database.Batchable<sObject>{
	
	global String email = 'bcasey@newsweaver.com';
	global String query;
    global BatchDeleteHubspotLogMessages(String q){
    	query = q; //Read in the query
    }
    
    global Database.querylocator start(Database.BatchableContext BC){    	
        return Database.getQueryLocator(query);   
    }
        
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		List<HubSpot_Inc__HubSpot_Log_Message__c> allHubspotLogMessagesToDelete = new List<HubSpot_Inc__HubSpot_Log_Message__c>();

		for(sObject s : scope){
           HubSpot_Inc__HubSpot_Log_Message__c hubLogMsg = (HubSpot_Inc__HubSpot_Log_Message__c)s;
           allHubspotLogMessagesToDelete.add(hubLogMsg);
        }
        System.debug('Total HubspotLog Messages to Delete: ' + allHubspotLogMessagesToDelete.size());
        delete allHubspotLogMessagesToDelete;			
    }
    
    global void finish(Database.BatchableContext BC){        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('bcasey@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Delete Hubspot Log Messages Completed');
        mail.setPlainTextBody('Delete Hubspot Log Messages Process has completed.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}