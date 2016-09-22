trigger CalculateQLIDiscountTrigger on QuoteLineItem (before insert, before update) {
			
			string vOptyId;
    		string vPricebookEntryId;
    		string vQuote;
    		
    		Set<Id> pricebookIds = new Set<Id>();
    		
    		for(QuoteLineItem q: Trigger.new){
				pricebookIds.add(q.PricebookEntryId);
				vOptyId = q.OpportunityID__c;
				}
			System.debug('pricebookIds: ' + pricebookIds);

			Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>([SELECT id, UnitPrice, Product2Id FROM PricebookEntry WHERE id IN :pricebookIds]);
			System.debug('SOQL query pbeMap is: ' + pbeMap);
			

if(Trigger.isInsert){
	System.debug('QLI discount Trigger is Insert'); 		    		
    		
    		Set<Id> productIds = new Set<Id>();    		  		    		
    					
			//create a set of product ids
			for(Id id : pbeMap.keySet()){
			productIds.add(pbeMap.get(id).Product2Id);
			}
			System.debug('productIds: ' + productIds);
	
			//Create a map to store charge type etc. associated with each product id
			Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT id, Charge_Type__c, Description, Family FROM Product2 Where Id IN :productIds]);
			System.debug('SOQL query productMap is: ' + productMap);
			
			//Create a map to store opplines
			Map<Id, OpportunityLineItem> oppLinesMap = new Map<Id, OpportunityLineItem>([SELECT id, PricebookEntryId, Term_months__c, Reduced_Price__c FROM OpportunityLineItem Where OpportunityId = :vOptyId]);
			System.debug('SOQL query oppLinesMap is: ' + oppLinesMap);
			
											
		for(QuoteLineItem q: Trigger.new){
    		decimal vTerm = q.Term_months__c;
    		double vReducedPrice;
    		double vListPrice;
    		decimal vTermPrice;
    		string vChargeType;
	    	//if this is a new quote line item, created from an opportunity line item, copy over the Term	 	
	    		     
	        		vPricebookEntryId = q.PricebookEntryId;
	        
	        		if(vOptyID != null){
	        			//for(OpportunityLineItem oppLine : [select Id, Term_months__c from OpportunityLineItem where (OpportunityId = :vOptyId and PricebookEntryId = :vPricebookEntryId)])
	        			for(Id id : oppLinesMap.keySet()){
							if(oppLinesMap.get(id).PricebookEntryId == q.PricebookEntryId){
								vTerm = oppLinesMap.get(id).Term_months__c;	
								q.Term_months__c = vTerm;
								System.debug('CalcQLI setting Term to: '+vTerm);
								vReducedPrice = oppLinesMap.get(id).Reduced_Price__c;	
								q.Reduced_Price__c = vReducedPrice;
								System.debug('CalcQLI setting Reduced Price to: '+vReducedPrice);
							}	
							else{
	        					vTerm = q.Term_months__c;
	        					vReducedPrice = q.Reduced_Price__c;
	        					System.debug('CalcQLI, Reduced Price and Term: '+vReducedPrice+' '+vTerm);
	        				}				   			  						
	    				}
	        		}
	        			
			
    	//because of https://success.salesforce.com/ideaView?id=08730000000kqsXAAQ we need to query pricebookentry to get ListPrice
    	 	
    	vListPrice = pbeMap.get(q.pricebookEntryId).UnitPrice;
    	System.debug('Got ListPrice from PriceBook: '+vListPrice);
    	
    	if(q.Charge_Type__c == null){
	    	vChargeType = productMap.get(pbeMap.get(q.PricebookEntryId).Product2Id).Charge_Type__c;  
	    	System.debug('Got ChargeType from Product: '+ vChargeType); 
	    	q.Charge_Type__c = vChargeType;
	    	}
	    	else{
	    	vChargeType = q.Charge_Type__c;
	    	}
    	
    Decimal myDecimalDiscount;  	
    	
   if((vChargeType == 'Recurring' || vChargeType =='Annual') && vTerm!= null){
      	if(vReducedPrice < vListPrice){
      		vTermPrice = vListPrice*vTerm/12;
          	System.debug('Term Price is '+vListPrice+' by '+vTerm+'/12');
          	myDecimalDiscount = ((vListPrice - vReducedPrice)/vListPrice) * 100;
        	System.debug('CalcDiscountTrigger - myDecimalDiscount: ' + myDecimalDiscount);
      		}
      		else if(vReducedPrice > vListPrice){
      		myDecimalDiscount = 0;
      		vTermPrice = vReducedPrice*vTerm/12;	
      		}
      		else{
      		myDecimalDiscount = 0;
      		vTermPrice = vListPrice*vTerm/12;
      		q.Reduced_Price__c=vListPrice;
      		}
      }
      else {
      	if((vChargeType == 'Recurring' || vChargeType =='Annual') && vTerm == null){
      		q.Term_months__c=12;
      			}
      		if(vReducedPrice < vListPrice){
      		vTermPrice = vListPrice;
      		myDecimalDiscount = ((vListPrice - vReducedPrice)/vListPrice) * 100;
        	System.debug('CalcDiscountTrigger - myDecimalDiscount: ' + myDecimalDiscount);
      		}
      		else if(vReducedPrice > vListPrice){
      		myDecimalDiscount = 0;
      		vTermPrice = vReducedPrice;	
      		}
      		else{
      		myDecimalDiscount = 0;
      		vTermPrice = vListPrice;
      		q.Reduced_Price__c=vListPrice;
      		}
      } 
    	
           
        if(q.Discount != myDecimalDiscount.setScale(6)){
            
            q.Discount = myDecimalDiscount.setScale(6);
                          
            System.debug('List Price: ' + vListPrice);
            System.debug('Term Price: ' + vTermPrice);
            System.debug('Reduced Price: ' + q.Reduced_Price__c);
            System.debug('Discount: ' + q.Discount);
          }
        else {
            System.debug('No Update required to Discount');
        }
        System.debug('CalcQLIDiscountTrigger - vTermPrice: ' + vTermPrice);
        q.UnitPrice = vTermPrice;       
        
        
        //if this is a new quote line, populate Description
        if (Trigger.isInsert && q.Description == null){
        	System.debug('Looking up ProductID: '+pbeMap.get(q.PricebookEntryId).Product2Id);
        	System.debug('Description is: '+productMap.get(pbeMap.get(q.PricebookEntryId).Product2Id).Description);       	
        	if(productMap.get(pbeMap.get(q.PricebookEntryId).Product2Id).Description != null){
        	q.Description = productMap.get(pbeMap.get(q.PricebookEntryId).Product2Id).Description.left(255);
        	}
        } 
       System.debug('QLI Calc q.Reduced_Price__c: '+q.Reduced_Price__c);
       System.debug('QLI Calc q.Quantity: '+q.Quantity); 	
       System.debug('QLI Calc vTerm: '+vTerm); 
       System.debug('QLI Calc vChargeType: '+vChargeType);
       System.debug('QLI Calc vTermPrice: '+vTermPrice); 
        //set the total monthly price
        if((vChargeType == 'Annual' || vChargeType == 'Recurring') && vTerm!=null ){
        	q.Total_Price_Monthly__c = q.Reduced_Price__c*q.Quantity/12;
           }
        else{
        	q.Total_Price_Monthly__c = null;
        }  
		}
		
}
else{
	for(QuoteLineItem q: Trigger.new){
		System.debug('QLI discount Trigger is Update');
    	
    	//because of https://success.salesforce.com/ideaView?id=08730000000kqsXAAQ we need to query pricebookentry to get ListPrice
       	double vListPrice = pbeMap.get(q.pricebookEntryId).UnitPrice;
    	System.debug('Got ListPrice from PriceBook: '+vListPrice);
    		
    		decimal vTerm = q.Term_months__c;
    		System.debug('QLI Calc vTerm: '+vTerm);  		
    		System.debug('List Price: ' + vListPrice);
    		decimal vTermPrice;
    		string vChargeType = q.Charge_Type__c;
    		System.debug('QLI Calc vChargeType: '+vChargeType);
    
    	
    	Decimal myDecimalDiscount;  	
    	
   if((vChargeType == 'Recurring' || vChargeType =='Annual') && vTerm!= null){
      	if(q.Reduced_Price__c!=null && q.Reduced_Price__c < vListPrice){
      		vTermPrice = vListPrice*vTerm/12;
          	System.debug('Term Price is '+vListPrice+' by '+vTerm+'/12');
          	myDecimalDiscount = ((vListPrice - q.Reduced_Price__c)/vListPrice) * 100;
        	System.debug('CalcDiscountTrigger - myDecimalDiscount: ' + myDecimalDiscount);
      		}
      		else if(q.Reduced_Price__c!=null && q.Reduced_Price__c > vListPrice){
      		myDecimalDiscount = 0;
      		vTermPrice = q.Reduced_Price__c*vTerm/12;	
      		}
      		else{
      		myDecimalDiscount = 0;
      		vTermPrice = vListPrice*vTerm/12;
      		q.Reduced_Price__c=vListPrice;
      		}
      }
      else {
      	if((vChargeType == 'Recurring' || vChargeType =='Annual') && vTerm == null){
      		q.Term_months__c=12;
      			}
      		if(q.Reduced_Price__c!=null && q.Reduced_Price__c < vListPrice){
      		vTermPrice = vListPrice;
      		myDecimalDiscount = ((vListPrice - q.Reduced_Price__c)/vListPrice) * 100;
        	System.debug('CalcDiscountTrigger - myDecimalDiscount: ' + myDecimalDiscount);
      		}
      		else if(q.Reduced_Price__c!=null && q.Reduced_Price__c > vListPrice){
      		myDecimalDiscount = 0;
      		vTermPrice = q.Reduced_Price__c;	
      		}
      		else{
      		myDecimalDiscount = 0;
      		vTermPrice = vListPrice;
      		q.Reduced_Price__c=vListPrice;
      		}
      } 
    	  	         
        if(q.Discount != myDecimalDiscount.setScale(6)){
            
            q.Discount = myDecimalDiscount.setScale(6);
           System.debug('QLI Calc q.Discount: '+ q.Discount);
          }
        else {
            System.debug('No Update required to Discount');
        }
       q.UnitPrice = vTermPrice;
              
       System.debug('QLI Calc q.Quantity: '+q.Quantity); 	
        
       
          //set the total monthly price
        if((vChargeType == 'Annual' || vChargeType == 'Recurring') && vTerm!=null ){
        	q.Total_Price_Monthly__c = q.Reduced_Price__c*q.Quantity/12;
           }
        else{
        	q.Total_Price_Monthly__c = null;
        }  
		}			
}
			     
}