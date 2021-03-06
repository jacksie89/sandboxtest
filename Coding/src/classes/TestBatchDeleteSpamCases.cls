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
private class TestBatchDeleteSpamCases {

    static testMethod void myUnitTest() {
        // The query used by the batch job.
		String query = 'Select Id, Subject From Case Where CreatedDate = TODAY';

       	Case[] spamCases = new List<Case>();
       	
       	for (Integer i=0;i<10;i++) {
           	//Create new hubspot logs to be deleted by the batch job
           	Case c = new Case(subject='My Test Case ' + i, OwnerId='00G200000017XWWEA2');               
           	spamCases.add(c);
       	}
       	insert spamCases;

       	Test.startTest();
       	BatchDeleteSpamCases cases = new BatchDeleteSpamCases(query); //Pass query to class
       	Database.executeBatch(cases); //Run batch job
       	Test.stopTest();

       	// Verify hubspot logs got deleted by batch job
       	Integer i = [SELECT COUNT() FROM Case];
       	System.assertEquals(i, 0);    
   	}
}