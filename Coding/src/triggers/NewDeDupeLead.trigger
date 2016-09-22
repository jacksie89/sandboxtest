trigger NewDeDupeLead on Lead (before insert, before update) {

	List<Lead> incomingLeads = new List <Lead>(); //List to add incoming leads to
	List<Lead> allExistingLeads = new List<Lead>();
	List<Contact> allExistingContacts = new List<Contact>();
	List<User> allAdminUsers = new List<User>();
	
	//Maps for duplicates
	Map<String, Lead> existingLeads = new Map<String, Lead>();
	Map<String, Lead> existingDomains = new Map<String, Lead>();
	Map<String, Lead> existingCompanies = new Map<String, Lead>();
	Map<String, Contact> existingContactDomains = new Map<String, Contact>();
	String currentUser = UserInfo.getUserId();			
	String l_emailDomain, contactDomain; //String to hold email domain
	
	//Build set of Admin User Ids to use in spam checker logic
	Set<String> adminUserIds = new set<string>();
	allAdminUsers = [Select Id, Name From User Where (User.Profile.Name Like '%System Administrator%' OR User.Profile.Name Like '%Hubspot%') AND isActive=true];
	for(User u: allAdminUsers){
		adminUserIds.add(u.Id);
	}

	//Build set of Sales Profile Ids to use in doDeDupeActions method
	Set<String> profIds = new set<string>();
	profIds.add('00e20000001crK7AAI');
	profIds.add('00e20000001crK2AAI');
	profIds.add('00ew00000012Gt6AAE');
	profIds.add('00ew00000012GbeAAE');
	
	//Build set of Sales & Marketing Profile Ids to query back active Sales & Marketing Users
	Set<String> salesMktProfIds = new Set<String>();
	salesMktProfIds.add('00e20000001crK7AAI');
	salesMktProfIds.add('00e20000001crK2AAI');
	salesMktProfIds.add('00ew00000012Gt6AAE');
	salesMktProfIds.add('00ew00000012GbeAAE');
	salesMktProfIds.add('00e20000001crJsAAI'); //Custom - Marketing Uses
	salesMktProfIds.add('00e200000012B5MAAU'); //Custom - Marketing Manager	

	//Query back list of active users from above profiles only and add to map
	Map<Id, User> activeUsers = new Map<Id, User>([Select Id, User.Profile.Id, Name, IsActive from User Where IsActive = true
					AND User.Profile.Id IN :salesMktProfIds]);
	
	//DedupeController.setNotAlreadyRun();
		
	//First check if dedupe flag is set on lead record(s) - only want to dedupe leads if flag is set
	for(Lead newLead : Trigger.new){		
		System.debug('Check 1 on lead email: ' + newLead.Email + ' , created by: ' + newLead.CreatedById);
		System.debug('Dedupe: ' + newLead.Dedupe__c);
		System.debug('Status: ' + newLead.Status);
		System.debug('isAlreadyRun value is: ' + DeDupeController.isAlreadyRun());
		
		// Only dedupe if lead's status is Sales Ready
		if(newLead.Dedupe__c == true && newLead.Status == 'Sales Ready' && newLead.Email != null && !DeDupeController.isAlreadyRun()){
			System.debug('Adding lead to list...');
			incomingLeads.add(newLead);	//First need to build a list of leads being inserted/updated	
		}		
	}
	
	//Only continue with the deduping if we have leads that need to be deduped.
	if(incomingLeads.size() > 0){
		
		//Query back all existing leads whose owners are not the Spam Queue or Marketing Lead Queue
		allExistingLeads = [select Email, Company, OwnerId, RecordTypeId, Reassign__c FROM Lead Where Email != null
	 		And (Status != 'Dead' Or Status != 'Invalid') And OwnerId NOT IN('00G200000017Q51EAE', '00G200000017I6vEAE') Order By CreatedDate ASC];
		
		for(Lead l : allExistingLeads){
			System.debug('Existing lead is: ' + l.Email + ', Owner: ' + l.OwnerId);
			existingLeads.put(l.Email, l); //Build existing email addresses map
			l_emailDomain = getDomainString(l.Email);
			existingDomains.put(l_emailDomain, l); //Build existing email domains map
			existingCompanies.put(l.Company, l); //Build existing companies map
		}		
		
		//Query back all existing contacts
		allExistingContacts	= [Select Id, Email, Account.OwnerId, Account.Status__c From Contact Where Email != null
		 		AND (Contact_Status__c = 'Active' Or Contact_Status__c = 'Pending' Or Contact_Status__c = 'Prospect') 
		 		AND Account.Status__c = 'Active'];	
		
		for(Contact c : allExistingContacts){		
			contactDomain = getDomainString(c.Email);
			existingContactDomains.put(contactDomain, c); //Build existing contact domains map
		}
		
		spamLeadCheck(incomingLeads); //Check for any spam leads in the list of incoming leads
				
		doDedupeChecks(incomingLeads, existingLeads);	//Check for dupes by passing the list of leads
		DeDupeController.setAlreadyRun();	// Indicate that trigger has already been run
	} else {
		System.debug('No leads to dedupe!!');
	}	

	// ***** 	HELPER METHODS 		*****
	
	// Checks for Spam Leads
  	public void spamLeadCheck(List<Lead> leadsToCheck){
      	System.debug('Inside Spam Check, totals leads: ' + leadsToCheck.size());
    	for(Lead newLead : leadsToCheck){
    		
	    	if(((newLead.Spam_Trap__c != null || newLead.FirstName == newLead.LastName) || (newLead.Timestamp_Hashed__c == '11')) && 
				(adminUserIds.contains(currentUser))){ //if current user is an admin user
				newLead.Spam_Lead__c = true;
				newLead.Reassign__c = false; //don't want to reassign the lead
			}
    	}
  	}

	// Checks for duplicates
 	public void doDedupeChecks(List<Lead> allLeads, Map<String, Lead> existingLeadsInfo){
		
		Boolean matchOnEmail, matchOnDomain, matchOnCompany, publicEmail;
		Map<String, Lead> leadEmailAdresses = new Map<String, Lead>(); //Build map of existing leads
		String leadEmailDomain;
		
		//Loop through list of leads passed in and check for matches
		for(Lead l : allLeads){
			matchOnEmail = false;
			matchOnDomain = false;
			matchOnCompany = false;
			publicEmail = false;
			System.debug('COMPANY: ' + l.Company);
			if(l.Spam_Lead__c != true){
				
				//	CHECK FOR MATCH ON EMAIL ADRRESS
				if(existingLeadsInfo.containsKey(l.Email)){	
					System.debug('Existing email address found: ' + l.Email);
					doDeDupeActions(existingLeadsInfo.get(l.Email).RecordTypeId, existingLeadsInfo.get(l.Email).OwnerId, l, profIds);
					matchOnEmail = true;
				}
				
				if(matchOnEmail == false){
					// CHECK FOR MATCH ON EMAIL DOMAIN
					leadEmailDomain = getDomainString(l.Email); //Check email domain..
					if(existingDomains.containsKey(leadEmailDomain)){
						System.debug('Existing email domain found: ' + leadEmailDomain);	
						//Determine if domain is public or not
						publicEmail = isPublicEmailAddress(leadEmailDomain);
						if(publicEmail == true){
							l.Reassign__c = true; //if public reassign the lead otherwise dedupe it
						} else {
							doDeDupeActions(existingDomains.get(leadEmailDomain).RecordTypeId, existingDomains.get(leadEmailDomain).OwnerId, l, profIds);							
						}
						matchOnDomain = true;
					}	
				}
				// CHECK FOR MATCH ON COMPANY
				if(matchOnEmail == false && matchOnDomain == false){
					System.debug('EXISTING COMPANIES: ' + existingCompanies);
					if(existingCompanies.containsKey(l.Company)){
						System.debug('Existing company found: ' + l.Company + ' , for lead: ' + l.Email);	
						doDeDupeActions(existingCompanies.get(l.Company).RecordTypeId, existingCompanies.get(l.Company).OwnerId, l, profIds);
						matchOnCompany = true;
					}
				}
				// CHECK FOR MATCH ON CONTACT DOMAIN
				if(matchOnEmail == false && matchOnDomain == false && matchOnCompany == false){
					
					if(existingContactDomains.containsKey(leadEmailDomain)){
						System.debug('Existing contact email domain found: ' + leadEmailDomain);	
						doDeDupeActions(null, existingContactDomains.get(leadEmailDomain).Account.OwnerId, l, profIds);						
					} else {
						System.debug('No match found anywhere!');
						System.debug('Lead is: ' + l.Email + ' , Reassign is: ' + l.Reassign__c);						
					}
				}
									
			} else {
				System.debug('Lead: ' + l.Email + ' , Spam: ' + l.Spam_Lead__c);
			}			
		}		
	}
  		
	public void doDeDupeActions(Id existingLeadRecordTypeId, Id dupeOwnerId, Lead newLead, Set<String> profileIds){
					
		User myUser = activeUsers.get(dupeOwnerId);

		//If duplicate record owner is a queue reassign the lead otherwise dedupe the lead
		if(myUser == null){
			newLead.Reassign__c = true; 		
		} else {  							
			if(myUser.IsActive){ // Check if User is Active
				System.debug('Dupe Owner is an active user!');
				Profile userProf = myUser.Profile;
				String userProfId = userProf.Id; //Profile Name

				//	Check if lead owner profile is not a Sales User/Sales Manger 			
				if(profileIds.contains(userProfId)){ 
					System.debug('The lead owner is a sales user so set Reassign to false.');						
					newLead.OwnerId = myUser.Id; //Assign lead to duplicate Lead Owner found		
					newLead.Reassign__c = false;
					newLead.Dedupe__c = false; // Indicates that the lead has now been deduped.
				} else {						
					System.debug('The lead owner is not a sales user so set Reassign to true');
					newLead.Reassign__c = true;
				}			
			
			} else { //Inactive User
				newLead.Reassign__c = true;
				System.debug('Dupe Owner is not an active user: ' + newLead.OwnerId);
			}
		}			
	}
  
	private String getDomainString(String emailAddress){
	    
	    String emailDomain = null;
	    String[] firstSplit = emailAddress.split('@'); //splits into 2 parts, 1: username, 2: domain
	    String[] secondSplit;
	    String temp;
	    
	    if(firstSplit != null && firstSplit.size() > 1){
	      	//emailDomain = firstSplit[1]; //assigning emailDomain to be 1st part of split above  
	      	temp = firstSplit[1];
	      	secondSplit = temp.split('\\.'); //Split domain by .
	      	emailDomain = secondSplit[0]; //assign email domain to be the first string in the array created from domain split
	      	return emailDomain;
	    }return emailAddress;
	}
  	
  	// Determines if email address is public
	public boolean isPublicEmailAddress(String domain){
		Set<String> publicDomains = new Set<String>{'gmail', 'yahoo', 'hotmail', 'googlemail', 'live', 'me', 'msn', 'aol'};
		if(publicDomains.contains(domain)){
			return true;
		}
		return false;
	}
}