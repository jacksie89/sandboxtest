/*
	When a Work Order is created set the status on the associated Change Request to Creating.
*/
trigger WorkOrderCreated on SFDC_Projects__c (after insert) {
    try {
        if (Trigger.new.size() == 1){
            for(SFDC_Projects__c p : Trigger.new) {
				 List <Change_Request__c> c = [select id, name from Change_Request__c where id = :p.Change_Request__c limit 1];
				 if(!c.isEmpty()){
				 	c[0].Status__c = 'Creating';
				 	update c[0];
				 }
				 
				 /*** Create a Case & Work Orders Link record using the Work Order Id and Case ID. JIRA REF: SF-1772***/
				
				if (p.Case__c != null){ /* ONLY WORK THROUGH THIS IF A CASE IS CREATED FROM A WORK ORDER*/
					CasesWorkOrdersAssociation__c csWOAssoc = new CasesWorkOrdersAssociation__c(Case__c = p.Case__c, Work_Order__c = p.id);
		    		insert csWOAssoc;
				} else {
					System.debug('The Work Order ' + p.Name + ' is not associated with a case.');
				}					
           	} 
        }
    } catch(Exception e) {
        system.debug ('error: ' + e.getMessage() );
    }
}