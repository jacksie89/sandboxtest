public class MyConsoleController {

	public Case selectedCase { get; set; }
	
	public Case[] getMyCases() {
		return [SELECT Id, Subject, Status, CaseNumber, Account_Manager__c, Contact.Name, Sub_Type__c, Priority, CreatedDate, Case_Age_days__c, Account.Name FROM Case WHERE OwnerId = :UserInfo.getUserId()
			AND Status != 'Closed'];
	}
	
	public PageReference viewCase() {
		String caseId = ApexPages.currentPage().getParameters().get('caseId');
		selectedCase = [SELECT Id FROM Case WHERE Id = :caseId];
		return null;
	}
}