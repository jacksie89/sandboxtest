@isTest
private class TestCreateUpdateEvent {
    
    static testMethod void myUnitTest(){
    
    DateTime myDateTime = DateTime.newInstance(2015, 6, 6, 3, 3, 3);
    //create a test lead
    List<Lead> testLeads = TestDataFactory.createTestLeads(1, 'none', false);
    //create a test event with status =completed
    Event testEvent = new Event(WhoId = testLeads[0].Id, Subject = 'Test Event', Event_Status__c = 'Completed', Type = 'First Demo', DurationInMinutes = 30, ActivityDateTime=myDateTime);
    insert testEvent;
    
    //query back the event
    Event mySavedEvent = [SELECT Event_Status__c, Type, Activity_Type__c, Date_Completed__c FROM Event WHERE Id=:testEvent.Id];
    //assert that activity type = type AND that Date completed = today
    System.assertEquals(mySavedEvent.Activity_Type__c, mySavedEvent.Type);
    System.assertEquals(system.today(), mySavedEvent.Date_Completed__c);
    
    //create another test event with status !=completed
    Event testEvent2 = new Event(WhoId = testLeads[0].Id, Subject = 'Test Event', Event_Status__c = 'Not Started', Type = 'Scheduled Call', DurationInMinutes = 30, ActivityDateTime=myDateTime);
    insert testEvent2;
    //assert that activity type = type AND that Date completed = blank
    mySavedEvent = [SELECT Event_Status__c, Type, Activity_Type__c, Date_Completed__c FROM Event WHERE Id=:testEvent2.Id];
    System.assertEquals(mySavedEvent.Activity_Type__c, mySavedEvent.Type);
    System.assertEquals(null, mySavedEvent.Date_Completed__c);
    //update event to set Event_Status__c = Completed
    testEvent2.Event_Status__c = 'Completed';
    update testEvent2;
    //assert that Date completed = today
    mySavedEvent = [SELECT Event_Status__c, Type, Activity_Type__c, Date_Completed__c FROM Event WHERE Id=:testEvent2.Id];
    System.assertEquals(system.today(), mySavedEvent.Date_Completed__c);
    }
}