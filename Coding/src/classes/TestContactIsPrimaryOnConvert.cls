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
private class TestContactIsPrimaryOnConvert {

    static testMethod void myUnitTest() {
        
        //create Campaign
        Campaign myCampaign = new Campaign(name='XYZ Campaign');
        myCampaign.Type = 'Advertisement';
        insert myCampaign;
        
               // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead', 
                                    FirstName='John',
                                    LastName='Doe',
                                    Status='Open',
                                    Phone='555-123-4567',
                                    Industry = 'Advertising',
                                    Department__c = 'Account Management',
                                    No_Employees__c = '0-500',
                                    Solution_Type__c = 'Internal Communications',
                                    Country='Ireland',
                                    Deal_Type__c = 'New Business',
                                    campaignid__c = myCampaign.id,
                                    Email = 'johndoe@stuff.com',
                                    BANT_Completed__c = true);
        insert testLead;
    
        // Create dummy conversion
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testlead.id);
        lc.setConvertedStatus('Sales Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        // Make sure conversion was successful
        System.assert(lcr.isSuccess());

        // Test Contact "Status" field update
        Contact testCon = [SELECT id FROM Contact WHERE Contact.Id = :lcr.getContactId()];
        OpportunityContactRole ocr = [Select ocr.isPrimary From OpportunityContactRole ocr Where ocr.ContactId = :lcr.getContactId() and ocr.OpportunityId = :lcr.getOpportunityId()];
        System.assert(ocr.isPrimary);        
    }
}