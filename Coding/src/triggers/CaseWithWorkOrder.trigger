trigger CaseWithWorkOrder on Case (after insert) {
	
	//Loop thru the cases being processed
	for (Case c : Trigger.new) {
	    
	    /*** Create a Case & Work Orders Link record using the Work Order Id and Case ID. JIRA REF: SF-1772***/
	    
	    if (c.Work_Order__c != null){ /* ONLY WORK THROUGH THIS IF A CASE IS CREATED FROM A WORK ORDER*/

		    CasesWorkOrdersAssociation__c csWOAssoc = new CasesWorkOrdersAssociation__c(Case__c = c.id, Work_Order__c = c.Work_Order__c);
		    insert csWOAssoc;
	    
	    } else if (c.Survey_Name__c != null) { /* FOR STANDALONE CASES CREATED FROM A CONTACT - DO NOTHING.*/
	    	System.debug('The case ' + c.Subject + ' is associated with a low scoring survey. OWNER: ' + c.OwnerId);
	    	System.debug('DESCRIPTION: ' + c.Description);
	    	System.debug('Account Id: ' + c.AccountId);
	    	System.debug('Contact Id: ' + c.ContactId);
	    	System.debug('Associated Survey: ' + c.Survey_Name__c);
	    	
	    }else { /* FOR STANDALONE CASES CREATED FROM A CONTACT - DO NOTHING.*/
	    	System.debug('The case ' + c.Subject + ' is not associated with a work order. OWNER: ' + c.OwnerId);
	    }
	    	    
	}

}