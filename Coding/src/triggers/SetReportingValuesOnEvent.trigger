trigger SetReportingValuesOnEvent on Event (before insert, before update) {
	
	for( Event e: Trigger.new ){
		
		//set the value of the custom field "Activity Type"
		e.Activity_Type__c = e.Type;
		
		//
		If(e.Event_Status__c=='Completed'  && (Trigger.isInsert || (Trigger.isUpdate && (System.Trigger.oldMap.get(e.Id).Event_Status__c != 'Completed')))){
		e.Date_Completed__c = system.today();
		}
	}
}