global class BatchDeleteSpamLeads implements Database.Batchable<sObject>{
	
	global String email = 'bcasey@newsweaver.com';
	global String query;
     
    global Database.querylocator start(Database.BatchableContext BC){    	
        //query = 'Select Id, CreatedDate from Lead Where Spam_Lead__c = True And CreatedDate < 2014-10-31T23:59:00Z And OwnerId=\'00G200000017Q51\'';
        //query = 'Select Id, CreatedDate from Lead Where Spam_Lead__c = True And CreatedDate < LAST_N_DAYS:30 And OwnerId=\'00G200000017Q51\'';
        query = 'Select Id, CreatedDate from Lead Where (Spam_Lead__c = True OR Timestamp_Hashed__c = \'11\') And CreatedDate < LAST_N_DAYS:30 And OwnerId=\'00G200000017Q51\'';
        return Database.getQueryLocator(query);   
    }
        
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		List<Lead> allLeadsToDelete = new List<Lead>();
		for(sObject s : scope){
           Lead l = (Lead)s;
           allLeadsToDelete.add(l);
        }
        delete allLeadsToDelete;			
    }
    
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('bcasey@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Delete Spam Leads Completed');
        mail.setPlainTextBody('Delete Spam Leads Process has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}