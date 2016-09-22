public class PortalUserHelper {

//Async method, using @future, to create the User record and associate it to the previously created Contact
//This uses @future because you can not have mixed DML operations for standard objects (Account, Contact) and Setup objects(User)
//NOTE - Must invoke a @future method to be able to create Account, Contacts, and Users in the same Apex Transaction
	    
    @future 
    public static void createUser(String theContacts) {
        
        String userAlias, u_alias, u_nickname, u_nickname_temp;
        String lastName, surName, error, action;
        
        Integer aliasRandomInt, i, j; 
		
		Set<string> currentContactAliases = new Set<string>();
		Set<string> currentContactNicknames = new Set<string>();
		
		User portalUserToUpdate = new User();
		
		Map<String, User> myusernames = new Map<String, User>();
		Map<String, User> currentUserNicknames = new Map<String, User>();
				
        List<User> portalUsersToCreate = new List<User>();
        List<User> portalUsersToUpdate = new List<User>();
        List<User> allUsers = new List<User>();
           
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom - Customer Community Login User'];
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;
        
        //Deserialize JSON string
        System.debug('JSONCONTACTSUPDATE2: ' + theContacts);
        List<Contact> helperContacts = (List<Contact>)JSON.deserialize(theContacts, List<Contact>.class);
        System.debug('Contacts deserialized: ' + helperContacts);
        
        allUsers = [Select id, Username, CommunityNickname, Registered__c from User Where ProfileId='00ew00000012H1j']; // 1. List back all community users
                
        for(User usr : allUsers){
        	myusernames.put(usr.Username, usr);
        	currentUserNicknames.put(usr.CommunityNickname, usr); // 2. Build map of users and their nicknames
        }        
		System.debug('CONTENTS OF MYUSERNAMES: ' + myusernames);        
        j=2; //Integer to append to nickname if duplicate found.
        
        //Loop through each contact, setup user details, set IC/EC flags & add to list of users to create
        for(Contact c : helperContacts){	
        	//Check myusernames map to see if a user already exists for the contact email address.
        	if(myusernames.containsKey(c.Email) == false){
        	
        		u_nickname = c.FirstName + ' ' + c.LastName;
	        	surName = c.LastName;
	        	
	        	surName = checkLastName(surName); //Need to ensure last name contains at least 4 characters
	        	userAlias = (c.FirstName.substring(0,1) + surName.substring(0, 4)).toLowerCase();
				
				//Check both current list of user nicknames and list of contact nicknames being inserted
				if(currentUserNicknames.containsKey(u_nickname) || currentContactNicknames.contains(u_nickname)){

					do{ //Generate new alias until the new alias is not found in list of current aliases
						u_nickname_temp = u_nickname + j;
						j++;	
					} while (currentUserNicknames.containsKey(u_nickname_temp) || currentContactAliases.contains(u_nickname_temp));
					
					u_nickname = u_nickname_temp;
					currentContactNicknames.add(u_nickname); //add new nickname to list of contact nicknames
					j=2; //Reset Integer to 2 after it has been used
				
				} else { //Nickname doesn't already exist
					currentContactNicknames.add(u_nickname); //add unique nickname to list of contact nicknames
				}
				
				//Build User Record        
	        	User myPortalUser = new User(Username = c.Email, LastName = c.LastName, FirstName = c.FirstName, ContactId = c.Id, 
					Email = c.Email, EmailEncodingKey='UTF-8', Alias=userAlias, LanguageLocaleKey='en_US', 
					LocaleSidKey='en_GB', ProfileId = p.Id, TimeZoneSidKey='Europe/London',
					CommunityNickname = u_nickname, UserPreferencesHideS1BrowserUI = true, 
					UserPermissionsSFContentUser = false, UserPreferencesContentNoEmail = true, 
					UserPreferencesContentEmailAsAndWhen = true);

				//Check number of internal & external accounts on Contact Record to determine user type			
				System.debug('NUM INT ACS: ' + c.Number_of_Internal_Accounts__c);
				System.debug('NUM EXT ACS: ' + c.Number_of_External_Accounts__c);
				System.debug('NUM ENT ACS: ' + c.Number_of_Enterprise_Accounts__c);
				if(c.Number_of_Internal_Accounts__c > 0 && c.Number_of_External_Accounts__c > 0){ //Combined User     		
	        		System.debug('Need to create an Internal & External Portal User!');
	        		myPortalUser.ICUser__c = true;
	        		myPortalUser.ECUser__c = true;
	        		portalUsersToCreate.add(myPortalUser); //Build list of users
	        	
	        	} else if(c.Number_of_Internal_Accounts__c > 0 || c.Number_of_Enterprise_Accounts__c > 0){ // for internal or enterprise users - SF-2525
	        		System.debug('Need to create an Internal Portal User!');
					myPortalUser.ICUser__c = true;
					portalUsersToCreate.add(myPortalUser); //Build list of users
	        	
	        	} else if(c.Number_of_External_Accounts__c > 0){
	        		//External User Only
	        		System.debug('Need to create an External Portal User!');
	        		myPortalUser.ECUser__c = true;
	        		portalUsersToCreate.add(myPortalUser);
	        	
	        	} else {
	        		System.debug('Don\'t create a Portal User!');
	        	}
        	
        	} else { //User already exists
        		
        		portalUserToUpdate = myusernames.get(c.Email); //Get user record from map
	        	
	        	//Call method to check contact certification programme       		
	        	portalUserToUpdate = checkContactCertificationProgramme(c.Certification_Programme__c, portalUserToUpdate);
				
        		if(c.Number_of_Internal_Accounts__c > 0 && c.Number_of_External_Accounts__c > 0){ //Combined User     		
	        		System.debug('Need to update an Internal & External Portal User!');
	        		portalUserToUpdate.ICUser__c = true;
	        		portalUserToUpdate.ECUser__c = true;
	        		portalUsersToUpdate.add(portalUserToUpdate); //Build list of users
	        	
	        	} else if(c.Number_of_Internal_Accounts__c > 0  || c.Number_of_Enterprise_Accounts__c > 0){ // for internal or enterprise users - SF-2525	        		
	        		System.debug('Need to update an Internal Portal User!');
					portalUserToUpdate.ICUser__c = true;
	        		portalUsersToUpdate.add(portalUserToUpdate); //Build list of users
	        	
	        	} else if(c.Number_of_External_Accounts__c > 0){ //External User Only	        		
	        		System.debug('Need to update an External Portal User!');
	        		portalUserToUpdate.ECUser__c = true;
	        		portalUsersToUpdate.add(portalUserToUpdate); //Build list of users	
        		}    		        		        		      			     					
        	}		       
    	}
    	
    	//Create Or Update Users accordingly
        if(portalUsersToCreate.size() > 0){     	
        	System.debug('Call method to create portal users!');
        	createOrUpdateUsers(portalUsersToCreate, 'Create'); //Call method to create users
 	
        } else if(portalUsersToUpdate.size() > 0){ //Update existing user records
        	System.debug('Call method to update portal users!');
       		createOrUpdateUsers(portalUsersToUpdate, 'Update'); //Call method to update users
        }    	
    }

	public static User checkContactCertificationProgramme(String certProgramme, User commUser){
		// SF-2318: Update 'Registered' checkbox on user
		if(certProgramme == 'Registered' || certProgramme == 'Certified'){
			commUser.Registered__c = true;
		} else {
			commUser.Registered__c = false;
		}
		return commUser;
	}

	//Method to create or update users
	public static void createOrUpdateUsers(List<User> thePortalUsers, String actionType){

        List<Database.SaveResult> ActionResults;
        Map<String, User> ErrorMessages = new Map<String, User>();
        String error;
        
        if(actionType == 'Create'){
        	ActionResults = Database.insert(thePortalUsers, false);
        
        } else {
        	ActionResults = Database.update(thePortalUsers, false);
        }    
			
		for(Integer z=0; z < ActionResults.size(); z++){
        	Database.SaveResult result = ActionResults[z];
        	error = null;

			if(!result.isSuccess()){
			   	System.debug('Not Successful');
			    		
			   	for(Database.Error dbe : result.getErrors()){
			   		error += dbe.getMessage()+' ';
			   		ErrorMessages.put(error, thePortalUsers.get(z));
			   	}		 	
			 } 
		}
		//Check for error messages and send via email if any found.
		if(ErrorMessages.size() > 0){
		  	sendExceptions(ErrorMessages, actionType);
		} else {
		 	assignPermissionSets(thePortalUsers); //Assign permission set to users	
		}		
	}
		
	//Deactivate any portal users whose contact status has been set to 'Inactive'
	@future 
    public static void deactivateUser(String theUsers) {
        
        Database.DMLOptions dmopts = new Database.DMLOptions();
        dmopts.EmailHeader.triggerUserEmail = false;
        List<Database.SaveResult> DeactivateResults;
        Map<String, User> ErrorMsgs = new Map<String, User>();
        String error;
        
        List<User> usersToDeactivate = (List<User>)JSON.deserialize(theUsers, List<User>.class);
        
        if(usersToDeactivate.size() > 0){
        	
        	DeactivateResults = Database.update(usersToDeactivate, false);
			    
			for(Integer z=0; z < DeactivateResults.size(); z++){
			 	
			 	Database.SaveResult result = DeactivateResults[z];			    	
			    error = null;
								
			    if(!result.isSuccess()){
			    	System.debug('Not Successful');
			    		
			    	for(Database.Error dbe : result.getErrors()){
			    		error += dbe.getMessage()+' ';
			    		ErrorMsgs.put(error, usersToDeactivate.get(z));
			    	}		 	
			    }
			 }
			 
			 if(ErrorMsgs.size() > 0){ //Check for error messages and send via email if any found.
			  	sendExceptions(ErrorMsgs, 'DEACTIVATE');
			 }	
        }    	
    }
    
	public static String checkUserAlias(String alias_to_check){
		System.debug('Alias to check: ' + alias_to_check);
		return alias_to_check;
	}

	//Function to generate random integer to append to last name if it's too short
    public static Integer getRandomInt (Integer lower, Integer upper)
	{
		return Math.round(Math.random() * (upper - lower)) + lower;
	} 

	//Function called to check that last name contains at least 4 characters, if not then correct this
	public static String checkLastName (String lastName){
		Integer i = 1;
		Integer j = 10;
		Integer aliasRandomInt;
		String l_lastName;
		l_lastName = lastName;
		
		if(l_lastName.length() == 3){
    		//append the number 1 onto the end of the last name
    		System.debug('Last Name is too short: ' + l_lastName);
    		aliasRandomInt = getRandomInt(i, 9);
    		l_lastName = l_lastName + aliasRandomInt;
    		System.debug('Last Name is now okay: ' + l_lastName);
        	
        	//Need to generate 2 random digits to add to last name if it only contains 2 characters
    	} else if (l_lastName.length() == 2) {
    		System.debug('Last Name is too short: ' + l_lastName);
    		aliasRandomInt = getRandomInt(j, 99); //ensure at least a double digit number is returned
    		l_lastName = l_lastName + aliasRandomInt;
    		System.debug('Last Name is now okay: ' + l_lastName);
    	}
    	return l_lastName;
	}
	   
    public static void assignPermissionSets(List<User> portalUsersToCreate){
    	
    	//Query the PermissionSet object to get the Id of the Permission Set
    	PermissionSet psIC = [Select Id from PermissionSet Where Name = 'IC_Community'];
    	PermissionSet psEC = [Select Id from PermissionSet Where Name = 'EC_Community'];
    	
    	//Create new list of PermissionSetAssignment type
    	List<PermissionSetAssignment> PSAssignmentsIC = new List<PermissionSetAssignment>();
    	List<PermissionSetAssignment> PSAssignmentsEC = new List<PermissionSetAssignment>();
   		
   		//Query List of User Ids from each permission set
   		List<PermissionSetAssignment> UserIdsICPermission = [Select Assignee.Id From PermissionSetAssignment Where PermissionSet.Name='IC_Community'];
   		List<PermissionSetAssignment> UserIdsECPermission = [Select Assignee.Id From PermissionSetAssignment Where PermissionSet.Name='EC_Community'];
   		Set<Id> ICUserIds = new Set<Id>();
   		Set<Id> ECUserIds = new Set<Id>();
   		
   		for(PermissionSetAssignment psa : UserIdsICPermission){
   			ICUserIds.add(psa.Assignee.Id);
   		}
   		
   		for(PermissionSetAssignment psasn : UserIdsECPermission){
   			ECUserIds.add(psasn.Assignee.Id);
   		}
   		   		
    	for(User u : PortalUsersToCreate){
	    	
	    	//Need to prevent assignment of duplicate permission set to user
	
    		if(u.ICUser__c && u.ECUser__c && (ICUserIds.contains(u.Id) == false && ECUserIds.contains(u.Id) == false)){	   			
    			PSAssignmentsIC.add(new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psIC.ID));
    			PSAssignmentsEC.add(new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psEC.ID));
    		
    		} else if(u.ICUser__c && ICUserIds.contains(u.Id) == false){
    			PSAssignmentsIC.add(new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psIC.ID));
    		
    		} else if(u.ECUser__c == true && ECUserIds.contains(u.Id) == false) {
    			PSAssignmentsEC.add(new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = psEC.ID));
    		}
    	}   	
    	
    	//Manage insertion of PermissionSetAssignments
    	if(PSAssignmentsIC.size() > 0 && PSAssignmentsEC.size() > 0){ //Combined User
    		insert PSAssignmentsIC;
    		insert PSAssignmentsEC;
    	} else if(PSAssignmentsIC.size() > 0){ //Internal User Only
    		insert PSAssignmentsIC;
    	} else {
    		insert PSAssignmentsEC; //External User Only
    	}
    }
    
    //Method to send email when Error is encountered during database insert/update of users.
    public static void sendExceptions(Map<String, User> userExceptions, String action){
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
		String body = '';
		
		for(String usr : userExceptions.keySet()){
			body += 'ERROR: ' + usr + ', Problem occurred on user ' + action + ' for contact: ' + userExceptions.get(usr).FirstName + ' ' 
				+ userExceptions.get(usr).LastName + ' => Contact ID: ' + userExceptions.get(usr).ContactId;
			body += '\n';
		}
		System.debug(body);
		String[] toAddresses = new String[] {'bcasey@newsweaver.com'};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Exception occurred on Portal User ' + action);
		mail.setSaveAsActivity(false);
		mail.setHtmlBody(body);
		System.debug('Sending Email'); 
		results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
	}
}