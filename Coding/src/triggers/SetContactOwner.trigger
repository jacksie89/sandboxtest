trigger SetContactOwner on Contact (before insert, before update) {

	Set<Id> accountIds = new Set<Id>();
	Set<Id> csmUserIds = new Set<Id>();
	Set<Id> salesUserIds = new Set<Id>();
	
	Map<Id, Account> accountMap = new Map<Id, Account>();
	Map<Id, Contact> contactsMap = new Map<Id, Contact>();
	
	String accountType, accountManager, orgOwner;
	
	for(Contact c : Trigger.new){				
		System.debug('Contact name: ' + c.firstName + ' ' + c.lastName);
		accountIds.add(c.accountId); //Build list of contact account ids
	}
	
	//Build a list of accounts based on contact account ids above
	List<Account> accounts = [Select Id, Type, Name, OwnerId, Account_Manager__c, (Select Name, OwnerId from Contacts) From Account Where Id in :accountIds];
		
	for(Account a : accounts){
		accountMap.put(a.Id, a); //Build a map of ids and accounts
	}
	
	//Build a list of active users from the Profiles: Custom - Account Manager, Custom - Support Manager
	List<User> activeCSMUsers = [Select Id from User Where IsActive=True AND (ProfileId='00e20000001crKC' OR ProfileId='00e200000012Bat')];
	
	//Build a list of active users from all Sales Profiles
	List<User> activeSalesUsers = [select user.Id FROM User Where user.profile.name LIKE '%Custom - Sales%' AND user.IsActive=true];
	
	for(User u : activeCSMUsers){
		csmUserIds.add(u.Id); //Build set of active CSM users ids to check for
	}
	
	for(User u : activeSalesUsers){
		salesUserIds.add(u.Id);//Build set of active Sales users ids to check for
	}
	
	for(Contact c : Trigger.new){

		if(accountMap.isEmpty()!= true){
			
			accountType = accountMap.get(c.accountId).Type;
			accountManager = accountMap.get(c.accountId).Account_Manager__c;
			System.debug('CONTACT EMAIL: ' + c.Email);
			//Set contact owner to be account manager(CSM) if Organisation = Customer
			if(accountType == 'Customer'){
				System.debug('Customer Org Owner Id is before: ' + c.OwnerId);
				//Only set the contact owner to be the CSM as long as there is one (active) on the org
				if(csmUserIds.contains(accountManager)){
					c.OwnerId = accountManager;
				}
				System.debug('Customer Org Owner Id is after: ' + c.OwnerId);
			
			//Otherwise set contact owner to be account owner(Sale Rep)
			} else {
				System.debug('Other Org Owner Id is before: ' + c.OwnerId);
				
				orgOwner = accountMap.get(c.accountId).OwnerId;
				//Only set the contact owner to be the Org Owner as long as the org owner is an active Sales user
				if(salesUserIds.contains(orgOwner)){
					c.OwnerId = orgOwner;
				}
				//If org owner is not a Sales rep then the current user will be set as the owner.
				
				System.debug('Other Org Owner Id is after: ' + c.OwnerId);			
			}
			
			// Remove Status Inactive reason for contacts being reactivated
			if(c.Contact_Status__c == 'Active' && c.Status_Inactive_Reason__c != null){
				System.debug('Need to remove this contacts status inactive reason!');
				c.Status_Inactive_Reason__c = '';
			}	
		}					
	}
}