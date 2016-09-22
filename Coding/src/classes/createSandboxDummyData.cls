public with sharing class createSandboxDummyData {

	public List<Account> accountList = new List<Account>();
    public List<Opportunity> opportunityList = new List<Opportunity>();
	private List<Lead> leadList = new List<Lead>();
	public List<Contact> contactList = new List<Contact>();
	public Boolean contactsCreated = false;
	public String records = null; 
    //indicates the number or records to create for EACH Account Record Type
    public Integer MAXRECORDS;
 
    //these bool's will be used to help render the page
    //public Boolean dataAdd {get;private set;}
    //public Boolean dataDelete {get;private set;}
 
    public createSandboxDummyData(){
        //dataAdd = false;
        //dataDelete = false;
    } 
    
    //are we on a sandbox?
    public boolean getOnSandbox(){
        return System.URL.getSalesforceBaseURL().getHost().contains('cs');
    } 
    
    //next few methods return the record lists
    public List<Account> getAccounts(){
        return accountList;
    }
 
    public List<Opportunity> getOpportunities(){
        return opportunityList;
    }

	public List<Lead> getLeads(){
		return leadList;
	} 
	
	public List<Contact> getContacts(){ 
		return contactList;
	}
        
	public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('15','15'));

        return options; 
    }

    public String getNumRecords() {
        return records;
    }
                    
    public void setNumRecords(String records) { 
    	this.records = records; 
   	}
    
    	
