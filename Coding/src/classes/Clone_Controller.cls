public with sharing class Clone_Controller {

    public Case trainingCase { get; set; }

    public Clone_Controller(ApexPages.StandardController stdController)
    {
        String caseId = ApexPages.currentPage().getParameters().get('case_id');
        //trainingCase = (Case)stdController.getRecord();
        
        // query all necessary fields.
        trainingCase = [select Id, CaseNumber, ContactId, AccountId, ParentId, OwnerId, Onboarding_Related_Opp__c, RecordTypeId,
        				Status, Type, Origin, Priority, Testimonial__c, Complaint__c, Subject, Description, refAccount__c,
        				refPublications__c, refDataCentre__c from Case where Id = :caseId];
    }

   /**
    *  Clone the Summary and save as a new record.  
    *  Return the user to the detail page of the new record.
    * 
   **/
    public PageReference cloneCase()
    {
        Case clonedCase = trainingCase.clone(false,true,false,false);
        insert clonedCase;
        return new PageReference('/' + clonedCase.Id);
    }
}