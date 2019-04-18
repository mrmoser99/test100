public class UpdateServiceFeeHandler{
    
    public static final String SERVICE_FEE_NAME = 'Service Fees';
    
    public static void func_USF(List<Application_Fee__c> app_fee, string operation){
        
        // get application ids
        Set<Id> applicationIdSet = new Set<Id>();
        for(Application_Fee__c afee : app_fee){
            applicationIdSet.add(afee.Application__c);
        }
        
        Map<Id, genesis__Applications__c> applicationsById = new Map<Id, genesis__Applications__c>();
        AggregateResult[] selectedApplicationFees = [SELECT Application__c, 
                                                             Frequency__c, 
                                                             Equipment__c,
                                                             MIN(Amount__c)MinVal 
                                                             FROM Application_Fee__c 
                                                                 WHERE Fee__r.Name = :SERVICE_FEE_NAME
                                                                     AND Application__c IN :applicationIdSet
                                                                     AND Frequency__c != 'ONE TIME'
                                                                     AND Equipment__c != NULL
                                                                 GROUP BY Application__c, Frequency__c, Equipment__c ];
        
        Set<Id> processAppIds = new Set<Id>();
        for(AggregateResult result : selectedApplicationFees){
            String applicationId = String.valueOf(result.get('Application__c'));
            genesis__Applications__c app = applicationsById.get(applicationId);
            if(app == NULL){
                app = new genesis__Applications__c(Id = applicationId, Service_Fee__c = 0);
                applicationsById.put(applicationId, app);
            } 
            Double minVal = Double.valueOf(result.get('MinVal'));
            app.Service_Fee__c = app.Service_Fee__c + minVal;    
            processAppIds.add(applicationId);
        }
        
        // remove processed app ids from entire set. Remaining Apps do not have service fees so 
        // amount should be set to 0
        
        applicationIdSet.removeAll(processAppIds);
        for(Id applicationId : applicationIdSet){
            genesis__Applications__c app = applicationsById.get(applicationId);
            if(app == NULL){
                app = new genesis__Applications__c(Id = applicationId, Service_Fee__c = 0);
                applicationsById.put(applicationId, app);
            } 
        }
        
        /*
        app_fee = [Select Id, 
                          Equipment__c, 
                          Application__c,
                          Start_Date__c,
                          Amount__c,
                          Fee__c,
                          Frequency__c
                          FROM Application_Fee__c
                              WHERE Application__c IN :applicationIdSet 
                                  AND Fee__r.Name =:SERVICE_FEE_NAME];
                              
                             
        // create a map of equipment wise application fees mapped to their respective applications
        Map<Id, Map<Id, List<Application_Fee__c>>> appFeeByEquipmentIdMapByAppId = new Map<Id, Map<Id, List<Application_Fee__c>>>();
        for(Application_Fee__c appFee : app_fee){
            Map<Id, List<Application_Fee__c>> appFeeByEquipmentId = appFeeByEquipmentIdMapByAppId.get(appFee.Application__c);
            List<Application_Fee__c> feesPerEquipment;
            
            if(appFeeByEquipmentId == NULL){
                appFeeByEquipmentId = new Map<Id, List<Application_Fee__c>>();
                feesPerEquipment = new List<Application_Fee__c>();
            } else {
                feesPerEquipment = appFeeByEquipmentId.get(appFee.Equipment__c);
                if(feesPerEquipment == NULL){
                    feesPerEquipment = new List<Application_Fee__c>();
                }
            }
            feesPerEquipment.add(appFee);
            appFeeByEquipmentId.put(appFee.Equipment__c, feesPerEquipment);
            appFeeByEquipmentIdMapByAppId.put(appFee.Application__c, appFeeByEquipmentId);      
        }
        
        // Sum of amount for min dates per equipment
        AggregateResult[] selectedApplicationFees = [SELECT Application__c, 
                                                             Frequency__c, 
                                                             Equipment__c,
                                                             MIN(Start_Date__c)MinDate 
                                                             FROM Application_Fee__c 
                                                                 WHERE Fee__r.Name = :SERVICE_FEE_NAME
                                                                     AND Application__c IN :appFeeByEquipmentIdMapByAppId.keySet()
                                                                     AND Frequency__c != 'ONE TIME'
                                                                     AND Equipment__c != NULL
                                                                 GROUP BY Application__c, Frequency__c, Equipment__c ];
        
        System.debug('selectedApplicationFees' +  selectedApplicationFees);                                             
        Map<Id, genesis__Applications__c> applicationsById = new Map<Id, genesis__Applications__c>();
        
        for(AggregateResult result : selectedApplicationFees){
            String applicationId = String.valueOf(result.get('Application__c'));
            String equipmentId = String.valueOf(result.get('Equipment__c'));
            if(applicationId != NULL && equipmentId != NULL){
                Map<Id, List<Application_Fee__c>> feesPerEquipmentForApp = appFeeByEquipmentIdMapByAppId.get(applicationId);
                if(feesPerEquipmentForApp != NULL){
                    List<Application_Fee__c> feesForEquipment = feesPerEquipmentForApp.get(equipmentId);
                    if(feesForEquipment != NULL && feesForEquipment.size() > 0){
                        Date minDate = Date.valueOf(result.get('MinDate'));
                        // get application record
                        genesis__Applications__c app = applicationsById.get(applicationId);
                        if(app == NULL){
                            app = new genesis__Applications__c(Id = applicationId,                                                               
                                                               Service_Fee__c = 0);
                        }  
                            
                        for(Application_Fee__c afee : feesForEquipment){
                            if(afee.Start_Date__c == minDate){
                                app.Service_Fee__c = app.Service_Fee__c + afee.Amount__c;
                            }
                        }
                        applicationsById.put(applicationId, app);
                    }
                }     
            }
        }
        */
        
        update applicationsById.values();
    
    }
    
    // This is invoked from Calculate Insurance to update date on fees 
    // if expected first payment date on application changes
    public static void updateDateOnFees(String applicationId){
        genesis__Applications__c application = [SELECT genesis__Term__c,
                                                       genesis__Expected_First_Payment_Date__c,
                                                       Id
                                                       FROM genesis__Applications__c 
                                                           WHERE id= :applicationId LIMIT 1];
    
    
        AggregateResult[] selectedApplicationFees = [SELECT Equipment__c,
                                                            Frequency__c,
                                                            MIN(Start_Date__c)MinDate 
                                                            FROM Application_Fee__c 
                                                                 WHERE Fee__r.Name = :SERVICE_FEE_NAME
                                                                     AND Application__c = :applicationId
                                                                     AND Frequency__c != 'ONE TIME'
                                                                 GROUP BY Equipment__c, Frequency__c];
         
        Map<String, Date> minDatePerEquipment = new Map<String, Date>();
        for(AggregateResult result : selectedApplicationFees){
            String equipmentId = String.valueOf(result.get('Equipment__c'));
            Date minDate = Date.valueOf(result.get('MinDate'));
            minDatePerEquipment.put(equipmentId, minDate);
        }
        
        List<Application_Fee__c> applicationFees = [Select Id, 
                                                            Equipment__c, 
                                                            Start_Date__c,
                                                            Amount__c,
                                                            Fee__c,
                                                            Frequency__c,
                                                            Number_of_Payments__c
                                                            FROM Application_Fee__c
                                                                  WHERE Application__c = :applicationId
                                                                      AND Fee__r.Name =:SERVICE_FEE_NAME
                                                                      AND Frequency__c != 'ONE TIME'
                                                                      ORDER BY Equipment__c, Start_Date__c ASC];   
                                                                      
        
        Map<Id, List<Application_Fee__c>> feesPerEquipment = new Map<Id, List<Application_Fee__c>>();
        for(Application_Fee__c fee : applicationFees){
            List<Application_Fee__c> temp = feesPerEquipment.get(fee.Equipment__c);
            if(temp == NULL){
                temp = new List<Application_Fee__c>();
                feesPerEquipment.put(fee.Equipment__c, temp);      
            }
            temp.add(fee);
        } 
        
        List<Application_Fee__c> feesToUpdate = new List<Application_Fee__c>();
        for(Id equipmentId : feesPerEquipment.keySet()){
            List<Application_Fee__c> temp = feesPerEquipment.get(equipmentId);
            if(temp != NULL && temp.size() > 0){
                temp[0].Start_Date__c = application.genesis__Expected_First_Payment_Date__c;
                for(Integer i = 1; i < temp.size() ; i++){
                    temp[i].Start_Date__c = genesis.DateUtil.getNextCycleDate(
                                                               temp[i - 1].Start_Date__c,
                                                               temp[i - 1].Start_Date__c.day(),
                                                               genesis.LendingConstants.PAYMENT_FREQ_MONTHLY,
                                                               temp[i -1].Number_of_Payments__c.intValue());       
                }
                feesToUpdate.addAll(temp);
            }     
        }
        
        update feesToUpdate;                                                                                                                                  
    }
}