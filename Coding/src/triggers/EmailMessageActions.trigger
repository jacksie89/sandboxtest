trigger EmailMessageActions on EmailMessage (after insert) {

/* TRIGGER TO CHECK INCOMING EMAIL ADDRESS FROM EMAIL-TO-CASE AND IF IT'S FROM A HP.COM ADDRESS SENDS 
	AN EMAIL TO CLICK-A-TELL WHICH IN TURN SENDS AN SMS ALERT TO SUPPORT NUMBERS WITH CASE NUMBER 
	AND FROM ADDRESS INFO. --- RELATED JIRA: SF-1998 */
		
	String emailDomain = null;
	Set<Id> caseIds = new set<Id>();

	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
	List<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
	    
	for(EmailMessage em : Trigger.new){
		
		//emailCreatedDate = em.CreatedDate.format('MM/dd/yyyy HH:mm:ss');
    	System.debug('Email Address is: ' + em.FromAddress);
	    
	    //Handling email messages with a blank from address
	    try {
		    String[] firstSplit = em.FromAddress.split('@');
		    emailDomain = firstSplit[1];
		    System.debug('First split: ' + emailDomain);
		    
		    if(firstSplit[1] == 'hp.com'){// || firstSplit[1] == 'newsweaver.com'){
		    	System.debug('Email domain is: ' + emailDomain);
		    	caseIds.add(em.ParentId);
		    } else {
		    	System.debug('Non-hp email domain: ' + emailDomain);
		    }	    	
	    } catch (Exception e) {
	    	System.debug('Exception message: ' + e);
	    	em.addError('Email Address is blank!');
	    	return;
	    }
	}
		
	//Map for to hold HP cases and ids
	Map<id, Case> cases = new Map<id, Case>([Select Id, Subject, Origin, CreatedDate From Case Where Id in: caseIds]);
	list<EmailMessage> ems = [Select ParentId From EmailMessage Where ParentId in: caseIds];
	
	for(EmailMessage myEmail: Trigger.new){
		
		//Checks if cases map isn't empty and if the Case Origin is emailing - ensuring we capture email-to-case cases only!	
		if(cases.isEmpty() == false && cases.get(myEmail.ParentId).Origin == 'Email'){
			
			System.debug('Number of emails: ' + ems.size());
			System.debug('Number of cases: ' + cases.size());
			System.debug('Cases Detail: ' + cases);
			//NEED TO ENSURE THAT THIS IS FIRST EMAIL THAT CREATED CASE AND IS NOT A FOLLOW-UP EMAIL
			if(ems.size() == 1){
				System.debug('Case created from hp email!: ' + cases.size());		
				System.debug('Running user is: ' + UserInfo.getUserId());
				//Handle bulk email sending
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTargetObjectId(UserInfo.getUserId());      
	      		mail.setCcAddresses(new String[] {'bcasey@newsweaver.com', 'sms@messaging.clickatell.com'});
			    //mail.setTemplateId('00X11000000I3Th'); //Sandbox Template Id
			    mail.setTemplateId('00Xw0000001pmx1'); //Live Template Id
			    mail.setSaveAsActivity(false);
			    mail.setWhatId(cases.get(myEmail.ParentId).Id);
			    emails.add(mail);	
			} else {
				System.debug('Multiple emails attached to case! DO NOT SEND EMAIL ALERT!!');
			}
								
		} else {
			System.debug('Associated case is not from HP. From Email Address: ' + myEmail.FromAddress);
		}
		
	}
	//
	if(emails.size()>0){
		try{
			System.debug('SEND EMAIL ALERT TO SUPPORT PHONES!!');
			results = Messaging.sendEmail(emails); //One bulk email send request	
		} catch(Exception e) {
			System.debug('Exception on Send Email: ' + e);
		}	
	}
}