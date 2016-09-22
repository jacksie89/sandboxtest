@isTest
private class TestBatchDeleteChatterUnfollowRuleJobs {

    static testMethod void myUnitTest() {
        // The query used by the batch job.
		String query = 'Select Id From chttrunfollow__UnfollowRuleJob__c';

       	chttrunfollow__UnfollowRuleJob__c[] chtUnfollowRuleJobs = new List<chttrunfollow__UnfollowRuleJob__c>();
       	
       	for (Integer i=0;i<10;i++) {
           	//Create new hubspot logs to be deleted by the batch job
           	chttrunfollow__UnfollowRuleJob__c chtUnfollowRuleJb = new chttrunfollow__UnfollowRuleJob__c(name='RuleJob' + i);               
           	chtUnfollowRuleJobs.add(chtUnfollowRuleJb);
       	}
       	insert chtUnfollowRuleJobs;

       	Test.startTest();
       	BatchDeleteChatterUnfollowRuleJobs jobs = new BatchDeleteChatterUnfollowRuleJobs(query); //Pass query to class
       	Database.executeBatch(jobs); //Run batch job
       	Test.stopTest();

       	// Verify hubspot logs got deleted by batch job
       	Integer i = [SELECT COUNT() FROM chttrunfollow__UnfollowRuleJob__c];
       	System.assertEquals(i, 0);    
   	}
}