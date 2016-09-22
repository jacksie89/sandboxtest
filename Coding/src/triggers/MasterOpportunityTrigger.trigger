trigger MasterOpportunityTrigger on Opportunity (after insert, after update, before insert, before update) {

    Map<ID, Account> accMap = new Map<ID, Account >();
    Map<Id, String> oppSolTypes = new Map<Id, String>();
    
    List<Opportunity> oppsWon = new List<Opportunity>();
    List<Opportunity> oppsAll = new List<Opportunity>();
    
    // Loop Through Opportunities Being Processed & build list of closed-won opps and all opps to work on in helper class
    for (Opportunity opp : Trigger.new) {
        
        if((Trigger.isInsert && opp.StageName == 'Closed-Won') || (opp.StageName == 'Closed-Won' && System.Trigger.oldMap.get(opp.Id).StageName != 'Closed-Won')){
            oppsWon.add(opp); 
        }
        oppsAll.add(opp);          
    }
        
    if(Trigger.isBefore){   //Cater for all before transactions - before insert
        
        if(Trigger.isUpdate){
            
            if(!oppsAll.isEmpty()){
                MasterOpportunityHelper.doCheckForDuplicateProduct(oppsAll); //Check for duplicate products
                /*oppSolTypes = MasterOpportunityHelper.setOpportunitySolutionType(oppsAll); // Set solution on opps
                for(Opportunity o : oppsAll){
                	o.Solution__c = oppSolTypes.get(o.Id);
                }*/
            }                   
        }
    }
    
    if(Trigger.isAfter){    //Cater for all after transactions
        System.debug('INSIDE AFTER PART OF OPP TRIGGER!!');
        if(Trigger.isUpdate){
            
            // Actions here to be done on both insert and update transactions
            if(!oppsWon.isEmpty()){
                //OpportunityClosedWon code to be called in here...
                MasterOpportunityHelper.doOpportunityTrigger(oppsWon);
            }               
        }
    }
}