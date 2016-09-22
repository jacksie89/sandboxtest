global class BatchDeleteUnfollowRuleJobs_scheduler implements Schedulable{

	global void execute (SchedulableContext SC){ 
		
		String query = 'Select Id From chttrunfollow__UnfollowRuleJob__c Where LastModifiedDate = LAST_MONTH';
		
		BatchDeleteChatterUnfollowRuleJobs jobsToDelete = new BatchDeleteChatterUnfollowRuleJobs(query); 
		database.executeBatch(jobsToDelete); 
	}
}