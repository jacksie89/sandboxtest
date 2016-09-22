@isTest
private class TestLeadCampaignAssignment {

    static testMethod void testCreateNewFreeTrialOnlyLead() {
        // create the campaign
        String cname = 'Free Trial FY16';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
		
		//createTestLeadsv2(Integer numLeads, String dupeType, String value, String miscValue, Boolean useAssignment, String leadStatus)
	    TestDataFactory.createTestLeadsv2(1, 'Unique', 'unique', 'true', true, 'New');
        
        Lead myLead = [select Reassign__c from Lead where Email = 'unique0@uniqueorg0.com'];
        
        //assert the lead is a member of the campaign
        final List <CampaignMember> campaignmembers = [select id from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];       
        System.assertEquals(1, campaignmembers.size());
    }

    static testMethod void testCreateICGraderOnlyLead() {
        // create the campaign
        String cname = 'IC Grader 2016';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];

	    TestDataFactory.createTestLeadsv2(1, 'Other', 'other', 'false', true, 'New');
        
        Lead myLead = [select Reassign__c from Lead where Email = 'other0@otherorg0.com'];
        
        //assert the lead is a member of the campaign
        final List <CampaignMember> campaignmembers = [select id from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];       
        System.assertEquals(1, campaignmembers.size());
    }
        
    static testMethod void testCreateNewFreeTrialAndICGraderLead() {
        // create the campaign
        String cname = 'IC Grader 2016';
        String cname2 = 'Free Trial FY16';
	    
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
	    List <Campaign> c2 = [select id, name from Campaign where name = :cname2 limit 1];

	    TestDataFactory.createTestLeadsv2(1, 'Other', 'other', 'true', true, 'New');
        
        Lead myLead = [select Reassign__c from Lead where Email = 'other0@otherorg0.com'];
        
        //assert the lead is a member of the IC Grader campaign
        final List <CampaignMember> campaignmembers = [select id from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];       
        System.assertEquals(1, campaignmembers.size());
        
        //assert the lead is a member of the Free Trial campaign
        final List <CampaignMember> campaignmembers2 = [select id from CampaignMember where campaignid = :c2[0].id and leadid = :myLead.id];
        System.assertEquals(1, campaignmembers2.size());
    }    

    static testMethod void testCreateMultipleNewFreeTrialOnlyLeads() {
        // create the campaign
        String cname = 'Free Trial FY16';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
		List <Id> savedLeadIds = new List<Id>();
		
	    TestDataFactory.createTestLeadsv2(102, 'Unique', 'unique', 'true', true, 'New');
        
		List <Lead> savedLeads = [select Id from Lead where Email Like '%uniqueorg%' and LastName Like '%UniqueEmail%'];
		
		for(Lead l : savedLeads){
			savedLeadIds.add(l.Id);
		}
        
        //assert the lead is a member of the campaign - only query back members from test class - not live
        final List <CampaignMember> campaignmembers = [select id from CampaignMember where campaignid = :c[0].id and leadid in :savedLeadIds];     
        System.assertEquals(102, campaignmembers.size());
    }

    static testMethod void testCreateMultipleNewICGraderOnlyLeads() {
        // create the campaign
        String cname = 'IC Grader 2016';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
		List <Id> savedLeadIds = new List<Id>();
		
        TestDataFactory.createTestLeadsv2(102, 'Other', 'other', 'false', true, 'New');

		List <Lead> savedLeads = [select Id from Lead where Email Like '%otherorg%' and LastName Like '%OtherEmail%'];
		
		for(Lead l : savedLeads){
			savedLeadIds.add(l.Id);
		}
        
        //assert the lead is a member of the campaign - only query back members from test class - not live
        final List <CampaignMember> campaignmembers = [select id from CampaignMember where campaignid = :c[0].id and leadid in :savedLeadIds];     
        System.assertEquals(102, campaignmembers.size());
    } 
}