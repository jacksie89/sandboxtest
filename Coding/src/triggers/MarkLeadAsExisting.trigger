trigger MarkLeadAsExisting on Lead ( before insert) {
	
 	for (Lead newLead : Trigger.new) {
	  if (Trigger.new.size() == 1) { // no bulk processing;
	  	//Get the Lead company
	  	System.debug(newLead.Company);
	  	//search for a match in Salesforce
	  	List <Account> matchOnCompany = [Select a.Category__c From Account a Where (a.Name = :newLead.Company or a.Trading_as_Name__c = :newLead.Company) and a.Status__c = 'Active' and a.Type = 'Customer']; //Company Match
	  	if(matchOnCompany.size() >= 1){
	  		//set the existing flag if a match is found
	  		newLead.Existing_Customer__c = true;	
	  		newLead.Category__c = matchOnCompany[0].Category__c; 
	  	}else{
	  		newLead.Category__c = 'Standard Account';
	  	}	  	 	  		  	 
	  }
	}
}