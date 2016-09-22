public class RRHelper {
	public static List<Group> SalesRREU = [Select Id from Group where Name = 'Sales Round Robin EU' and Type = 'Queue'];
	public static List<Group> SalesRRUS = [Select Id from Group where Name = 'Sales Round Robin US' and Type = 'Queue'];
	public static List<Group> MktRREU = [Select Id from Group where Name = 'Mkt Round Robin EU' and Type = 'Queue'];
	public static List<Group> MktRRUS = [Select Id from Group where Name = 'Mkt Round Robin US' and Type = 'Queue'];
	public static List<Group> EU0to5K = [Select Id from Group where Name = 'EU Leads 0-5K' and Type = 'Queue'];
	public static List<Group> EU30K = [Select Id from Group where Name = 'EU Leads 30K+' and Type = 'Queue'];
	public static List<Group> MktRRUSHot = [Select Id from Group where Name = 'Mkt Round Robin US Hot' and Type = 'Queue'];
	
	public static List<User> SalesRREUUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: SalesRREU[0].id )];	
	public static List<User> SalesRRUSUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: SalesRRUS[0].id)];	
	public static List<User> MktRREUUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: MktRREU[0].id)];	
	public static List<User> MktRRUSUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: MktRRUS[0].id)];	
	public static List<User> EU0to5KUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: EU0to5K[0].id)];
	public static List<User> EU30KUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: EU30K[0].id)];
	public static List<User> MktRRUSHotUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: MktRRUSHot[0].id)];
	
	// *** PREVENTION FOR MULTIPLE RUNS OF THE TRIGGER ***
	 // initialize a variable to hold state
	private static boolean alreadyInserted = false;
	private static boolean alreadyUpdated = false;
	
	// get the state
	public static boolean isAlreadyInserted() {
		return alreadyInserted;
	}

	public static boolean isAlreadyUpdated() {
		return alreadyUpdated;
	}
	 
	// set this to true to keep track of and avoid recursive updates. Generally set after first time through
	// a trigger. We can access this in the trigger and avoid recursive updates...
	
	public static void setAlreadyInserted() {
		alreadyInserted = true;
	}
	public static void setAlreadyUpdated() {
		alreadyUpdated = true;
	}	
	
	public static void setNotAlreadyInserted() {
		alreadyInserted = false;
	}	
	public static void setNotAlreadyUpdated() {
		alreadyUpdated = false;
	}
	
	public static void doUpdateActions(Lead lead, Id OwnerId){
		// *** ORIGINAL CODE ***
		System.debug('LEAD OWNER ID: ' + lead.OwnerId);
		if(lead.OwnerId == SalesRREU[0].Id){ //This is the Id of the Round RobinGroup.--LIST<Group> groups = [SELECT Id FROM Group WHERE Name = 'RoundRobin']; - Removed this to cut down on queries.
			
			for (User usr: SalesRREUUsers){
				System.debug(usr.name);
			}
			assignToUser(SalesRREUUsers, lead);
			
		} else if(lead.OwnerId == SalesRRUS[0].Id){	

			for (User usr: SalesRRUSUsers){
				System.debug(usr.name);
			}
			assignToUser(SalesRRUSUsers, lead);
		
		} else if(lead.OwnerId == MktRREU[0].Id){ // Marketing Round Robin EU

			for (User usr: MktRREUUsers){
				System.debug(usr.name);
			}
			assignToUser(MktRREUUsers, lead);
		
		} else if(lead.OwnerId == MktRRUS[0].Id){ // Marketing Round Robin US

			for (User usr: MktRRUSUsers){
				System.debug(usr.name);
			}
			assignToUser(MktRRUSUsers, lead);

		} else if(lead.OwnerId == EU0to5K[0].Id){
			System.debug('RR doUpdateActions...');
			assignToUser(EU0to5KUsers, lead);
		
		} else if(lead.OwnerId == EU30K[0].Id){
			System.debug('RR doUpdateActions...');
			assignToUser(EU30KUsers, lead);
		
		} else if(lead.OwnerId == MktRRUSHot[0].Id){
			System.debug('RR doUpdateActions...');
			assignToUser(MktRRUSHotUsers, lead);
		}
		// *** END ORIGINAL CODE ***
	}
	
	public static void assignToUser(List<User> groupUsers, Lead lead){
		
		boolean isset = false;
	
		//Keeping track of who has already been assigned a lead...		    		    
	    for (User u : groupUsers){                    
	        if(u.received_RR_Lead__c == false){
	            lead.OwnerId = u.Id;
	            u.received_RR_Lead__c = true;
	            isset = true;
	            update u;
	            sendMail(u, lead.Id);
	            break;
	        }
	    }
    	if(isset == false){ // everybody has a lead so start again..
	        //loop through again and set them all to false
	        for (User u : groupUsers){
	            //set the first one to true
	            u.received_RR_Lead__c = false;
	            update u;
	        }
	        //set the first one to true
	        groupUsers[0].received_RR_Lead__c = true;
	        lead.OwnerId = groupUsers[0].Id;
	        update groupUsers[0];
	        sendMail(groupUsers[0], lead.Id);
    	}   	
	}
	
	public static void sendMail(User u, id leadId){		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
	    mail.setTargetObjectId(u.id);	    
	    mail.setTemplateId('00X20000001ZWtlEAG');
	    mail.setSaveAsActivity(false);
	    mail.setWhatId(leadId);	    
	    results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}