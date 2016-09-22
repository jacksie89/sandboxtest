public with sharing class WorkOrderTasksController {
  

    public final SFDC_Projects__c proj{get;set;}

		
    public WorkOrderTasksController(ApexPages.StandardController controller){      
        proj = (SFDC_Projects__c)controller.getRecord();         
    }
    
    public PageReference save() 
    {

      update proj; 
      return null;
      
    }
}