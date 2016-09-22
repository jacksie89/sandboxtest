trigger CreatePortalUserFromContact on Contact (after insert, after update) {
	
	/*** WHEN A NEW CONTACT IS CREATED, OR AN EXISTING CONTACT UPDATED, NEED TO 
		CHECK THE CONTACT'S FLAG TO DETERMINE WHERE OR NOT THE CONTACT NEEDS TO 
		BE SET UP AS A CUSTOMER PORTAL USER***/
	
	String JSONcontacts, JSONcontactsUpdate, JSONusers, UserName, Email, FullName; //, contactEmail, tmp_UserName;
	Id userId;	
	
	Set<id> contactIds = new Set<id>();
	Set<String> currentConEmails = new Set<String>();
	
	List<Contact> myContacts = new List<Contact>();
	List<Contact> myContactsForUpdating = new List<Contact>();
	//List<Contact> consToUpdate = new List<Contact>();
	List<User> allUsers = new List<User>();
	
	if(Test.isRunningTest()){
		System.debug('Test code is running... ');
		allUsers = [Select Id, ContactId, Username, FirstName, LastName, IsActive, IsPortalEnabled, Name, Email from User Where IsActive = true LIMIT 100];
	} else {
		allUsers = [Select Id, ContactId, Username, FirstName, LastName, IsActive, IsPortalEnabled, Name, Email from User Where IsActive = true];		
	}
	//List<User> allUsers = [Select Id, ContactId, Username, FirstName, LastName, IsActive, IsPortalEnabled, Name, Email from User Where IsActive = true];
	List<User> usersToUpdate = new List<User>();
	List<User> usersToDeactivate = new List<User>();
	
	//Map<String, Contact> allContacts = new Map<String, Contact>();
	Map<String, User> users = new Map<String, User>();

	/* NEW CODE IMPROVEMENTS - BEGIN	*/
	
	for(Contact c : Trigger.new){
		if(Trigger.isUpdate){
			System.debug('Trigger Update, contact is: ' + c.Email);
		}
		System.debug('Contact being inserted: ' + c.Email + ', ID: ' + c.Id);
	
		//Deal with contacts with a status of Inactive
		if(c.Contact_Status__c == 'Inactive'){
			System.debug('Contact Status is Inactive - Find & Deactivate Portal User');
		}
		
		//Split contacts into internal and external
		if((c.Number_of_Internal_Accounts__c > 0 || c.Number_of_External_Accounts__c > 0 || c.Number_of_Enterprise_Accounts__c > 0) || (c.FirstName == 'Contact')){
			contactIds.add(c.id); //Add to list of contacts to be created as Portal Users
			System.debug('Contact has internal or external accounts!');
		} else {
			System.debug('Contact has no internal or external accounts!');
		}		
	}
        
	for(User u : allUsers){
		users.put(u.Username, u); //Build map https://plus.google.com/u/0/stream/circles/p3738120d0a3228adof usernames and users
	}

	List<Contact> mixedContacts = [Select id, Contact_Status__c, Certification_Programme__c, Number_of_Internal_Accounts__c, Number_of_External_Accounts__c, Number_of_Enterprise_Accounts__c, Email, FirstName, LastName, Name from Contact Where id in :contactIds];	
	//System.debug('MIXED CONTACTS.. ' + mixedContacts);
	for(Contact c : mixedContacts){
		//Check current users against contact email address
		if(users.containsKey(c.Email) || currentConEmails.contains(c.Email)){
			
			User contactUser = users.get(c.Email); //Pull back user from map
			FullName = users.get(c.Email).Name;
			UserName = users.get(c.Email).Username;
			System.debug('------------------------');
			System.debug('CONTACT NAME: ' + c.Name + ' => STATUS: ' + c.Contact_Status__c);
			System.debug('------------------------');
			System.debug('MATCHING USER:' + FullName + ', ' + Username + ' => ACTIVE: ' + users.get(c.Email).isActive);			
			System.debug('------------------------');
			
			//Deactivate contact's user if it is active
			if(c.Contact_Status__c == 'Inactive'){			
				
				if(contactUser.IsActive){
					contactUser.IsActive = false;
					contactUser.IsPortalEnabled = false; //Removes association to contact
					contactUser.Username = '_' + contactUser.Username;
					usersToDeactivate.add(contactUser);				
				}
			//Check for updates to internal or external accounts on contact record	
			} else {
				myContactsForUpdating.add(c);
			}
					
		} else {
			System.debug('No matching user found for contact: ' + c.Email);
			myContacts.add(c); //Build list of contacts to be created as users
			currentConEmails.add(c.Email);
		}
	}
	System.debug('MYCONTACTS FOR UPDATING: ' + myContactsForUpdating);
	//Check if there are any users to deaactivate
	if(usersToDeactivate.size() > 0){
		System.debug('Total number of users to be deactivated: ' + usersToDeactivate.size());
		JSONusers = JSON.serialize(usersToDeactivate); //Serialize list of contacts into JSON string to pass into @future method
		System.debug('JSONUsers: ' + JSONUsers);
		PortalUserHelper.deactivateUser(JSONusers);
	}
	//Check if there are any contacts who need portal users	
	if(myContacts.size() > 0 && !ProcessorControl.isAlreadyModified()){
		System.debug('Total number of users to be created: ' + myContacts.size());
		JSONcontacts = JSON.serialize(myContacts); //Serialize list of contacts into JSON string to pass into @future method
		PortalUserHelper.createUser(JSONcontacts);
				
	}
	//Check if there are any contacts that need to be updated
	if(myContactsForUpdating.size() > 0 && !ProcessorControl.isAlreadyModified()){
		System.debug('Total number of users to be updated: ' + myContactsForUpdating.size());
		JSONcontactsUpdate = JSON.serialize(myContactsForUpdating); //Serialize list of contacts into JSON string to pass into @future method
		System.debug('JSONCONTACTSUPDATE: ' + JSONcontactsUpdate);
		PortalUserHelper.createUser(JSONcontactsUpdate);	
	}
	ProcessorControl.setAlreadyModified();
	/* NEW CODE IMPROVEMENTS - END	*/
}