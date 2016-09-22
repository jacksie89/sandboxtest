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
private class TestBatchDeleteNWEmailActivities {

    static testMethod void myUnitTest() {
		
		String query = 'Select Id, CreatedDate, newsweav_imprt__Contact__c, newsweav_imprt__Lead__c, newsweav_imprt__Issue__r.Name From newsweav_imprt__Newsweaver_Mailing__c' + 
				' Where CreatedDate = TODAY AND (NOT (newsweav_imprt__Issue__r.Name LIKE \'%Group_Webinar%\' OR newsweav_imprt__Issue__r.Name LIKE \'%Tactical%\' OR' +
				' newsweav_imprt__Issue__r.Name LIKE \'%Internal%\' OR newsweav_imprt__Issue__r.Name LIKE \'%Employee%\' OR newsweav_imprt__Issue__r.Name LIKE \'%IC Matters%\'))';

       	newsweav_imprt__Newsweaver_Mailing__c[] nwEmailActivitiesList = new List<newsweav_imprt__Newsweaver_Mailing__c>();
       	
       	for (Integer i=0;i<10;i++) {
           	//Create new hubspot logs to be deleted by the batch job
           	newsweav_imprt__Newsweaver_Mailing__c nwEmailActivity = new newsweav_imprt__Newsweaver_Mailing__c(Name = 'Top Ten Tips');               
           	nwEmailActivitiesList.add(nwEmailActivity);
       	}
       	insert nwEmailActivitiesList;

       	Test.startTest();
       	BatchDeleteNWEmailActivities bd = new BatchDeleteNWEmailActivities(query);
       	Database.executeBatch(bd); //Run batch job
       	Test.stopTest();

       	// Verify hubspot logs got deleted by batch job
       	Integer i = [SELECT COUNT() FROM newsweav_imprt__Newsweaver_Mailing__c];
       	System.assertEquals(i, 0);    
   	}
}