//    public void createLeads(){
	public void createLeads(){
        //Create some Leads       
    	Integer j;
    	Boolean error = false;
    	        
        String[] firstnamesArray = new String[]{'Jim', 'Victoria', 'Jack', 'Mike', 'Mark', 'Rodney', 'Linda', 'Larry', 'Sandra', 'Tina',
        												'Richard', 'Raquel', 'Dolores', 'Shane', 'Evan'};
        String[] lastnamesArray = new String[]{'Murphy', 'Mitchell', 'Casey', 'Sullivan', 'Kelleher', 'Flynn', 'McGuirk', 'Hosford', 'Murray', 'Kavanagh',
        												'Rednapp', 'Knowles', 'Kelly', 'Roche', 'Ritchie'};
        String[] emailsArray = new String[]{'jmurphy@abc.com', 'vmitchell@qqddii.com', 'jcasey@pcnness.com', 'msullivan@jjbbcc.com', 'mkelleher@notessa.com', 
           	'rflynn@bloggsinc.com', 'lmcguirk@fghfgh.com', 'lhosford@stradas.com', 'smurray@jjskeano.com', 'tkavanagh@wwzzznn.com',
           	'rrednapp@iiojiwe.com', 'rknowles@knowles1234.com', 'dkelly@estarlllie.com', 'sroche@wwssxlohe.com', 'eritchie@lleiwewdcs.com'};
        
        String[] companiesArray = new String[]{'Dell', 'CocaCola', 'BIC', 'Q-Connect', 'Pinarello', 'Cervelo', 'Magners', 'Flahavans', 'Kelloggs', 'Heineken',
        										'Dominos', 'Ristorante', 'Apache', 'King Pizza', 'Good Fellas'};
            
        if(getNumRecords() == null){
        	MAXRECORDS=0;
        } else {
        	MAXRECORDS = integer.valueOf(getNumRecords());
        }
        System.debug('Max Records = ' + MAXRECORDS);
        
        if(MAXRECORDS == 0){
        	error=true;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select the number of records you want to create!'));		
        	System.debug('Error message added!');
        } else {
        	leadList = new List<Lead>();
	     	System.debug('Inside Else: MAXRECORDS is: ' + MAXRECORDS);
	        //leadList = [select Id, Name, LeadSource from Lead where LeadSource ='Purchased List'];
	        //if(leadList.size() > 0 || leadList.size() == 15){
	        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You have already created some dummy leads!'));
	        //}else{
		        for(Integer i=0;i<MAXRECORDS;i++){
					leadList.add( new Lead(FirstName=firstnamesArray[i], LastName=' ' + lastnamesArray[i], Email=emailsArray[i], Company=companiesArray[i], 
					RecordTypeId='01220000000YZ4R', Status='Open', LeadSource='Purchased List'));			
		        }
				insert leadList;
				System.debug('My First Lead Status (after insert) is: ' + leadList[0].Status);
	
		        //Create an Email Marketing campaign
			    Campaign myEMCampaign = new Campaign(name='Test Email Marketing Campaign');
			    myEMCampaign.Type = 'Email Marketing';
			    myEMCampaign.IsActive = true;
			    insert myEMCampaign;
			         	    
		    	List <Campaign> c = [select id, name from Campaign where name = :myEMCampaign.Name limit 1];
			
		    	//For all inserted leads, go through the list of them and add them as campaign members to the above campaign
		    	for(j=0; j<leadList.size(); j++){
		    		CampaignMember cml = new CampaignMember();
		    		cml.campaignid = c[0].id;
			        cml.leadid = leadList[j].id;
			        insert cml;
		    	}
				System.debug('1. My First Lead Id is: ' + leadList[0].Id);
	        //}
		}       	
    }

    public void createAccountsWithContacts(){
		//Create some dummy Accounts
       	String[] companiesArray = new String[]{'Dell', 'CocaCola', 'BIC', 'Q-Connect', 'Pinarello', 'Cervelo', 'Magners', 'Flahavans', 'Kelloggs', 'Heineken',
       											'Gatorade', '7 Eleven', 'KAS', 'Peugeot', 'Fujitsu'};
       	String[] firstnamesArray = new String[]{'Jack', 'Kieran', 'Sean', 'Liam', 'Lucy', 'Albert', 'Michelle', 'Ruth', 'Clara', 'Mary',
       											'Seamus', 'William', 'Wendy', 'Sheila', 'Jeff'};
       	String[] lastnamesArray = new String[]{'Lynch', 'Lally', 'Buggy', 'Well', 'Harrington', 'Mann', 'Flynn', 'Randall', 'Daly', 'Quinlan',
       											'Given', 'Brady', 'Giles', 'Dunphy', 'Whelan'};
       	String[] emailsArray = new String[]{'jlynch@cde.com', 'klally@eefdfdfs.com', 'sbuggy@erewrweqrwq.com', 'lwell@nbvn.com', 'lharrington@ghsdewt.com', 
           'amann@bloggsinc.com', 'mflynn@mbmvbmc.com', 'rrandall@qazsxw.com', 'cdaly@trreeww.com', 'mquinlan@olpkmn.com',
           	'sgiven@defg.com', 'wbrady@ooiieed.com', 'wgiles@simples123.com', 'sdunphy@umbro5433.com', 'jwhelan@splendid555.com'};

        if(getNumRecords() == null){
        	MAXRECORDS=0;
        } else {
        	MAXRECORDS = integer.valueOf(getNumRecords());
        }
        System.debug('Max Records = ' + MAXRECORDS);
        
        if(MAXRECORDS == 0){
        	//error=true;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select the number of records you want to create!'));		
        	System.debug('Error message added!');
        } else {


	       	accountList = new List<Account>();
	       	for(Integer i=0;i<MAXRECORDS;i++){
				accountList.add( new Account(Name=companiesArray[i], Industry='Energy'));
	       	}
	       	System.debug('Total Orgs created: ' + accountList.size());
	
	       	System.debug('Total Orgs created: ' + accountList.size());
	       	insert accountList;
				
			//Great, we have some accounts, how about some opportunities
	 		contactList = new List<Contact>();
	        //Use this counter to give unique names to opportunities
	        Integer contactCounter=0;
	        System.debug('Account List Size: ' + accountList.size());
	
	        for(Account a : accountList){     
	           System.debug('Account Id: ' + a.id);
	           contactList.add(
	                new Contact(FirstName=firstnamesArray[contactCounter], LastName=' ' + lastnamesArray[contactCounter],
	                   AccountId=a.id,
	                   Email=emailsArray[contactCounter], Contact_Status__c='Information'
	                   )
	           );
	           contactCounter++;   	
	        }
	        insert contactList;
	        contactsCreated = True;
        }
    }


    
    public void createOpportunities(){
    	//Great, we have some accounts, how about some opportunities
        opportunityList = new List<Opportunity>();
        accountList = [select Id, Name, Industry from Account where Industry ='Energy'];       	
        String[] oppnamesArray = new String[]{'Internal Connect', 'Customer Connect Lite', 'New Template', 'Template Redesign', 'Customer Connect', 
       		'New Enterprise Account', 'Multi User Account', 'Channel Connect', 'Team Collaborate', 'Enterprise Upgrade',
       		'Random Opp 1', 'Random Opp 2', 'Random Opp 3', 'Random Opp 4', 'Random Opp 5'};
        Integer oppCounter=0;

            for(Account a : accountList){
                opportunityList.add(
                    new Opportunity(Name=oppnamesArray[oppCounter],
                        AccountId=a.id,
                        OwnerId=UserInfo.getUserId(),
                        CloseDate=Date.Today().addDays(40),
                        StageName='First Appointment'
                   )
                );
                oppCounter++;
                
            }
            insert opportunityList;
    }
                
    public void createOppsAndContacts(){
    	    //Great, we have some accounts, how about some opportunities
            opportunityList = new List<Opportunity>();
 			contactList = new List<Contact>();
            //Use this counter to give unique names to opportunities
            Integer oppCounter=1, contactCounter=1;
            for(Account a : accountList){
                opportunityList.add(
                    new Opportunity(Name='Test Opportunity '+oppCounter,
                        AccountId=a.id,
                        CloseDate=Date.Today().addDays(40+oppCounter),
                        StageName='Trial Period',
                        Probability=0.4
                   )
                );
                oppCounter++;
                
                contactList.add(
                    new Contact(FirstName='Test', LastName='Contact ' + contactCounter,
                        AccountId=a.id,
                        Email='testcontact' + contactCounter + '@testcompany.com'
                   )
                );
                contactCounter++; 
            	
            }
            insert opportunityList;
            insert contactList;
    }

}
/*
    public void createContacts(){
       String[] firstnamesArray = new String[]{'Jack', 'Kieran', 'Sean', 'Liam', 'Lucy', 'Albert', 'Michelle', 'Ruth', 'Clara', 'Mary'};
       String[] lastnamesArray = new String[]{'Lynch', 'Lally', 'Buggy', 'Well', 'Harrington', 'Mann', 'Flynn', 'Randall', 'Daly', 'Quinlan'};
       String[] emailsArray = new String[]{'jlynch@cde.com', 'klally@eefdfdfs.com', 'sbuggy@erewrweqrwq.com', 'lwell@nbvn.com', 'lharrington@ghsdewt.com', 
           'amann@bloggsinc.com', 'mflynn@mbmvbmc.com', 'rrandall@qazsxw.com', 'cdaly@trreeww.com', 'mquinlan@olpkmn.com'};
       String[] companiesArray = new String[]{'Pepsi', 'Cadbury', 'Aer Lingus', 'Ryanair', 'Cogans', 'Kearys', 'Aviva', 'FBD', 'Toyota', 'Pellegrino'};

		//Great, we have some accounts, how about some opportunities
 		contactList = new List<Contact>();
        //Use this counter to give unique names to opportunities
        Integer contactCounter=1;
        System.debug('Account List Size: ' + accountList.size());
		List<Account> existing_accounts = new List<Account>();
        existing_accounts = [select Id, Name, Industry from Account where Industry='Energy'];
		
        for(Account a : existing_accounts){     
           System.debug('Account Id: ' + a.id);
           contactList.add(
                new Contact(FirstName=firstnamesArray[contactCounter], LastName=' ' + lastnamesArray[contactCounter],
                   AccountId=a.id, Email=emailsArray[contactCounter], Contact_Status__c='Information'
                   )
           );
           contactCounter++;   	
         }
         insert contactList;    	
    }
*/