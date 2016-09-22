/*
    When a Work Order is Completed set the work order completed flag on the associated Change Request.
*/
trigger WorkOrderCompleted on SFDC_Projects__c (after update) {
    try {
        if (Trigger.new.size() == 1){
            for(SFDC_Projects__c p : Trigger.new) {
                 if(p.Work_Order_Status__c == 'Completed'){                                    
                     List <Change_Request__c> c = [select id, name from Change_Request__c where id = :p.Change_Request__c limit 1];
                     if(!c.isEmpty()){
                        c[0].Work_Order_Complete__c = true;
                        update c[0];
                     }
                 }
            } 
        }
    } catch(Exception e) {
        system.debug ('error: ' + e.getMessage() );
    }
}