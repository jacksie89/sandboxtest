/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestWorkOrderCompleted {

    static testMethod void testCompletedWorkOrderWithChangeRequest() {
    	Change_Request__c cr = new Change_Request__c(Summary__c = 'Steph New Change Request');
    	insert cr;
    	
    	        //create first Project
        Account newAccount = new Account (name='XYZ Organization');
        newAccount.BillingCountry = 'Ireland';
        insert newAccount;
        
        Contact newContact = new Contact (FirstName='Joe', 
                                         LastName='Schmoe',
                                         AccountId=newAccount.id,
                                         email='bizofemail@newsweaver.com');
		newContact.MailingCountry = 'Ireland';
		newContact.OtherCountry = 'Ireland';
        insert newContact;
         
        SFDC_Projects__c project1 = new SFDC_Projects__c (Contact__c = newContact.Id, 	No_Templates__c = 3, Organisation__c = newAccount.Id, Change_Request__c = cr.id, Start_Date__c = System.now(), Expected_Completion_Date__c = System.now());
        insert project1;
        
        System.assertEquals(false, cr.Work_Order_Complete__c);
        project1.Work_Order_Status__c = 'Completed';
        update project1;
        // get the cr again
        final List <Change_Request__c> cr2 = [select Work_Order_Complete__c from Change_Request__c where id = :cr.id];
        System.assertEquals(true, cr2[0].Work_Order_Complete__c);
        
   
    }
}