public with sharing class DeleteServiceCharge {
    public static final String SERVICE_FEE_NAME = 'Service Fees';
    public static Decimal term = 0,EscalationFrequency = 0,c = 0,Amount = 0,EscalationValue =0,DividentValue = 100,result = 0;
    public static list<Application_Fee__c> listApplicationFee = new list<Application_Fee__c>();
    public static Date myDate;
    public static integer i=0;
//Invocable method to get the id from Process Builder
    @InvocableMethod
     public static void invokeDeleteServiceFee(List<Application_Fee__c> feeid) {
        
        
        if(feeid[0].Parent_id__c == null)  
        DeleteServiceChargeEscalation(feeid[0].id);   
    }
    public static string DeleteServiceChargeEscalation(Id feeid) 
    {
    
      try{
        List<Application_Fee_Payment__c> feePayment = new List<Application_Fee_Payment__c>();
        List<Application_Fee__c> feeList = [SELECT id,
                                                   name
                                          FROM Application_Fee__c WHERE id =:feeid OR Parent_id__c =:feeid];
        feePayment = [Select id,name from Application_Fee_Payment__c where Application_Fee__r.id =: feeList];
        if(feePayment.size()> 0){
        i = feePayment.size();
        Database.DeleteResult[] DelFeePaymentList = Database.delete(feePayment, false);
        for(Database.DeleteResult dr : DelFeePaymentList) {
            if (dr.isSuccess()) {
                i--;    
            }
          }
        }
        if(i <= 0)
        {   
            if(feeList.size() > 0)
            Database.DeleteResult[] DelFeePaymentList = Database.delete(feeList, false);        
            //Delete feeList;
        }
        return System.label.SUCCESS_MSG;
      }
        Catch(Exception e){
      
            string exe = e.getMessage();
            return exe;
        }
    }
}