trigger Create_CampaignMember_For_New_Tasks on Task (after insert) {
    try {  
 
        if (Trigger.new.size() == 1 ) {
        	
            String cname = '';             
            Integer current_year = System.today().year(); //Calculate current year
            CampaignMember cml = new CampaignMember();
            
            for(Task t : Trigger.new) {
            	if(t.Adword__c == null && t.Adcampaign__c == null ){
            		return;
            	}                     	
           		if(t.Adword__c == 'Newsweaver' || t.Adword__c  == 'newsweaver'){
            		cname = 'Direct Website Visit ' + current_year; //append year value to campaign name
            	}else if(t.Adcampaign__c == 'Client_newsletter'){
                    cname = 'Client Newsletter 2011';
                }else if(t.Adcampaign__c == 'Ireland-1-Sept-09'){                                                               
                       cname = 'Google Adwords IE';
                }else if(t.Adcampaign__c == 'UK-1-Sept-09'){                                                                
                       cname = 'Google Adwords UK';
                }else if(t.Adcampaign__c == 'online_banner_ad' && t.Adword__c == 'dmablog'){
                  cname = 'DMA-Banner-Ad';
                }else if(t.Adcampaign__c == 'ebulletins' && t.Adword__c == 'edispatch'){
                  cname = 'eDispatch-Banner-Ad-2010';
                }else if(t.Adcampaign__c == 'ENN' && t.adword__c == 'email_newsletter_template'){
                  cname = 'ENN-Email-Newsletter-Banner-Ad-20xx';
                }else if(t.Adcampaign__c == 'IAA' && t.Adword__c == 'IIA_Advertorial'){
                  cname = 'IIA-Email-Newsletter';
                }else if(t.Adcampaign__c == 'Advertising' && t.Adword__c == 'imjad'){
                  cname = 'IMJ-PrintAd';
                }else if(t.Adcampaign__c == 'online_banner_ad' && t.Adword__c == 'mixingdigital'){
                  cname = 'Mixing-Digital-2011';
                }else if((t.Adcampaign__c == 'undefined' || t.Adcampaign__c == 'Direct_visit_website' || t.Adcampaign__c == '' || t.Adcampaign__c == null)){
                    cname = 'Direct Website Visit ' + current_year; //append year value to campaign name
                }else{
                    cname = t.Adcampaign__c;
                }
        	
	            if(cname != ''){
	                List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
	                if(!c.isEmpty()){           
	                    cml.campaignid = c[0].id;
	                    if(string.valueOf(t.WhoId).startsWith('00Q')){
	                    	cml.leadId = t.WhoId;	
	                    }else{
	                    	cml.contactId = t.WhoId;
	                    }
	                    
	                }else{
	                    System.debug('No Campaign exists');
	            	}
	            }
            }
      
       if(cml.CampaignId != null){          
        insert cml;
       }
    }
    } catch(Exception e) {
        system.debug ('error: ' + e.getMessage() );
    }
}