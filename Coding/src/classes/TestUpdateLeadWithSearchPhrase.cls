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
private class TestUpdateLeadWithSearchPhrase {

   /* static testMethod void myUnitTest() {
    	
    	
    	Lead l = new Lead(FirstName='Joe2ndRound', 
                                       LastName='Schmoe2ndRound',
                                        leadSource='Web',
                                        Company='random2ndRound',
                                        Country='Ireland',
                                        email = 'joeshmoe@test.com');
        insert l;
                                        
		List<Lead> savedLeadJoe2ndRound = [SELECT searchTerm__c FROM Lead WHERE FirstName = 'Joe2ndRound' and LastName='Schmoe2ndRound' and Company = 'random2ndRound' and email = 'joeshmoe@test.com'];            
		System.assertEquals('SearchPhrase', savedLeadJoe2ndRound[0].searchTerm__c);
    }*/
}