public with sharing class OpportunityRedirect {
	private ApexPages.StandardController controller;
	public String contactID {get; set;}
	public Map<String, String> allParameters {get; set;}

	public opportunityRedirect(ApexPages.StandardController controller) {	
		this.controller = controller;		
		contactID = ApexPages.currentPage().getParameters().get('conId');
		allParameters = ApexPages.currentPage().getParameters();
	}

	public PageReference redirect(){
	
		PageReference returnURL;
		// Redirect if Record Type corresponds to custom VisualForce page		
		IF(contactID == null) {		
			returnURL = new PageReference('/apex/createOpportunity2');
		}ELSE {		
			returnURL = new PageReference('/006/e');		
		}
		allParameters.remove('save_new');
		returnURL.getParameters().putAll(allParameters);		
		returnURL.getParameters().put('nooverride', '1');
		returnURL.setRedirect(true);
		return returnURL;
	}
}