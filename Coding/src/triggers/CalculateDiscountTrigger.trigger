trigger CalculateDiscountTrigger on OpportunityLineItem (before insert, before update) {

  /*if line item has been added to a quote and is being synced back to opp, ListPrice will not be available. 
      In this instance we need to query the ListPrice from the PricebookEntry, also if it's an insert the Charge Type will be blank and we need to get the charge type from the product*/
  Set<Id> pricebookIds = new Set<Id>();
  Set<Id> productIds = new Set<Id>();
  
  for(OpportunityLineItem p: Trigger.new){
    pricebookIds.add(p.PricebookEntryId);
  }
  System.debug('pricebookIds: ' + pricebookIds);
  //Create a map to hold pricebook information for each opportunity product
  Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>([SELECT id, UnitPrice, Product2Id FROM PricebookEntry WHERE id IN :pricebookIds]);
  System.debug('pbeMap is: ' + pbeMap);
  
  //create a set of product ids
  for(Id id : pbeMap.keySet()){
  productIds.add(pbeMap.get(id).Product2Id);
  }
  System.debug('productIds: ' + productIds);
  
  //Create a map to store charge type etc. associated with each product id
  Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT id, Charge_Type__c, Description, Family FROM Product2 Where Id IN :productIds]);
  System.debug('productMap is: ' + productMap);
  

  
    for(OpportunityLineItem p: Trigger.new){
      
      decimal vListPrice;
      decimal termPrice;
      String vChargeType;  
      
      if(p.ListPrice==null){
      vListPrice = pbeMap.get(p.pricebookEntryId).UnitPrice;
      System.debug('Got ListPrice from PriceBook: '+vListPrice);
      }
      else{
      vListPrice = p.ListPrice;
      }
      
      if(p.Charge_Type__c == null){
      vChargeType = productMap.get(pbeMap.get(p.PricebookEntryId).Product2Id).Charge_Type__c;  
      System.debug('Got ChargeType from Product: '+ vChargeType); 
      }
      else{
      vChargeType = p.Charge_Type__c;  
      }
      
      System.debug('Term is: '+p.Term_months__c+' and vChargeType is: '+vChargeType);
      
      Decimal myDecimalDiscount;      
      System.debug('Reduced Price: ' + p.Reduced_Price__c + ' , List Price: ' + vListPrice);
      if((vChargeType == 'Recurring' || vChargeType =='Annual') && p.Term_months__c!= null){
      	if(p.Reduced_Price__c < vListPrice){
      		termPrice = vListPrice*p.Term_months__c/12;
          	System.debug('Term Price is '+vListPrice+' by '+p.Term_months__c+'/12');
          	myDecimalDiscount = ((vListPrice - p.Reduced_Price__c)/vListPrice) * 100;
        	System.debug('CalcDiscountTrigger - myDecimalDiscount: ' + myDecimalDiscount);
      		}
      		else if(p.Reduced_Price__c > vListPrice){
      		myDecimalDiscount = 0;
      		termPrice = p.Reduced_Price__c*p.Term_months__c/12;	
      		}
      		else{
      		myDecimalDiscount = 0;
      		termPrice = vListPrice*p.Term_months__c/12;
      		p.Reduced_Price__c=vListPrice;
      		}
      }
      else {
      	if((vChargeType == 'Recurring' || vChargeType =='Annual') && p.Term_months__c == null){
      		p.Term_months__c=12;
      			}
      		if(p.Reduced_Price__c < vListPrice){
      		termPrice = vListPrice;
      		myDecimalDiscount = ((vListPrice - p.Reduced_Price__c)/vListPrice) * 100;
        	System.debug('CalcDiscountTrigger - myDecimalDiscount: ' + myDecimalDiscount);
      		}
      		else if(p.Reduced_Price__c > vListPrice){
      		myDecimalDiscount = 0;
      		termPrice = p.Reduced_Price__c;	
      		}
      		else{
      		myDecimalDiscount = 0;
      		termPrice = vListPrice;
      		p.Reduced_Price__c=vListPrice;
      		}
      }   
            
        if(p.Discount != myDecimalDiscount.setScale(6)){
            p.Discount = myDecimalDiscount.setScale(6);
            //System.debug('CalculateDiscountTrigger - Discount: ' + p.Discount);
          	}
        else {
            System.debug('No Update required to Discount');
        }   
        
        p.UnitPrice = termPrice;
        //set the total monthly price
        if((vChargeType == 'Annual' || vChargeType == 'Recurring') && p.Term_months__c!=null ){
          p.Total_Price_Monthly__c = (p.Reduced_Price__c/12)*p.Quantity;
           }
        else{
          p.Total_Price_Monthly__c = null;
        }
           
       //if this is a new opp line, populate Description, Product Family
        if (Trigger.isInsert){
          System.debug('Trigger is Insert');
        
          if(productMap.get(pbeMap.get(p.PricebookEntryId).Product2Id).Description!=null){
          p.Description = productMap.get(pbeMap.get(p.PricebookEntryId).Product2Id).Description.left(255);}
          
          p.Product_Family__c = productMap.get(pbeMap.get(p.PricebookEntryId).Product2Id).Family;
          	if (p.Charge_Type__c == null){
          		p.Charge_Type__c = vChargeType;
          	}
             if(p.Term_months__c !=null && vChargeType != 'Monthly' && vChargeType != 'Annual' && vChargeType != 'Recurring'){
            p.Term_months__c = 0;
             }       
    }
    }
}