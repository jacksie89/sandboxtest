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
private class TestBatchDeleteHubspotLogMessages {

    static testMethod void myUnitTest() {
        // The query used by the batch job.
		String query = 'Select Id, Name, HubSpot_Inc__HubSpot_Log__c, OwnerId, CreatedDate From HubSpot_Inc__HubSpot_Log_Message__c Where CreatedDate = TODAY';

       	HubSpot_Inc__HubSpot_Log_Message__c[] hubLogMsgsList = new List<HubSpot_Inc__HubSpot_Log_Message__c>();
       	
       	for (Integer i=0;i<10;i++) {
           	//Create new hubspot logs to be deleted by the batch job
           	HubSpot_Inc__HubSpot_Log_Message__c hLogMsg = new HubSpot_Inc__HubSpot_Log_Message__c();               
           	hubLogMsgsList.add(hLogMsg);
       	}
       	insert hubLogMsgsList;

       	Test.startTest();
       	BatchDeleteHubspotLogMessages hsLogMessages = new BatchDeleteHubspotLogMessages(query); //Pass query to class
       	Database.executeBatch(hsLogMessages); //Run batch job
       	Test.stopTest();

       	// Verify hubspot logs got deleted by batch job
       	Integer i = [SELECT COUNT() FROM HubSpot_Inc__HubSpot_Log_Message__c];
       	System.assertEquals(i, 0);    
   	}
}