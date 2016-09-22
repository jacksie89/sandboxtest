global class BatchDeleteCampaignMembers implements Database.Batchable<sObject>{
	
	global String email = 'bcasey@newsweaver.com';
    global String query;
    
    global BatchDeleteCampaignMembers(String q){
    	query = q; //Read in the query
    }
    
    global Database.querylocator start(Database.BatchableContext BC){    	
        return Database.getQueryLocator(query);   
    }
        
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		List<CampaignMember> allCampaignMembersToDelete = new List<CampaignMember>();
		
		for(sObject s : scope){
           CampaignMember cm = (CampaignMember)s;
           allCampaignMembersToDelete.add(cm);
        }
        System.debug('Total Campaign Members to Delete: ' + allCampaignMembersToDelete.size());
        delete allCampaignMembersToDelete;			
    }
    
    global void finish(Database.BatchableContext BC){        
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('bcasey@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Delete Campaign Members Completed');
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}