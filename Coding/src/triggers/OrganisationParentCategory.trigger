trigger OrganisationParentCategory on Account (before insert, before update) {
//If this Account has child Accounts - and the Category has changed - Update the child category.
	list<ID> listMyChildAccounts = new list<ID>();
	Map<ID, Account> mapMyChildAccounts = new Map<ID, Account>();
	
	list<ID> listMyParentAccount = new list<ID>();
	Map<ID, Account> mapMyParentAccount = new Map<ID, Account>();
	
	/*Create 3 separate lists for countries to assign to each region*/
	list<String> europeCountries = new list<String>();
	list<String> restOfWorldCountries = new list<String>();
	list<String> UKCountries = new list<String>();
	list<String> USCountries = new list<String>();
	list<String> IRLCountries = new list<String>();
	
	for ( Account account : Trigger.new )
	{	
		/*** TEST FOR LIST OF COUNTRIES TO CHECK AGAINST ***/
		account.Organisation_Region__c = CountryRegionMapper.getRegion(account);
						
		if(Trigger.isUpdate){				
			Account beforeUpdate = System.Trigger.oldMap.get(account.Id);
			if(account.Category__c != beforeUpdate.Category__c){
				//get Child Accounts:
				listMyChildAccounts.add(account.Id);
				mapMyChildAccounts.put(account.Id, account);
			}
			if(account.ParentId != null && account.parentId != beforeUpdate.ParentId){
				listMyParentAccount.add(account.ParentId);
				mapMyParentAccount.put(account.ParentId, account);
			}
			
			/*** TEST FOR LIST OF COUNTRIES TO CHECK AGAINST ***/
			//account.Organisation_Region__c = CountryRegionMapper.getRegion(Trigger.new);
						
		}if(Trigger.isInsert){
			//check if this Account has a parentId
			if(account.ParentId != null){
				mapMyParentAccount.put(account.ParentId, account);
				listMyParentAccount.add(account.ParentId);
			}
		}
	}
		
	list<Account> accountsToUpdate = new list<Account>();
	
	for (Account childAccount : [select Category__c, id, ParentId from Account where ParentId in :listMyChildAccounts]){
		childAccount.Category__c = mapMyChildAccounts.get(childAccount.ParentId).Category__c;
		accountsToUpdate.add(childAccount);
	}
	
	for (Account parentAccount : [select Category__c from Account where Account.Id in :listMyParentAccount]){
		mapMyParentAccount.get(parentAccount.Id).Category__c = parentAccount.Category__c;
	}

	update accountsToUpdate;
}