public class ApplicationTriggerHandler{
    
    private static clcommon__Agreement__c dealerProgram;
    
    public void setValues(List<genesis__Applications__c> applications){
        if(applications != NULL){
            for(genesis__Applications__c application : applications){
                setDealerProgram(application);
                setFirstPaymentDueDate(application);
                // updating dealer with Invoice number for Unique check
                String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
                application.Duplicate_Dealer_Invoice_Number__c = application.Dealer__c + (application.Dealer_Invoice_Number__c != null? application.Dealer_Invoice_Number__c : hashString);
            }
        }   
    }
    
    // set dealer program on each application
    private void setDealerProgram(genesis__Applications__c application){
        if(dealerProgram == NULL){ // populate dealer program     
            dealerProgram = [SELECT ID FROM clcommon__Agreement__c WHERE Name = 'NewCo' LIMIT 1];
        }
        application.dealer_program__c = dealerProgram.id;     
    }
    
    // set first payment due date depending on expected start date on application
    public void setFirstPaymentDueDate(genesis__Applications__c application){  
        // Note: Ignoring the following condition ("application.genesis__Expected_Start_Date__c != application.Equipment_Install_Date__c") for dates updates.
        if(application.Equipment_Install_Date__c != NULL ) {
        //    && application.genesis__Expected_Start_Date__c != application.Equipment_Install_Date__c){
            
            Date startDate = application.Equipment_Install_Date__c;
            application.genesis__Expected_Start_Date__c = startDate;
            application.genesis__Expected_First_Payment_Date__c = cllease.DateUtil.getNextCycleDate(
                                                                        startDate, 
                                                                        startDate.day(),
                                                                        cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                                                                        1); 
            Boolean isLeapYear = Date.isLeapYear(startDate.year());
            /* First Payment due date should be nextCycleDate - 1 in case of arrears            
                01/01/2018 --> 01/31       
                01/29/2018 --> 02/28
                01/30/2018 --> 02/28
                01/31/2018 --> 02/28
                02/01/2018 --> 02/28 or 02/29
                
                01/01/2020 --> 01/31    
                01/29/2020 --> 02/28
                01/30/2020 --> 02/29
                01/31/2020 --> 02/29
                
                Special case for feb             
                02/02/2018 --> 03/02
            */
            if(!(
                    (startDate.month() == 1 && (startDate.day() >= 30 || (!isLeapYear && startDate.day() == 29))) 
                    || (startDate.month() == 2 && startDate.day() > 1)
                	|| (startDate.month() == 8 && startDate.day() == 31)
                )
            ){
                application.genesis__Expected_First_Payment_Date__c = application.genesis__Expected_First_Payment_Date__c - 1;
            }                                                                                                                               
        }
    }
    
}