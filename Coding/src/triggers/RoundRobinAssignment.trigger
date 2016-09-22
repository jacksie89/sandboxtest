trigger RoundRobinAssignment on Lead (before insert, before update) {

  	if(Trigger.new.size() == 1){ //SINGLE UPDDATE  	  
		System.debug('Single Update...');
		assignToNextInRoundRobinQueue();		
  	}else{ //BATCH ASSIGN LEADS
  		System.debug('Mass Update.. TOTAL: ' + Trigger.new.size());
  		assignLeadsInBatch();
  	}

	/*
	This method is fro Round robin 1 off leads from the web - It takes into account who is next in line to get a lead. 
	*/
	public void assignToNextInRoundRobinQueue(){
		
		for (Lead newLead : Trigger.new) {
			System.debug('Lead: ' + newLead.LastName + ' Owner: ' + newLead.OwnerId);
			// 1.  Establish whether trigger is an insert or update
			if(Trigger.isInsert && !RRHelper.isAlreadyInserted()){
				System.debug('This is an insert in the Round Robin Trigger to the lead: ' + newLead.LastName);
				RRHelper.setAlreadyInserted();			
			}
			if(Trigger.isUpdate && !RRHelper.isAlreadyUpdated()){
				System.debug('This is an update in the Round Robin Trigger to the lead: ' + newLead.LastName);
				//Call doUpdateActions in helper class
				RRHelper.doUpdateActions(newLead, newLead.OwnerId);
				//RRHelper.setAlreadyUpdated();
			}	
		}
	}
	/*
		Needs to be rewritten - removing from Trigger for now - 27/01/15.
	*/
	public void assignLeadsInBatch(){

		/*LIST<User> SalesRREUUsers = [select id, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid = '00G20000001d62uEAA')];
		LIST<User> SalesRRUSUsers = [select id, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid = '00Gw00000018RTl')];
		LIST<User> MktRREUUsers = [select id, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid = '00Gw0000002ANdB')];
		LIST<User> MktRRUSUsers = [select id, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid = '00Gw0000002ANdC')];
		LIST<User> EU0to5KUsers = [select id, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid = '00Gw0000002Sxnl')];
		LIST<User> EU30KUsers = [select id, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid = '00Gw0000002Sxnq')];*/

		List<Group> SalesRREU = [Select Id from Group where Name = 'Sales Round Robin EU' and Type = 'Queue'];
		List<Group> SalesRRUS = [Select Id from Group where Name = 'Sales Round Robin US' and Type = 'Queue'];
		List<Group> MktRREU = [Select Id from Group where Name = 'Mkt Round Robin EU' and Type = 'Queue'];
		List<Group> MktRRUS = [Select Id from Group where Name = 'Mkt Round Robin US' and Type = 'Queue'];
		List<Group> EU0to5K = [Select Id from Group where Name = 'EU Leads 0-5K' and Type = 'Queue'];
		List<Group> EU30K = [Select Id from Group where Name = 'EU Leads 30K+' and Type = 'Queue'];
		List<Group> MktRRUSHot = [Select Id from Group where Name = 'Mkt Round Robin US Hot' and Type = 'Queue'];
		
		List<User> SalesRREUUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: SalesRREU[0].id )];	
		List<User> SalesRRUSUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: SalesRRUS[0].id)];	
		List<User> MktRREUUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: MktRREU[0].id)];	
		List<User> MktRRUSUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: MktRRUS[0].id)];	
		List<User> EU0to5KUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: EU0to5K[0].id)];
		List<User> EU30KUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: EU30K[0].id)];
		List<User> MktRRUSHotUsers = [select id, name, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid =: MktRRUSHot[0].id)];


		Integer i = 0;
		Integer j = 0;
		Integer numberOfSalesRREUUsers = SalesRREUUsers.size();
		Integer numberOfSalesRRUSUsers = SalesRRUSUsers.size();
		Integer numberOfMktRREUUsers = MktRREUUsers.size();
		Integer numberOfMktRRUSUsers = MktRRUSUsers.size();
		Integer numberOfEU0to5KUsers = EU0to5KUsers.size();
		Integer numberOfEU30KUsers = EU30KUsers.size();

		for (Lead l : Trigger.new) {		

			if(l.OwnerId == SalesRREU[0].Id){
				if(j >= SalesRREUUsers.size()){
					j=0;
				}
				l.OwnerId = SalesRREUUsers[j].id;
				j++;

			} else if(l.OwnerId == SalesRRUS[0].Id){	
				if(j >= SalesRRUSUsers.size()){
					j=0;
				}
				l.OwnerId = SalesRRUSUsers[j].id;
				j++;
				 
			} else if(l.OwnerId == MktRREU[0].Id){
				if(j >= MktRREUUsers.size()){
					j=0;
				}
				l.OwnerId = MktRREUUsers[j].id;
				j++; 

			} else if(l.OwnerId == MktRRUS[0].Id){
				if(j >= MktRRUSUsers.size()){
					j=0;
				}
				l.OwnerId = MktRRUSUsers[j].id;
				j++; 

			} else if(l.OwnerId == EU0to5K[0].Id){
				if(j >= EU0to5KUsers.size()){
					j=0;
				}
				l.OwnerId = EU0to5KUsers[j].id;
				j++;

			} else if(l.OwnerId == EU30K[0].Id){
				if(j >= EU30KUsers.size()){
					j=0;
				}
				l.OwnerId = EU30KUsers[j].id;
				j++;
			
			} else if(l.OwnerId == MktRRUSHot[0].Id){
				if(j >= MktRRUSHotUsers.size()){
					j=0;
				}
				l.OwnerId = MktRRUSHotUsers[j].id;
				j++;
			}

		}
	}  
}