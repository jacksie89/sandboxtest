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
private class testCheckVATExemptExpired {

    static testMethod void myUnitTest() {
        //Create an Active Account
        Account newAccount = new Account (name='XYZ Organization');
        newAccount.BillingCountry = 'Ireland';
        newAccount.Status__c = 'Active';
        newAccount.VAT_exemption_expiry_Date__c = Date.today();
        insert newAccount;
		Test.startTest();
        checkVatExemptExpiredDate cv = new checkVatExemptExpiredDate();
        cv.execute(null);
        //System.schedule('Schedule', sch, cv);
        List<Task> taskList = [SELECT id, description, whoId from Task where whatId=:newAccount.Id ]; //WHERE whoId = '00520000001d8ey'
        test.stoptest();
        System.assertEquals(1,taskList.size());        
        System.assertEquals('The VAT Exempt Expiration date has passed. Plase Review', taskList[0].description);
    }
}