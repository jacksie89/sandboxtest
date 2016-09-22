public class AssignLeadOwner {

    ApexPages.StandardSetController sc;

    public AssignLeadOwner(ApexPages.StandardSetController controller) {
        sc = controller;
        sc.addFields(new List<String>{'Email'});
        if(getMySelectedSize() == 0){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No leads selected. Please press the \'Cancel\' button to return'
        			+ ' to the previous screen and then please select 1 or more leads before attempting this action again!'));	
        } else {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'You are about to reassign the following leads. Please indicate if you want to dedupe the leads first by ticking the box.'
        			+ ' They will then be run through the assignment rules if no duplicates have been found. Please press the \'Continue\' button if you are happy with your selection'
        			+ ' or press the \'Cancel\' button to return to the previous page and select your desired leads again.'));
        }
    }

    public integer getMySelectedSize() {
        System.debug('Selected Records: ' + sc.getSelected());
        return sc.getSelected().size();
    }
    public integer getMyRecordsSize() {
        return sc.getRecords().size();
    }
    
    public PageReference save(){
    	
    	List<Lead> selectedLeads = new List<Lead>();
    	List<Lead> leadsToUpdate = new List<Lead>();
    	
    	selectedLeads = sc.getSelected();

        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

    	for(Integer i=0; i<selectedLeads.size(); i++){
    		System.debug('Lead Name: ' + selectedLeads[i].FirstName + ' ' + selectedLeads[i].LastName + ', Dedupe: ' + selectedLeads[i].Dedupe__c);
    		System.debug('Email: ' + selectedLeads[i].Email);
    		Lead l = selectedLeads[i];
    		//l.Dedupe__c = true;
    		l.setOptions(dmlOpts);
    		leadsToUpdate.add(l);
    	}
    	
    	try{
	      update leadsToUpdate;
	      
	    } catch (Exception e){
	      System.debug('Exception caught for lead update. Error: ' + e.getMessage());
	      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The following error has occurred: ' + e));
	    }
	    
	    PageReference pageRef = new PageReference('/00Q'); // Return to lead list view
    	return pageRef;
    }
}