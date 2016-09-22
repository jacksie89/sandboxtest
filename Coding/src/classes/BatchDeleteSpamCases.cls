global class BatchDeleteSpamCases implements Database.Batchable<sObject>{
	
	global String email = 'bcasey@newsweaver.com';
	global String query;

    global BatchDeleteSpamCases(String q){
    	query = q; //Read in the query
    }     
    /*global Database.querylocator start(Database.BatchableContext BC){    	
        query = 'Select Id From Case Where OwnerId = \'00G200000017XWWEA2\' And LastModifiedDate < LAST_MONTH';
        return Database.getQueryLocator(query);   
    }*/

    global Database.querylocator start(Database.BatchableContext BC){    	
        return Database.getQueryLocator(query);   
    }
            
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		List<Case> allCasesToDelete = new List<Case>();
		for(sObject s : scope){
           Case l = (Case)s;
           allCasesToDelete.add(l);
        }
        delete allCasesToDelete;			
    }
    
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('bcasey@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Delete Spam Cases Completed');
        mail.setPlainTextBody('Delete Spam Cases Process has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}