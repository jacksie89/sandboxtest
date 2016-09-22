trigger Create_CampaignMember_For_New_Leads on Lead (after insert, after update) {
 /*** SF-2468 Cleanup of Trigger to account for free trial leads only and assignment of leads to 
 		the IC GRADER campaign. Hubspot looks after the assignment of all other leads to campaigns. ***/
 
    try {  
		Integer current_year = System.today().year(); //Calculate current year
            
        String icGraderCamp = 'IC Grader ' + current_year;
        String freeTrialCamp = 'Free Trial FY16'; 
            
        List<Id> icGraderLeadIds = new List<Id>();
        List<Id> freeTrialLeadIds = new List<Id>();

        List<CampaignMember> icCmls = new List<CampaignMember>();
        List<CampaignMember> ftCmls = new List<CampaignMember>();
        Set<Id> campaignMemLeadIds = new Set<Id>();        
        Boolean memberExists;
            
        // Loop through all leads and figure out what campaigns they need to be assigned to
        for(Lead l : Trigger.new) {            	
	       	
	       	if(l.Tactics__c == 'IC Grader'){
	       		icGraderLeadIds.add(l.Id);
	       		System.debug('Adding to IC Grader List...');
            } 
                
            if(l.Free_Trial__c == true){
            	freeTrialLeadIds.add(l.Id);
                System.debug('Adding to Free Trial List...');
            }
       	}
       		
       	// Check if leads need to be added to IC Grader campaign
       	if(icGraderLeadIds.size() > 0){
       			
       		List<Lead> icGraderLeads = [Select Id From Lead Where Id in: icGraderLeadIds];
       		List<Campaign> icCamp = [select id, name from Campaign where name = :icGraderCamp limit 1];	
       		
       		// NEED TO ADD CHECK TO SEE IF CAMPAIGN MEMBER ALREADY EXISTS
       		// List back all campaign members lead ids from campaign
       		List<CampaignMember> campaignMems = [select leadid from CampaignMember where campaignid = :icCamp[0].Id];
       		for(CampaignMember cm : campaignMems){
       			campaignMemLeadIds.add(cm.leadid);
       		}
       		memberExists = false;
       		
       		for(Lead ld : icGraderLeads){ // Loop through list of leads and create campaign members

				CampaignMember icCml = new CampaignMember();
       			memberExists = campaignMemLeadIds.contains(ld.Id);
       			if(!icCamp.isEmpty() & memberExists == false){
       				icCml.campaignid = icCamp[0].id; // Assign campaign member the campaign
                   	icCml.leadid = ld.id;	// Assign campaign member the lead
                   	icCmls.add(icCml);	// Add campaign member to list of members to insert
       			}      				
       		} 
       	}
			
		// Check if leads need to be assigned to Free Trial campaign
       	if(freeTrialLeadIds.size() > 0){
   			List<Lead> freeTrialLeads = [Select Id From Lead Where Id in: freeTrialLeadIds];
   			List<Campaign> ftCamp = [select id, name from Campaign where name = :freeTrialCamp limit 1];
   			
   			// Loop through list of leads and create campaign members
   			for(Lead ld : freeTrialLeads){
   				CampaignMember ftCml = new CampaignMember();
   				
   				if(!ftCamp.isEmpty()){
   					ftCml.campaignid = ftCamp[0].id; // Assign campaign member the campaign
                	ftCml.leadid = ld.id;	// Assign campaign member the lead
                	ftCmls.add(ftCml);	// Add campaign member to list of members to insert	
   				}      				
   			}
   		}
   		 		
   		if(!icCmls.isEmpty()){ // Insert IC Grader campaign members if they exist     
   			insert icCmls;
   		}
   		  		
   		if(!ftCmls.isEmpty()){ // Insert Free Trial campaign members if they exist
   			insert ftCmls;
   		}       		
    
    } catch(Exception e) {
    	system.debug ('error: ' + e.getMessage());
    	system.debug('Stack trace: ' + e.getStackTraceString());
    }
}