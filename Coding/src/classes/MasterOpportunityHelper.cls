public class MasterOpportunityHelper {
	
  	// *** PREVENTION FOR MULTIPLE RUNS OF THE TRIGGER ***
	
  	// initialize a variable to hold state
  	private static boolean alreadyInserted = false;
  	private static boolean alreadyUpdated = false;
  	public static Map<Id, Opportunity> oppsDealTypes = new Map<Id, Opportunity>();
  	// get the state
  	public static boolean isAlreadyInserted() {
    	return alreadyInserted;
  	}
   
  	// set this to true to keep track of and avoid recursive updates. Generally set after first time through
  	// a trigger. We can access this in the trigger and avoid recursive updates...
  
  	public static void setAlreadyInserted() {
    	alreadyInserted = true;
  	}
  
  	// Methods that MasterOpportunityTrigger can call
  
  	public static void doOpportunityTrigger(list<Opportunity> oppsToUpdate){    
		System.debug('DEBUG 1... ');    
	    // ***** VARIABLES *****
	    String caseType;
	    
	    List<Contact> theContacts = new List<Contact>();
	    List<Case> masterCasesToCreate = new List<Case>();
	    List<Case> billingCases = new List<Case>();    
	    List<OpportunityContactRole> oppContactRoleIds = new List<OpportunityContactRole>();    
	    List<RecordType> caseRecordType = [Select Id From RecordType Where Name = 'Master Case'];
	    List<Group> onboardingQueue = [Select Id From Group Where Name = 'New Onboarding Queue'];
	    List<Case> actualBillingCasesToCreate = new List<Case>();
	       
	    Set<Id> oppIds = new Set<Id>();
	    Set<Id> oppAccountIds = new Set<Id>();
	    Set<Id> masterCasesRelatedOppIds = new Set<Id>();
	    Set<Id> myContactIds = new Set<Id>();    
	    Set<Id> billingCasesWithParents = new Set<Id>();
	    Set<String> accOnboardingSolCategories = new Set<String>{'New Customer', 'New Account (Existing Customer)', 'Account Upgrade', 'Other'};
	    Map<Id, Id> oppsContacts = new Map<Id, Id>();
	    Map<Id, Case> oppsBillingCases = new Map<Id, Case>();
	    
	    
	    // Loop through each opportunity to update
	    for(Opportunity opp : oppsToUpdate) {
	    	oppIds.add(opp.Id); // Add each opp id to a Set
	      	oppAccountIds.add(opp.AccountId); // Add each opp's account id to a Set
	    }
    
	    // Build map of opp accounts based on account ids gathered above
	    Map<Id, Account> oppAccounts = new Map<Id, Account>([SELECT Status__c, Type, Communication_Type_Org__c, Name FROM Account WHERE Id IN :oppAccountIds]); 
	    
	    // Build a list of all contact roles on all opportunities
	    List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>(
	      	[Select OpportunityId, Contact.Id, Contact.Name From OpportunityContactRole Where isPrimary=true And OpportunityId IN :oppIds]);
	    
	    // Loop through list of all opps contact roles and build map of Opportunity Id and Primary Contact Id
	    for(OpportunityContactRole ocr : oppContactRoles){
	      	System.debug('Opportunity ID: ' + ocr.OpportunityId + ', Contact ID: ' + ocr.ContactId);
	      	oppsContacts.put(ocr.OpportunityId, ocr.ContactId);
	    }
	
	    // ***** PERFORM OPERATIONS ON CONTACTS *****
	    
	    //Create a list of Opportunity Contact Roles from opp ids above   
	    oppContactRoleIds = [SELECT ContactId FROM OpportunityContactRole WHERE opportunityId IN :oppIds];
	  
	    for (OpportunityContactRole ocr : oppContactRoleIds){
	      	myContactIds.add(ocr.ContactId); //Build list of contact ids from contact roles    
	    }
	
	    //Create a list of Contacts from contact ids gathered above
	    theContacts = ([ SELECT Contact_Status__c FROM Contact WHERE id IN :myContactIds]);
	  
	    //Loop through each Contact and update the status to active
	    for (Contact c : theContacts){
	      	c.Contact_Status__c = 'Active';  
	    }
      
    	update theContacts; //Make one call to update the list of contacts    


    	// ***** PERFORM OPERATIONS ON CASES *****
    
    	// Generate a list of all existing billing cases for all opportunities being updated
	    List<Case> existingBillingCases = [Select Onboarding_Related_Opp__c, Id, Subject, ParentId from Case
	                 Where Onboarding_Related_Opp__c IN :oppIds And ParentId != null And RecordType.Name Like '%Billing%'];
	    
	    // Loop through this list of existing Billing Cases and build a map of billing cases for opps with the opp id as the key
	    for(Case c : existingBillingCases){
	      	oppsBillingCases.put(c.Onboarding_Related_Opp__c, c);
	    }
	        
	    // Build list of master cases for all opps being processed
	    List<Case> masterCasesForOpps = [Select Id, Onboarding_Related_Opp__c From Case Where Onboarding_Related_Opp__c IN :oppIds And RecordType.Name Like '%Master%'];
	    
	    // Loop through list of master cases generated above and build set of opp ids for each case
	    for(Case c : masterCasesForOpps){
	      	masterCasesRelatedOppIds.add(c.Onboarding_Related_Opp__c);
	    }
	      
	    for(Opportunity opp : oppsToUpdate) {    
			System.debug('OPPS TO UPDATE: ' + opp.Name + ': ' + opp.Solution_Category__c);		    	        
	      	String contactId = oppsContacts.get(opp.Id); // Pull this opportunity's contact Id from map built above
	        Account oppAccount = oppAccounts.get(opp.AccountId); // Get opp's account details from map       
	        oppsDealTypes.put(opp.Id, opp);
	        // FIRST CHECK OPP FOR RENEWAL DEAL TYPES AND IF FOUND SET CASE TYPE ACCORDINGLY
	        if(opp.Deal_Type__c == 'Renewal'){
	        	caseType = 'Contract Renewals';
	        
	        // OTHERWISE CHECK SOLUTION CATEGORIES AND SET CASE TYPE ACCORDINGLY
	        } else if(accOnboardingSolCategories.contains(opp.Solution_Category__c)){
	        	caseType = 'Account Onboarding';
	        } else if(opp.Solution_Category__c == 'Additional Quota'){
	        	caseType = 'Additional Emails';
			} else if(opp.Solution_Category__c == 'Add User Licences'){
				caseType = 'Additional Users';
	        } else {
	        	caseType = 'Services';
	        }
	      	
	      	// Check set built above for case related opps to see if this opportunity already has a Master Case associated with it - CREATE IF NONE FOUND
	      	if(!masterCasesRelatedOppIds.contains(opp.Id)){
	        
		        //Create Master onboarding case
		        Case masterCase = new Case(AccountId=opp.AccountId, contactId=contactId, Onboarding_Related_Opp__c=opp.Id, Type=caseType, 
		              Status='Deal closed - Pending action', Subject='Master onboarding case', Communication_Type__c=opp.Communication_Type__c, 
		              Origin='Closed Opportunity', Priority='Medium', RecordTypeId=caseRecordType[0].Id, OwnerId=onboardingQueue[0].Id);
		        masterCasesToCreate.add(masterCase);      
	      	}
	      
	      	// Check the map of billing cases built above to see if this opp already has a billing case associated with it - CREATE IF NONE FOUND
	      	if(oppsBillingCases.get(opp.Id) != null){
	        	billingCasesWithParents.add(oppsBillingCases.get(opp.Id).ParentId); //Build a map of parentIds and billing case ids         
	      	}
	    }

		// Call method doOrganisationUpdates and pass map of opps and orgs to it
		doOrganisationUpdates(oppAccounts, oppsToUpdate);
		
	    // Only insert master cases if opps have no related master cases above
	    if(masterCasesToCreate.size() != 0){
	    	insert masterCasesToCreate;    
	    }
	       
	    if(isAlreadyInserted() == false){
	      
	      	//Query back all master cases from database
	     	List<Case> masterOnboardingCases = [Select contactId, CurrencyIsoCode, Onboarding_Related_Opp__c, Id, 
	                  Subject from Case Where Onboarding_Related_Opp__c IN :oppIds And RecordType.Name Like '%Master%'];
	
	      	//Check map of parentIds and billing case ids built above to see if billing case already exists for Opportunity - CREATE IF NOT
	      	for(Case c : masterOnboardingCases){
	        	if(!billingCasesWithParents.contains(c.Id)){
	          		actualBillingCasesToCreate.add(c);
	        	}
	      	}
	                   
	      	//Call method to create billing cases for all onboarding cases
	      	if(actualBillingCasesToCreate.size() > 0){
	        	billingCases = createBillingCases(actualBillingCasesToCreate);
	        	insert billingCases;  // Insert new billing cases for master onboarding cases    
	      	}        
	    }              
  	}

	public static void doOrganisationUpdates(Map<Id, Account> oppsWithAccounts, List<Opportunity> theOpportunities){
    	
    	String oppCommsType, orgCommsType;
    	Account theOrg;
    	List<Account> orgsToUpdate = new List<Account>();
    	Map<Id, Account> orgsToUpdate2 = new Map<Id, Account>();
    	
    	for(Opportunity opp : theOpportunities){
			
			theOrg = oppsWithAccounts.get(opp.AccountId);	// Pull the opportunity's organisation from the map
			oppCommsType = opp.Communication_Type__c;
			orgCommsType = theOrg.Communication_Type_Org__c;
			
	      	// Compare opp and org Communication Types
	      	if(orgCommsType == null && oppCommsType != null){
	      		theOrg.Communication_Type_Org__c = oppCommsType; // Assign Opp Comms Type to Org Comms Type if blank
	      		//orgsToUpdate.add(theOrg);
	      		orgsToUpdate2.put(theOrg.Id, theOrg);
	      	} else if(orgCommsType != oppCommsType){
	      		theOrg.Communication_Type_Org__c = 'Internal Comms; External Comms'; // If Org Comms Type differs - assign it both values
	      		//orgsToUpdate.add(theOrg);
	      		orgsToUpdate2.put(theOrg.Id, theOrg);
	      	}
    	}
      	System.debug('OrgsToUpdateMap: ' + orgsToUpdate2);
      	
      	for(Account a : oppsWithAccounts.values()){
			// Check opp's account details and update account if necessary
      		if(a.Status__c != 'Active' && a.Status__c != 'Pending'){
        		a.Status__c = 'Pending';
        		a.Type = 'Customer';
        		orgsToUpdate2.put(a.Id, a);
      		}      		
      	}
      	// Add any accounts added orgToUpdate map to a list in order to be able to execute update dml statement      	
      	for(Account a : orgsToUpdate2.values()){
      		orgsToUpdate.add(a);
      	}
      	
      	// Check if there are any orgs to update
      	if(orgsToUpdate.size() > 0){
      		update orgsToUpdate;
      	}
  	}
  
  	public static void doCheckForDuplicateProduct(list<Opportunity> oppsToCheck){
		
    	//List<string> PriceBookIds = new List<string>();    
    	Set<String> PriceBookIds = new Set<String>();
    	Set<String> mySet = new Set<String>();
    	Set<Id> oppIds = new Set<Id>();
    	
    	for(Opportunity opp : oppsToCheck){
    		// Build a set of oppIds to query back later
    		oppIds.add(opp.Id);
    	}
    	
    	Map<Id, OpportunityLineItem> oppLinesMap = new Map<Id, OpportunityLineItem>([ SELECT Id, SortOrder, PricebookEntryId FROM OpportunityLineItem WHERE OpportunityId IN :oppIds ]);
	    
	    for(Opportunity opp : oppsToCheck) {    
	    	
	      	//oppLinesMap = new Map<Id, OpportunityLineItem>([ SELECT Id, SortOrder, PricebookEntryId FROM OpportunityLineItem WHERE OpportunityId = :opp.Id ]);
	      	
	      	for(Id id : oppLinesMap.keySet()){
	        	PriceBookIds.add(oppLinesMap.get(id).PricebookEntryId);
	      	}	      
	      	mySet.addAll(PriceBookIds);
	      	System.debug('PriceBookIds: ' + PriceBookIds);
	      	System.debug('mySet: ' + mySet);
	      	
	      	if(!PriceBookIds.isEmpty()){
	      	  
	      		if(mySet.size() != PriceBookIds.size()){
	        		
	        		if(!Test.isRunningTest()){
	            		opp.addError('The same product cannot appear more than once on an Opportunity.');
	          		} else {
	            		System.debug('The same product cannot appear more than once on an Opportunity.');
	          		}  
	        	} else {
	        		System.debug('Check for Duplicate Product is okay...');
	        	}  
	      	}
	    }
  	}
 	
 	// METHOD TO AUTOMATICALLY SET THE OPPORTUNITY SOLUTION BASED ON THE OPPORTUNITY LINE ITEMS
	public static Map<Id, String> setOpportunitySolutionType(list<Opportunity> oppsToCheck){

    	Set<Id> oppIds = new Set<Id>();   	
    	Set<String> enterpriseProducts = new Set<String>{'enterprise account'};
    	Set<String> standardProducts = new Set<String>{'internal connect account', 'customer connect account'};
    	Set<String> liteProducts = new Set<String>{'lite account', 'internal connect lite', 'customer connect lite'};    	
    	
    	Map<Id, String> oppsSolutionTypes = new Map<Id, String>();
    	
    	for(Opportunity opp : oppsToCheck){ 		
    		oppIds.add(opp.Id); // Build a set of oppIds to query back later
    	}
    	Map<Id, OpportunityLineItem> oppLinesMap = new Map<Id, OpportunityLineItem>([ SELECT Id, Name, Description, SortOrder, OpportunityId, PricebookEntryId FROM OpportunityLineItem 
    												WHERE OpportunityId IN :oppIds ]);
		
		for(OpportunityLineItem oli : oppLinesMap.values()){
			
			String productName = oli.Name;
			productName = productName.toLowerCase(); // Downcase the product name for comparison purposes
			
			// First check for products that are upgrade products
			if(productName.contains('enterprise upgrade')){
				oppsSolutionTypes.put(oli.OpportunityId, 'enterprise');
								
			} else if(productName.contains('internal connect upgrade') || productName.contains('customer connect upgrade')){
				oppsSolutionTypes.put(oli.OpportunityId, 'Standard');				
			}
			
			// If not upgrade product then check if product is Enterprise/Standard/Lite/Non Core Product
			for (String s : enterpriseProducts){
				if(productName.contains(s) && !productName.contains('upgrade')){
					oppsSolutionTypes.put(oli.OpportunityId, 'Enterprise');
					break;
				}
			}

			for (String s : standardProducts){
				if(productName.contains(s) && !productName.contains('upgrade')){
					oppsSolutionTypes.put(oli.OpportunityId, 'Standard');
					break;
				}
			}			

			for (String s : liteProducts){
				if(productName.contains(s) && !productName.contains('upgrade')){
					oppsSolutionTypes.put(oli.OpportunityId, 'Lite');
					break;
				}
			}
			
			if(oppsSolutionTypes.isEmpty()){
				oppsSolutionTypes.put(oli.OpportunityId, 'Non Core Products');	
			}
		}
		return oppsSolutionTypes;		
	} 
  
  	public static List<Case> createBillingCases(List<Case> masterCases){
    
	    List<Case> billingCasesToReturn = new List<Case>();
	    List<RecordType> billingCaseRecordType = [Select Id From RecordType Where Name = 'Billing'];
	    System.debug('CREATE BILLING CASES, TOTAL MASTER CASES: ' + masterCases.size());
	    
	    for(Case c : masterCases){
	    	System.debug('Opp Deal Type for this master case is: ' + oppsDealTypes.get(c.Onboarding_Related_Opp__c).Deal_Type__c);  
	      	//Create Billing case
	      	Case billingCase = new Case(contactId=c.contactId, CurrencyIsoCode=c.CurrencyIsoCode, Onboarding_Related_Opp__c=c.Onboarding_Related_Opp__c, 
	            	ParentId=c.Id, RecordTypeId=billingCaseRecordType[0].Id, Status='New', Subject='Billing onboarding case', Opportunity_Deal_Type__c=oppsDealTypes.get(c.Onboarding_Related_Opp__c).Deal_Type__c);
	      	billingCasesToReturn.add(billingCase);      
	    }  
	    setAlreadyInserted();
	    
	    return billingCasesToReturn;
  	}    
}