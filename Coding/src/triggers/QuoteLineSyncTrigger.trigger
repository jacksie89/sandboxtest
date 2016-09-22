trigger QuoteLineSyncTrigger on QuoteLineItem (before insert, after insert, after update) {

//If this is running before an insert, call the populate required field method from Utility class 
    if (trigger.isBefore && trigger.isInsert) { 
        if (QuoteSyncUtil.isRunningTest) {
            for (QuoteLineItem qli : trigger.new) {
                QuoteSyncUtil.populateRequiredFields(qli);
            }
        }    
        return;
    }
          
//Stop if the Trigger Stopper says so
  
    if (TriggerStopper.stopQuoteLine) return;
    
    //Get the qli fields and the opl fields       
    Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();
    List<String> oppLineFields = QuoteSyncUtil.getOppLineFields();
    
    //make a string of the qli fields
    String qliFields = QuoteSyncUtil.getQuoteLineFieldsString();
    //make a string of the oli fields
    String oliFields = QuoteSyncUtil.getOppLineFieldsString();
    //create blank string for qli ids, and build it up with the qli ids in the form "\id\,\id\,..."        
    String qliIds = '';
    for (QuoteLineItem qli : trigger.new) {
        if (qliIds != '') qliIds += ', ';
        qliIds += '\'' + qli.Id + '\'';
    }
    //build a string to use as a database query 
    String qliQuery = 'select Id, QuoteId, PricebookEntryId, Quantity, ServiceDate, SortOrder' + qliFields + ' from QuoteLineItem where Id in (' + qliIds + ') order by QuoteId, SortOrder ASC';
    //System.debug(qliQuery); 
    
    //Create a list of qlis using the query above    
    List<QuoteLineItem> qlis = Database.query(qliQuery);
    
    //Declare a map of ids and list of quote line items
    Map<Id, List<QuoteLineItem>> quoteToQliMap = new Map<Id, List<QuoteLineItem>>();
    
    //Set up this map of Quote id with list of corresponding quote line items  (quote id, all qlis for this quote) 
    for (QuoteLineItem qli : qlis) {    
        List<QuoteLineItem> qliList = quoteToQliMap.get(qli.QuoteId);
        if (qliList == null) {
            qliList = new List<QuoteLineItem>();
        } 
        qliList.add(qli);  
        quoteToQliMap.put(qli.QuoteId, qliList);        
    }
	//Pull the keys from the map (quote ids) and put them in a set i.e. get the set of quotes we are dealing with
    Set<Id> quoteIds = quoteToQliMap.keySet();
    //Build a map of quotes, with OpportunityId and isSyncing flag
    Map<Id, Quote> quotes = new Map<Id, Quote>([select id, OpportunityId, isSyncing from Quote where Id in :quoteIds]);
    
    //Declare a string of Opportunity ids
    String oppIds = '';
    //Declare a new set of Ids for quotes not to sync
    Set<Id> filterQuoteIds = new Set<Id>();
    //Go through the quotes in the quote map, for ones that are new or syncing, write the ids to the string oppIds.
    //ids of quotes not to be synced are added to the filterQuoteIds set
    for (Quote quote : quotes.values()) {
        // Only sync quote line item that are inserted for a new Quote or on a isSyncing Quote
        if ((trigger.isInsert && QuoteSyncUtil.isNewQuote(quote.Id)) || quote.isSyncing) {
           if (oppIds != '') oppIds += ', ';
           oppIds += '\'' + quote.OpportunityId + '\'';         
        } else {
            filterQuoteIds.add(quote.Id);
        }
    }
    
    //System.debug('Filter quote ids: ' + filterQuoteIds);
    
    //Remove the quotes not to be synced from the quoteIds set
    quoteIds.removeAll(filterQuoteIds);
    for (Id id : filterQuoteIds) {
       quotes.remove(id);
       quoteToQliMap.remove(id);
    }   
   
   //Create database query to bring back info on all the Opp line items we may need to update
    if (oppIds != '') {   
        String oliQuery = 'select Id, OpportunityId, PricebookEntryId, Quantity, ServiceDate, SortOrder' + oliFields + ' from OpportunityLineItem where OpportunityId in (' + oppIds + ') order by OpportunityId, SortOrder ASC';   
        //System.debug(qliQuery);    
      //put these Opps in a list  
        List<OpportunityLineItem> olis = Database.query(oliQuery);    
        //Declare a map of ids and list of Opp line items
        Map<Id, List<OpportunityLineItem>> oppToOliMap = new Map<Id, List<OpportunityLineItem>>();
        
        //populate the map, so that it is (oppid, list of opp line items for this opp)
        for (OpportunityLineItem oli : olis) {
            List<OpportunityLineItem> oliList = oppToOliMap.get(oli.OpportunityId);
            if (oliList == null) {
                oliList = new List<OpportunityLineItem>();
            } 
            oliList.add(oli);  
            oppToOliMap.put(oli.OpportunityId, oliList);       
        } 
     	//Declare 2 new sets - Opportunity line items & Quote line items to update
        Set<OpportunityLineItem> updateOlis = new Set<OpportunityLineItem>();
        Set<QuoteLineItem> updateQlis = new Set<QuoteLineItem>();
        System.debug('QuoteLineSync - Before FOR Loop: ');      
        
        //for each quote in the quotes map, 
        for (Quote quote : quotes.values()) {
            //get a list of corresponding opp line items    
            List<OpportunityLineItem> opplines = oppToOliMap.get(quote.OpportunityId);
            
            // for quote line insert, there will not be corresponding opp line
            if (opplines == null) continue;        
			//create a new set of matched opportunity line items
            Set<OpportunityLineItem> matchedOlis = new Set<OpportunityLineItem>();
        	
        	//get all the quote line items for the quote we are looking at
            for (QuoteLineItem qli : quoteToQliMap.get(quote.Id)) {
            	
                boolean updateOli = false;
                QuoteLineItem oldQli = null;
                
                if (trigger.isUpdate) {
                    oldQli = trigger.oldMap.get(qli.Id);
                    System.debug('Old qli: '  + oldQli.Quantity + ', ' + oldQli.SortOrder + ', ' + oldQli.ServiceDate);
                    System.debug('New qli: '  + qli.Quantity + ', ' + qli.SortOrder + ', ' + qli.ServiceDate);
                    
                    //compare field values old and new for quote line items, if they all match set updateOli to true
                    if ( //qli.UnitPrice == oldQli.UnitPrice
                        qli.Quantity == oldQli.Quantity
                        //&& qli.Discount == oldQli.Discount
                        && qli.ServiceDate == oldQli.ServiceDate
                        && qli.SortOrder == oldQli.SortOrder 
                        
                       )
                        updateOli = true;                       
                }
                
                                                                      
                boolean hasChange = false;
                boolean match = false;
                
                
                for (OpportunityLineItem oli : opplines) {          
                    if (oli.pricebookentryid == qli.pricebookentryId  
                        //&& oli.UnitPrice == qli.UnitPrice
                        && oli.Quantity == qli.Quantity
                        //&& oli.Discount == qli.Discount
                        && oli.ServiceDate == qli.ServiceDate
                        && oli.SortOrder == qli.SortOrder
                        
                       ) {
                        //if the oli is in the set to be updated or in the matchedOlis set, continue
                        if (updateOlis.contains(oli) || matchedOlis.contains(oli)) continue;  
                        //add this oli to the matchedOlis set
                        matchedOlis.add(oli);                       
                        System.debug('Before FOR Loop: ');
                        //for each of the quoteLineFields we want to sync                       
                        for (String qliField : quoteLineFields) {
                            String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                            Object oliValue = oli.get(oliField);
                            Object qliValue = qli.get(qliField);
                            System.debug('oliField value is: ' + oliField);
                            System.debug('oliValue is: ' + oliValue);
                            System.debug('qliValue is: ' + qliValue);
                            //if oli value is not the same as the qli value
                            if (oliValue != qliValue) { 
                                                                                                
//                              if (trigger.isInsert && (qliValue == null || (qliValue instanceof Boolean && !Boolean.valueOf(qliValue)))) {
                                /* REMOVED THIS IF STATEMENT TO SOLVE PROBLEM OF YEAR FIELD WITH DEFAULT VALUE BEING IGNORED */
                                
                                if (trigger.isInsert) {
                                
                                    //System.debug('Insert trigger, isSyncing: ' + quote.isSyncing + ', new quote ids: ' + QuoteSyncUtil.getNewQuoteIds());
                                    
                                    // If it's a newly created Quote, don't sync the "Description" field value, 
                                    // because it's already copied from Opportunity Line Item on create. 
                                    System.debug('quoteId is: ' + quote.Id);
                                    if (quote.isSyncing || (QuoteSyncUtil.isNewQuote(quote.Id) && !qliField.equalsIgnoreCase('description'))) {                                     
                                        qli.put(qliField, oliValue);
                                        System.debug('oliValue is: ' + oliValue);
                                        hasChange = true; 
                                    }    
                                   
                                } else if (trigger.isUpdate && !updateOli /*&& oldQli != null*/) {
                                    //Object oldQliValue = oldQli.get(qliField);
                                    //if (qliValue == oldQliValue) {
                                        if (oliValue == null) qli.put(qliField, null);
                                        else qli.put(qliField, oliValue);
                                        hasChange = true;
                                    //}     
                                     
                                } else if (trigger.isUpdate && updateOli) {
                                    if (qliValue == null) oli.put(oliField, null);
                                    else oli.put(oliField, qliValue);
                                    hasChange = true;  
                                }
                            }    
                        }
                        
                        if (hasChange) {
                            if (trigger.isInsert || (trigger.isUpdate && !updateOli)) { 
                                updateQlis.add(qli);
                            } else if (trigger.isUpdate && updateOli) {                               
                                updateOlis.add(oli);
                            }                    
                        } 
                        
                        match = true;      
                        break;                          
                    } 
                }
                
                // NOTE: this cause error when there is workflow field update that fired during record create
                //if (trigger.isUpdate && updateOli) System.assert(match, 'No matching oppline');     
            }
        }
     
        TriggerStopper.stopOpp = true;
        TriggerStopper.stopQuote = true;             
        TriggerStopper.stopOppLine = true;
        TriggerStopper.stopQuoteLine = true;    
                    
        if (!updateOlis.isEmpty()) { 
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            oliList.addAll(updateOlis);
                            
            Database.update(olilist);              
        }
        
        if (!updateQlis.isEmpty()) {
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();   
            qliList.addAll(updateQlis);
                              
            Database.update(qliList);            
        }
        
        if (Trigger.isInsert) {
           QuoteSyncUtil.removeAllNewQuoteIds(quoteIds);
        }                             
        
        TriggerStopper.stopOpp = false;
        TriggerStopper.stopQuote = false;                
        TriggerStopper.stopOppLine = false;          
        TriggerStopper.stopQuoteLine = false;           
    }    
}