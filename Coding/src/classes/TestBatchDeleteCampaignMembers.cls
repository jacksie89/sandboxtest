@isTest
private class TestBatchDeleteCampaignMembers {

    static testMethod void myUnitTest() {
		
		String query = 'Select Id from CampaignMember Where campaignId IN (select Id From Campaign Where Name Like \'%BOE%\' Or CreatedBy.Name Like \'%Aine%\')';

       	CampaignMember[] campaignMembersList = new List<CampaignMember>();
       	
		List<Lead> testLeads = TestDataFactory.createTestLeads(10, 'none', false);
        			
       	Campaign myTestCampaign = new Campaign(Name = 'BOE Campaign');
       	insert myTestCampaign;
       	
       	for (Integer i=0;i<10;i++) {
           	//Create new hubspot logs to be deleted by the batch job
           	CampaignMember cm = new CampaignMember(campaignId=myTestCampaign.Id, leadId=testLeads[i].Id);               
           	campaignMembersList.add(cm);
       	}
       	insert campaignMembersList;

       	Test.startTest();
       	BatchDeleteCampaignMembers bdcm = new BatchDeleteCampaignMembers(query);
       	Database.executeBatch(bdcm); //Run batch job
       	Test.stopTest();

       	// Verify hubspot logs got deleted by batch job
       	Integer i = [SELECT COUNT() FROM CampaignMember];
       	System.assertEquals(i, 0);    
   	}
}