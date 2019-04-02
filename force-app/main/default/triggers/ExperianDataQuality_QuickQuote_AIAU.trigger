trigger ExperianDataQuality_QuickQuote_AIAU on genesis__Quick_Quotes__c (after insert, after update) {
    EDQ.DataQualityService.ExecuteWebToObject(Trigger.New, 2, Trigger.IsUpdate);
}