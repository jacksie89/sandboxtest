@isTest
private class TestCreateUpdateTask {
	
	static testMethod void myUnitTest(){
	//create a test lead
	List<Lead> testLeads = TestDataFactory.createTestLeads(1, 'none', false);
	//create a test task with status =completed
	Task testTask = new Task(WhoId = testLeads[0].Id, Subject = 'Test Task', Status = 'Completed', Type = 'Email');
    insert testTask;
    //query back the task
    Task mySavedTask = [SELECT Status, Type, Activity_Type__c, Date_Completed__c FROM Task WHERE Id=:testTask.Id];
    //assert that activity type = type AND that Date completed = today
	System.assertEquals(mySavedTask.Activity_Type__c, mySavedTask.Type);
	System.assertEquals(system.today(), mySavedTask.Date_Completed__c);
	//create another test task with status !=completed
	Task testTask2 = new Task(WhoId = testLeads[0].Id, Subject = 'Test Task', Status = 'Not Started', Type = 'Call');
    insert testTask2;
	//assert that activity type = type AND that Date completed = blank
	mySavedTask = [SELECT Status, Type, Activity_Type__c, Date_Completed__c FROM Task WHERE Id=:testTask2.Id];
	System.assertEquals(mySavedTask.Activity_Type__c, mySavedTask.Type);
	System.assertEquals(null, mySavedTask.Date_Completed__c);
	//update task to set Status = Completed
	testTask2.Status = 'Completed';
	update testTask2;
	//assert that Date completed = today
	mySavedTask = [SELECT Status, Type, Activity_Type__c, Date_Completed__c FROM Task WHERE Id=:testTask2.Id];
	System.assertEquals(system.today(), mySavedTask.Date_Completed__c);
	}
}