trigger ExperianDataQuality_QuickQuote_BIBU on genesis__Quick_Quotes__c (before insert, before update) {
    EDQ.DataQualityService.SetValidationStatus(Trigger.new, Trigger.old, Trigger.IsInsert, 2); 
}