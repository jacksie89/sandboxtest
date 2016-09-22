global class CleanUpCaseEmails implements Database.Batchable<sObject>{
	
	global String email = 'bcasey@newsweaver.com';
	List<Case> allCases = new List<Case>();
	global String query;
     
    global Database.querylocator start(Database.BatchableContext BC){    	
        query = 'SELECT Id, Subject, isScrubbed__c, ClosedDate, (Select id, Subject, CreatedDate FROM case.EmailMessages Order By CreatedDate Desc) FROM Case '
        		+ 'WHERE ClosedDate < LAST_N_MONTHS:6 AND isScrubbed__c = false AND Status LIKE \'%Closed%\' Order By ClosedDate Asc';
        //query = 'SELECT Id, Subject, isScrubbed__c, ClosedDate, (Select id, Subject, CreatedDate FROM case.EmailMessages Order By CreatedDate Desc) FROM Case '
        //		+ 'WHERE ClosedDate > 2013-01-01T00:00:00Z AND ClosedDate < 2013-12-31T23:59:00Z AND Status LIKE \'%Closed%\' Order By ClosedDate Asc';


        System.debug('Query: ' + query);
        return Database.getQueryLocator(query);    
    }
        
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		DateTime temp_date = DateTime.newInstance(2010, 01, 01, 00, 16, 23);
		List<Case> casesToUpdate = new List<Case>();
		List<EmailMessage> emailsToDelete = new List<EmailMessage>();
		
		for(sObject s : scope){
           	Case mycase = (Case)s;
           	System.debug('Case subject: ' + mycase.Subject);
        	
        	//Only want to pull up a case's emails if that case hasn't already been scrubbed
        	if(mycase.isScrubbed__c == false){
        		for(EmailMessage em : mycase.EmailMessages)
    			{
        			System.debug('Temp Date: ' + temp_date);
        			if (em.CreatedDate > temp_date) {
        				System.debug('This is the latest email...');
        				temp_date = em.CreatedDate;

        			} else {
        				System.debug('This is not the latest email...');
        				emailsToDelete.add(em);
        			}        		
    			}
    			mycase.isScrubbed__c = true;
    			casesToUpdate.add(mycase);	
        	} else {
        		System.debug('This case has already been scrubbed - please ignore!!');
        	}
        	
    		temp_date = DateTime.newInstance(2010, 01, 01, 00, 00, 10);    			
		}	
    	
    	update casesToUpdate;
    	delete emailsToDelete;	
    }
    
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('bcasey@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Case Cleanup Completed');
        mail.setPlainTextBody('Case Cleanup Process has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}