trigger ServiceEscalation on Application_Fee__c (before insert,Before Update) {
     public static final String SERVICE_FEE_NAME = 'Service Fees';
     Map<id,genesis__Applications__c> mapApp = new Map<id,genesis__Applications__c>();
     Map<id,clcommon__Fee_Definition__c> mapfee = new Map<id,clcommon__Fee_Definition__c>();
     Map<id,genesis__Application_Equipment__c> mapequip = new Map<id,genesis__Application_Equipment__c>();
     Map<id,genesis__Application_Equipment__c> equipmap = new Map<id,genesis__Application_Equipment__c>();
     public static string EscalationFrequency = System.Label.DefaultEscalationFrequency;
     public static integer EscalationValue = integer.ValueOf(System.Label.DefaultFrequencyValue);
     set<id> appSet   = new set<id>();
     set<id> feeSet   = new set<id>();
     set<id> equipset = new set<id>();
     //Checking the RecursiveFlag and on BeforeInsert Trigger//
     if(trigger.IsInsert && trigger.IsBefore && checkRecursive.runOnce()){
         List<Application_Fee__c> feelist = new List<Application_Fee__c>();
         //Getting the ralated application,Fee,Equipments Fields to used in the Conditions and Create Records//
         for(Application_Fee__c f : Trigger.new){
            
            appSet.add(f.Application__c);
            feeSet.add(f.Fee__c);
            equipset.add(f.Equipment__c);
         }       
         for(genesis__Applications__c App : [SELECT id,name,genesis__Expected_First_Payment_Date__c,Total_Equipment_Cost__c,Pre_Upfront_Tax_Payment_Amount__c,genesis__Term__c FROM genesis__Applications__c WHERE Id IN: appSet]){
            
            mapApp.put(App.id,App);   
         }
         for(clcommon__Fee_Definition__c fe : [SELECT Id,name FROM clcommon__Fee_Definition__c WHERE Id IN: FeeSet]){
             mapfee.put(fe.id,fe);
         }
         for(genesis__Application_Equipment__c equiment: [SELECT Id,name,genesis__Estimated_Selling_Price__c from genesis__Application_Equipment__c WHERE Id IN :equipset]){
             equipmap.put(equiment.id,equiment);
         }
           //Lopping through newly inserted Application Fee and Cross verifying the Fee Befor Escalating//
            for(Application_Fee__c fee : Trigger.new){
                 clcommon__Fee_Definition__c feeDef = new clcommon__Fee_Definition__c();
                 genesis__Applications__c    feeApp = new genesis__Applications__c();
                 genesis__Application_Equipment__c equipfee = new genesis__Application_Equipment__c();
                 //Checking the Map and Getting the Values if existed for perticular fee//
                 if( !mapfee.isEmpty() && mapfee.ContainsKey(fee.Fee__c) ){
                      
                      feeDef = mapfee.get(fee.Fee__c);
                 }
                 if( !mapApp.isEmpty() && mapApp.ContainsKey(fee.Application__c)){
                    
                      feeApp = mapApp.get(fee.Application__c);   
                 }
                 if(!equipmap.isEmpty() && equipmap.ContainsKey(fee.Equipment__c)){
                     equipfee = equipmap.get(fee.Equipment__c);
                 }
                 System.debug('****feeDef.Name*****'+feeDef.Name);
                 System.debug('***fee.Number_of_Payments__c****'+fee.Number_of_Payments__c);
                 System.debug('***feeApp.genesis__Term__C****'+feeApp.genesis__Term__c);
                 
                 //Checking the Upfront_Tax_Payemnt_Amount is caluclated and pricing is generated or not//
                 if(feeApp.Pre_Upfront_Tax_Payment_Amount__c > 0  && feeDef.Name == 'Service Fees' && fee.Service_Escalate__c == 'YES'){
                     //Throwing an Validation error if Amount is less or equal to zero//
                     if(fee.Amount__c <= 0){
                         fee.addError('The Amount cannot be less than equal to Zero');
                     }
                     //Auto Assigning the Due Date for the Fee for SericeFee if user left the field blank
                     if(fee.Start_Date__c == null &&  feeDef.Name == 'Service Fees'){
                     
                         fee.Start_Date__c = feeApp.genesis__Expected_First_Payment_Date__c;
                         System.debug('*****feeApp.genesis__Expected_First_Payment_Date__c***'+feeApp.genesis__Expected_First_Payment_Date__c);
                     }
                     //Validating the ServcieFee Child record crossing the MaturityDate//
                     if(fee.Number_of_Payments__c > feeApp.genesis__Term__c){
                 
                     fee.addError('Number of Payments Cannot be Greater than Genesis Lease Term');
                     }
                     else{
                     if(fee.Start_Date__c != null && feeDef.Name == 'Service Fees')
                     {
                         Date MaturityDate;
                         MaturityDate = feeApp.genesis__Expected_First_Payment_Date__c;
                         System.debug('***MaturityDate***'+MaturityDate);
                         MaturityDate = cllease.DateUtil.getNextCycleDate(
                                                                           MaturityDate, 
                                                                           MaturityDate.day(),
                                                                           cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                                                                           feeApp.genesis__Term__c.intValue());
                         
                         System.debug('*****MaturityDate**generated***'+MaturityDate);
                         Date myDate;
                         myDate = fee.Start_Date__c;
                         myDate = cllease.DateUtil.getNextCycleDate(
                                                                       myDate, 
                                                                       myDate.day(),
                                                                       cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                                                                       fee.Number_of_Payments__c.intValue());
                        System.debug('*****myDate**Generated***'+myDate);
                        if(myDate > MaturityDate){
                            
                            fee.addError('The Date which you entered was crossing the Maturity Date ' +MaturityDate.format()+ ' for the subsequent records.Please Enter First Payment Due Date or any suitable Due Date');
                        }
                        
                        else if(fee.Start_Date__c < feeApp.genesis__Expected_First_Payment_Date__c)
                        {
                            fee.addError('The Due Date Cannot be less than First payment Date ' +feeApp.genesis__Expected_First_Payment_Date__c.format()+' ');
                        } 
                        
                      }
                     }
                     if((fee.Parent_id__c == null || fee.Parent_Application_Fee__c == null) && fee.Service_Escalate__c == 'YES' && fee.Equipment__c != null && feeDef.Name == 'Service Fees' && !fee.Prorate_Per_Asset__c){
                         
                         
                         fee.Number_of_Terms__c = fee.Number_of_Payments__c;
                         if(fee.Escalation_Frequency__c == null){
                            fee.Number_of_Payments__c = EscalationValue;
                            fee.Escalation_Frequency__c = EscalationFrequency;                         
                         }
                         else{
                         fee.Number_of_Payments__c = fee.Calculating_Frequency__c;
                         }
                         
                     }
                     else if((fee.Parent_id__c == null || fee.Parent_Application_Fee__c == null) && fee.Service_Escalate__c == 'YES' && fee.Equipment__c != null && feeDef.Name == 'Service Fees' && fee.Prorate_Per_Asset__c){
                                Decimal Amount = fee.Amount__c;
                                fee.Number_of_Terms__c = fee.Number_of_Payments__c;
                                if(fee.Escalation_Frequency__c == null){
                                    fee.Number_of_Payments__c = EscalationValue;
                                    fee.Escalation_Frequency__c = EscalationFrequency;                                 
                                 }
                                 else{
                                    fee.Number_of_Payments__c = fee.Calculating_Frequency__c;
                                 }
                                //fee.Number_of_Payments__c = fee.Calculating_Frequency__c;
                                fee.ProrateAmount__c = Amount;
                                fee.Amount__c = (Amount)*(equipfee.genesis__Estimated_Selling_Price__c/feeApp.Total_Equipment_Cost__c).setScale(4);
                     }
                     //Creating the ServiceFee for all the Equiments and prorating the Amount as per EscalationFrequency. If no Equipment is Associated to the Fee while Creating//
                     else if((fee.Parent_id__c == null || fee.Parent_Application_Fee__c == null) && fee.Service_Escalate__c == 'YES' && fee.Equipment__c == null && feeDef.Name == 'Service Fees'){
                         
                         
                         set<id> equipds = new set<id>();
                         Decimal Amount = fee.Amount__c;
                            for(genesis__Application_Equipment__c eq: [SELECT Id,Name,
                                                                                     genesis__Application__c,
                                                                                     genesis__Estimated_Selling_Price__c 
                                                                                FROM genesis__Application_Equipment__c 
                                                                                WHERE genesis__Application__c =:fee.Application__c]){
                                
                                
                                if(!equipds.contains(eq.id) && equipds.size() == 0){
                                fee.Number_of_Terms__c = fee.Number_of_Payments__c;
                                if(fee.Escalation_Frequency__c == null){
                                    fee.Number_of_Payments__c = EscalationValue;
                                    fee.Escalation_Frequency__c = EscalationFrequency;                                 
                                 }
                                 else{
                                    fee.Number_of_Payments__c = fee.Calculating_Frequency__c;
                                 }
                                //fee.Number_of_Payments__c = fee.Calculating_Frequency__c;
                                fee.ProrateAmount__c = Amount;
                                fee.Amount__c = (Amount)*(eq.genesis__Estimated_Selling_Price__c/feeApp.Total_Equipment_Cost__c).setScale(4);
                                fee.Prorate_Per_Asset__c  = True;
                                
                                fee.Equipment__c = eq.id;
                                equipds.add(eq.id);
                                }                                           
                                if(!equipds.contains(eq.id) && equipds.size() != 0){
                                    
                                    Application_Fee__c appfee   = new Application_Fee__c();
                                    
                                    appfee.Number_of_Terms__c        = fee.Number_of_Terms__c;
                                    appfee.Application__c            = feeApp.id;
                                    appfee.Number_of_Payments__c     = fee.Number_of_Payments__c;
                                    appfee.Frequency__c              = fee.Frequency__c;
                                    appfee.Fee__c                    = feeDef.id;
                                    appfee.prorateAmount__C          = Amount;
                                    appfee.Amount__c                 = (Amount)*(eq.genesis__Estimated_Selling_Price__c/feeApp.Total_Equipment_Cost__c).setScale(4);
                                    appfee.Service_Escalate__c       = fee.Service_Escalate__c;
                                    appfee.Escalation_Value__c       = fee.Escalation_Value__c;
                                    appfee.Escalation_Type__c        = fee.Escalation_Type__c;
                                    appfee.Escalate_Service_On__c    = fee.Escalate_Service_On__c;
                                    appfee.Start_Date__c             =  feeApp.genesis__Expected_First_Payment_Date__c;
                                    appfee.Equipment__c              =  eq.id;
                                    appfee.Escalation_Frequency__c   =  fee.Escalation_Frequency__c == null ? EscalationFrequency : fee.Escalation_Frequency__c;
                                    appfee.Prorate_Per_Asset__c      =  True;
                                    System.debug('*** the value entered for Amount field****'+fee.Amount__c);
                                    equipds.add(eq.id);
                                    feelist.add(appfee);
                                    
                                    System.debug('****feelist.size()****'+feelist.size());
                                }
                            }   
                        }
                    }
                    else if(feeApp.Pre_Upfront_Tax_Payment_Amount__c <= 0  && feeDef.Name == 'Service Fees' && fee.Service_Escalate__c == 'YES'){
                        
                        fee.addError('Please Generate and SelectPricing before Escalating Service Fee');
                    }                   
            }
            if(feelist.size()>0){
               System.debug('*****feelist.size()****'+feelist.size());
             insert feelist;
             }             
        }
             
     //Checking the Recursive Before Updating the Record//
     if(trigger.IsBefore && trigger.isUpdate && checkRecursive.runOnce()){
         //Getting all the Related parents Records of the Application Fee//
         for(Application_Fee__c f : Trigger.new){
            
            appSet.add(f.Application__c);
            feeSet.add(f.Fee__c);   
         }       
         for(genesis__Applications__c App : [SELECT id,name,genesis__Expected_First_Payment_Date__c,Total_Equipment_Cost__c,Pre_Upfront_Tax_Payment_Amount__c,genesis__Term__c FROM genesis__Applications__c WHERE Id IN: appSet]){
            
            mapApp.put(App.id,App);   
         }
         for(clcommon__Fee_Definition__c fe : [SELECT Id,name FROM clcommon__Fee_Definition__c WHERE Id IN: FeeSet]){
             mapfee.put(fe.id,fe);
         }
         for(genesis__Application_Equipment__c eq: [SELECT Id,Name,
                                                                                 genesis__Application__c,
                                                                                 genesis__Estimated_Selling_Price__c 
                                                                            FROM genesis__Application_Equipment__c 
                                                                            WHERE genesis__Application__c IN:appSet]){
            mapequip.put(eq.id,eq);  
         }
         Decimal Amount = 0;
         List<Application_Fee__c> updatFee = new List<Application_Fee__c>();
         System.debug('*****entered into before update trigger*****');
         //Looping through newly Updated Records//
         for(Application_Fee__c fee : trigger.new){
             clcommon__Fee_Definition__c feeDef = new clcommon__Fee_Definition__c();
             genesis__Applications__c    feeApp = new genesis__Applications__c();
             genesis__Application_Equipment__c equip = new genesis__Application_Equipment__c();
             
             if( !mapfee.isEmpty() && mapfee.ContainsKey(fee.Fee__c) ){
                      
                      feeDef = mapfee.get(fee.Fee__c);
                 }
                 if( !mapApp.isEmpty() && mapApp.ContainsKey(fee.Application__c)){
                    
                    feeApp = mapApp.get(fee.Application__c);   
                 }
             if(!mapequip.isEmpty() && mapequip.Containskey(fee.Equipment__c)){
             
                 equip = mapequip.get(fee.Equipment__c);
             }
             
             Amount = fee.Amount__c;
             System.debug('***** the values in the Amount*******'+Amount);
             Application_Fee__c oldfee = trigger.oldMap.get(fee.id);
         //Checking the old Values with newly updated Values and Triggering the Validation Based on that//
        if(oldfee.Service_Escalate__c != fee.Service_Escalate__c && fee.Service_Escalate__c == 'NO' && feeDef.Name == 'Service Fees'){
            
            fee.addError('Escalated Fee cannot be reverted. Please delete the Service Fee using the Delete Checkbox and create New Service Fee');
        }
        //Checking the UpdfrontTax is Caluclated and Pricing is Generated Successfully moving Further or Triggering Validation Error//
        else if(feeApp.Pre_Upfront_Tax_Payment_Amount__c > 0 && feeDef.Name == 'Service Fees' && fee.Service_Escalate__c == 'YES'){
             if(fee.Equipment__c != oldfee.Equipment__c || fee.Service_Escalate__c == 'YES' && fee.Service_Escalate__c != oldfee.Service_Escalate__c && fee.Parent_Application_Fee__c == null){
                //Checking the Due Date is Blank and Assigning the AutoAssigning the Due Date// 
                if(fee.Start_Date__c == null && feeDef.Name == 'Service Fees'){
                 
                     fee.Start_Date__c = feeApp.genesis__Expected_First_Payment_Date__c;
                 }
                 if((fee.Parent_id__c == null || fee.Parent_Application_Fee__c == null) && fee.Service_Escalate__c == 'YES' && fee.Service_Escalate__c != oldfee.Service_Escalate__c && feeDef.Name == 'Service Fees' && !fee.Prorate_Per_Asset__c){
                     fee.Number_of_Terms__c = fee.Number_of_Payments__c;
                     if(fee.Escalation_Frequency__c == null){
                                    fee.Number_of_Payments__c = EscalationValue;
                                    fee.Escalation_Frequency__c = EscalationFrequency;                                 
                                 }
                                 else{
                                    fee.Number_of_Payments__c = fee.Calculating_Frequency__c;
                                 }
                    
               }
              }
              //Escalating the Fee PerEquipment if Prorate Per Asset Check Box is true Means//
              if((fee.Parent_id__c == null || fee.Parent_Application_Fee__c == null) && (fee.Service_Escalate__c == 'YES' && feeDef.Name == 'Service Fees' && fee.Prorate_Per_Asset__c) && (fee.Prorate_Per_Asset__c != oldfee.Prorate_Per_Asset__c || fee.Amount__c != oldfee.Amount__c || fee.Equipment__c != oldfee.Equipment__c)){
                         
                       fee.ProrateAmount__c = Amount;  
                       fee.Amount__c = (Amount)*(equip.genesis__Estimated_Selling_Price__c/feeApp.Total_Equipment_Cost__c).setScale(4);
                    if(fee.Start_Date__c == null && feeDef.Name == 'Service Fees'){
                 
                        fee.Start_Date__c = feeApp.genesis__Expected_First_Payment_Date__c;
                    }
                    //Validating the Due Date While Updating the Child record with New Due Date if DueDate Crossing the Maturity Date throwing the validatin Error//
                    else if(fee.Start_Date__c != null && feeDef.Name == 'Service Fees' && oldfee.Start_Date__c != fee.Start_Date__c)
                    {
                         Date MaturityDate;
                         MaturityDate = feeApp.genesis__Expected_First_Payment_Date__c;
                         System.debug('***MaturityDate***'+MaturityDate);
                         MaturityDate = cllease.DateUtil.getNextCycleDate(
                                                                           MaturityDate, 
                                                                           MaturityDate.day(),
                                                                           cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                                                                           feeApp.genesis__Term__c.intValue());

                         System.debug('*****MaturityDate**generated***'+MaturityDate);
                         
                         Date myDate;
                         myDate = fee.Start_Date__c;
                         myDate = cllease.DateUtil.getNextCycleDate(
                                                                       myDate, 
                                                                       myDate.day(),
                                                                       cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                                                                       fee.Number_of_Terms__c.intValue());
                        System.debug('*****myDate**Generated***'+myDate);
                        if(myDate > MaturityDate){
                            
                            fee.addError('The Date which you entered was crossing the Maturity Date ' +MaturityDate.format()+ ' for the subsequent records.Please Enter First Payment Due Date or any suitable Due Date');
                        }
                        else if(fee.Start_Date__c < feeApp.genesis__Expected_First_Payment_Date__c)
                        {
                            fee.addError('The Due Date Cannot be less than First payment Date ' +feeApp.genesis__Expected_First_Payment_Date__c.format()+' ');
                        } 
                        
                     }
                            
              
             }
             // Checking The Number of Payments Field Update if its Already Escalated we stoping the user to do that//
              else if((fee.Parent_id__c == null || fee.Parent_Application_Fee__c== null) && fee.Service_Escalate__c == 'YES' && fee.Number_of_Payments__c != fee.Calculating_Frequency__c && feeDef.Name == 'Service Fees' && !fee.IsDelete__c){
                System.debug('***the value in the Number of Payments Before insert****'+fee.Number_of_Payments__c);
                if(fee.Escalation_Frequency__c == null){
                                    fee.Number_of_Payments__c = EscalationValue;
                                    fee.Escalation_Frequency__c = EscalationFrequency;
                                    
                                 }
                                 else{
                                    fee.Number_of_Payments__c = fee.Calculating_Frequency__c;
                                 }
                //fee.Number_of_Payments__c = fee.Calculating_Frequency__c;
                fee.addError('Changes Not Allowed on Number of Terms Field Once Escalated. please Delete the Fee Using Delete Check Box and Create New Service Fees');     
              }
              //checking the Due Date is changed and not crossing the Maturity of Child Records//
              else if(fee.Start_Date__c != null && feeDef.Name == 'Service Fees' && oldfee.Start_Date__c != fee.Start_Date__c){
                  
                         Date MaturityDate;
                         MaturityDate = feeApp.genesis__Expected_First_Payment_Date__c;
                         System.debug('***MaturityDate***'+MaturityDate);
                         MaturityDate = cllease.DateUtil.getNextCycleDate(
                                                                           MaturityDate, 
                                                                           MaturityDate.day(),
                                                                           cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                                                                           feeApp.genesis__Term__c.intValue());

                         System.debug('*****MaturityDate**generated***'+MaturityDate);
                    
                         Date myDate;
                         myDate = fee.Start_Date__c;
                         myDate = cllease.DateUtil.getNextCycleDate(
                                                                       myDate, 
                                                                       myDate.day(),
                                                                       cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                                                                       fee.Number_of_Terms__c.intValue());
                        System.debug('*****myDate**Generated***'+myDate);
                        if(myDate > MaturityDate){
                            
                            fee.addError('The Date which you entered was crossing the Maturity Date ' +MaturityDate.format()+ ' for the subsequent records.Please Enter First Payment Due Date or any suitable Due Date');
                        }
                        else if(fee.Start_Date__c < feeApp.genesis__Expected_First_Payment_Date__c)
                        {
                            fee.addError('The Due Date Cannot be less than First payment Date ' +feeApp.genesis__Expected_First_Payment_Date__c.format()+' ');
                        }
                     
              }
        }
        else if(feeApp.Pre_Upfront_Tax_Payment_Amount__c <= 0 && feeDef.Name == 'Service Fees' && fee.Service_Escalate__c == 'YES' && !fee.IsDelete__c){
             
            System.debug('***'+feeDef.Name);
            System.debug('***'+fee.Service_Escalate__c);   
            fee.addError('Pricing need to be Generated and Selected before Escalating Service Fee');
        }
    }
          
   }   
}