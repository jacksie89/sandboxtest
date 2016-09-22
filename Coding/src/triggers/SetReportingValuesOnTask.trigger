trigger SetReportingValuesOnTask on Task (before insert, before update) {
	
	for( Task t: Trigger.new ){
		
		//set the value of the custom field "Activity Type"
		t.Activity_Type__c = t.Type;
		
		//If the status is completed and this is a new task, or an existing task updated to completed, set the Date completed
		if(t.Status=='Completed' && Trigger.isInsert){
		t.Date_Completed__c = system.today();
		System.debug('Insert: Date completed set by trigger is: '+ t.Date_Completed__c);
		}
		else if(Trigger.isUpdate && (System.Trigger.oldMap.get(t.Id).Status != 'Completed')){
		t.Date_Completed__c = system.today();
		System.debug('Update: Date completed set by trigger is: '+ t.Date_Completed__c);
		}
}
}