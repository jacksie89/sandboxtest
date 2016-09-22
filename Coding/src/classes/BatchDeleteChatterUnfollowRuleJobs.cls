global class BatchDeleteChatterUnfollowRuleJobs implements Database.Batchable<sObject>{
	
	global String email = 'bcasey@newsweaver.com';
	global String query;

    global BatchDeleteChatterUnfollowRuleJobs(String q){
    	query = q; //Read in the query
    }     

    global Database.querylocator start(Database.BatchableContext BC){    	
        return Database.getQueryLocator(query);   
    }
            
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		List<chttrunfollow__UnfollowRuleJob__c> allChatterJobsToDelete = new List<chttrunfollow__UnfollowRuleJob__c>();
		for(sObject s : scope){
           chttrunfollow__UnfollowRuleJob__c chturj = (chttrunfollow__UnfollowRuleJob__c)s;
           allChatterJobsToDelete.add(chturj);
        }
        delete allChatterJobsToDelete;			
    }
    
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('bcasey@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Delete Chatter Unfollow Rule Jobs Completed');
        mail.setPlainTextBody('Delete Chatter Unfollow Rule Jobs has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}