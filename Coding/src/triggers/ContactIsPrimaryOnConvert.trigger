trigger ContactIsPrimaryOnConvert on Lead (after update) {
// no bulk processing; will only run from the UI
  if (Trigger.new.size() == 1) {
    if (Trigger.old[0].isConverted == false && Trigger.new[0].isConverted == true) {      
      // if a new contact was created
      if (Trigger.new[0].ConvertedContactId != null && Trigger.new[0].ConvertedOpportunityId != null) {
        // update the converted contact with some text from the lead 
        OpportunityContactRole ocr = [Select ocr.Id From OpportunityContactRole ocr Where ocr.ContactId = :Trigger.new[0].ConvertedContactId and ocr.OpportunityId = :Trigger.new[0].ConvertedOpportunityId];
        ocr.IsPrimary = true;
        
        update ocr;
      }      
    }
  }   
}