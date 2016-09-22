global class BatchDeleteNWEmailActivities implements Database.Batchable<sObject>{
	
	global String email = 'bcasey@newsweaver.com';
    global String query;
    
    global BatchDeleteNWEmailActivities(String q){
    	query = q; //Read in the query
    }
    
    global Database.querylocator start(Database.BatchableContext BC){    	
        return Database.getQueryLocator(query);   
    }
        
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		List<newsweav_imprt__Newsweaver_Mailing__c> allNWEmailActivitiesToDelete = new List<newsweav_imprt__Newsweaver_Mailing__c>();
		
		for(sObject s : scope){
           newsweav_imprt__Newsweaver_Mailing__c nwEmailActivity = (newsweav_imprt__Newsweaver_Mailing__c)s;
           allNWEmailActivitiesToDelete.add(nwEmailActivity);
        }
        System.debug('Total NW Email Activities to Delete: ' + allNWEmailActivitiesToDelete.size());
        delete allNWEmailActivitiesToDelete;			
    }
    
    global void finish(Database.BatchableContext BC){        
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('bcasey@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Delete NW Email Activities Completed');
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}