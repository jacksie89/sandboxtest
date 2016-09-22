trigger CaseComplaintSetOrgAtRisk on Case (before update) {
	
	Set<id> accountIds = new Set<id>();
	List<Account> selectedAccounts = new List<Account>();
	List<Account> accountsToUpdate = new List<Account>();	
	 
	//account = [Select id, name, At_Risk__c from Account where id=:c.accountId];
	for (Case c: Trigger.new){
		
		if(c.Complaint__c == True || c.Rate_Customer_Satisfaction__c == 'Very Unhappy'){
			accountIds.add(c.accountId);
		}
	}
	//Bulkifying trigger by creating list of account ids for affected cases
	//then querying a list of accounts based on account id list
	selectedAccounts = [Select name, At_Risk__c from Account where id in:accountIds];
	
	//Looping through list of accounts and setting At_Risk flag to true, then adding to list of accounts to update
	for (Account a: selectedAccounts){
		if(a.At_Risk__c == false){
			a.At_Risk__c = True;
			accountsToUpdate.add(a);
		}
	}
	//Only call update on list of acccounts to update if the list is not empty
	if(accountsToUpdate.size() > 0){
		update accountsToUpdate;	
	}
	
}