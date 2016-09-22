trigger IfOrgInactiveSetContactsInactive on Account (before update) {	
	
	if(Trigger.isUpdate){
		
		List<Contact> contacts;		 		 
		Set<Id> accountIds = new Set<Id>();
		List<Account> targetedAccounts = new List<Account>();
		Boolean contactsUpdated = false; //Flag to indicate whether or not contacts have been updated
		 
		for (Account a : Trigger.new){
	 		
	 		// *** NEW FILTER TO ONLY TARGET ORGS BECOMING INACTIVE TO AVOID DE-ACTIVATING 
	 		// ACTIVE ORGS CONTACTS. REQUIREMENT AS PER JIRA: SF-2364 ***
	 		
	 		if(a.Status__c == 'Inactive' || a.Status__c == 'Inactive - hosted' || a.Status__c == 'Inactive - nonhosted'
	 		 	||  a.Status__c == 'Sold-written off' || a.Status__c == 'Superseded'){
	 			accountIds.add(a.Id); //Build list of accounts to target
	 		}	
		}
	 	
	 	//Query back a list of contacts for all accounts from above
	 	contacts = [select id, Email, Contact_Status__c from Contact where accountId in :accountIds];
		
		//Query back account to loop through and deactivate contacts
		targetedAccounts = [select Name, Status__c from Account Where Id in : accountIds];
		
		for (Account a : targetedAccounts) { 

			 	//Go through the list of contacts and set to inactive
		 		for (Contact c : contacts) {
		 			c.Contact_Status__c = 'Inactive';
		 			c.Status_Inactive_Reason__c = 'Organisation no longer a client';
		 		}
		 		contactsUpdated = true; //Set flag to indicate contacts have been updated
	 	}	

	 	//Update the list of contacts when 1 one or more exist & only when contacts have been updated
		if(contacts.size() >= 1 && contactsUpdated == true){
			update contacts; //Bulk update action	
		}
	}
}