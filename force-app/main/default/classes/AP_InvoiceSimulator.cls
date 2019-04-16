global with sharing class AP_InvoiceSimulator {

   
     public class resultLine{
        @AuraEnabled public String equipmentName; 
        @AuraEnabled public String recordName; 
        @AuraEnabled public String fee;
        @AuraEnabled public String feeAmount;
        @AuraEnabled public String taxAmount;
        @AuraEnabled public String totalAmount;
        @AuraEnabled public String className;
      
     }
    /********************************************************************************************
   	* get adjustments
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static List<resultLine> getAdjustments(String recordId){
        
        List<resultLIne> results= new List<resultLine>();

        List<adjustment__c> aList = new List<adjustment__c>();
        aList = [select Id
                ,adjustment_type__c
                ,credit__c
                ,debit__c
                ,charge__c
                ,Charge__r.Name  
                ,Due_Detail_Line__r.Name  
                ,Due_Detail_Line__c
                ,tax_amount__c
                ,equipment__c
                from adjustment__c
                where invoice__c = :recordId
          ];
        
        Decimal feeTotal = 0;
        Decimal taxTotal =  0;
        Decimal totalTotal = 0;
        resultLine r = new resultLine();

        for (Adjustment__c a:aList){
            r = new resultLine();

            r.equipmentName = a.equipment__c;

            if (a.charge__c != null)
                r.recordName = a.charge__r.name;

            if (a.due_detail_line__c != null)
                r.recordName = a.due_detail_line__r.name;
           
            r.fee = a.adjustment_type__c;
            if (a.tax_amount__c == null)
                a.tax_amount__c = 0.00;

            r.feeAmount =  string.valueOf(0 - a.credit__c);
            feeTotal = feeTotal + (0 - a.credit__c);
            taxTotal = taxTotal + ( 0 - a.tax_amount__c);
            totalTotal = totalTotal + (0 - a.credit__c) + (0 - a.tax_amount__c);
            r.taxAmount = string.valueOf(0 - a.tax_amount__c);
            r.totalAmount = string.valueOf((0 - a.credit__c) + (0 - a.tax_amount__c));
            results.add(r);
        }

        r = new resultLine();
        r.equipmentName = 'Totals';
        r.fee = '';
        r.feeAmount = string.valueOf(feeTotal);
        r.taxAmount = string.valueOf(taxTotal);
        r.totalAmount = string.valueOf(totalTotal);
        r.className = 'makeBold';
        results.add(r);
        
        return results;
    }

     
    /********************************************************************************************
   	* get charges and bills
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static List<resultLine> getCharges(String recordId){
        
        List<resultLine> results = new List<resultLine>();

        List<cllease__charge__c> cList = new List<cllease__Charge__c>();
        cList = [select Id
                ,name
                ,cllease__Original_Amount__c
                ,cllease__Tax_Due__c
                ,cllease__Fee_Definition__r.name
                ,cllease__Contract_Equipment__r.Equipment_Description1__c
                from cllease__Charge__c
                where invoiced_In__c = :recordId
                order by cllease__Contract_Equipment__r.Equipment_Description1__c
                ];
        
        Decimal feeTotal = 0;
        Decimal taxTotal =  0;
        Decimal totalTotal = 0;

        
        resultLine  r = new resultLine();
        /*
        r.recordName = 'Charge/Bill Id';
        r.fee = 'Description';
        r.feeAmount = 'Amount';
        r.taxAmount = 'Tax';
        r.totalAmount = 'Total';
        r.className = 'makeBold';
        
        results.add(r);  
        */

        for (cllease__charge__c c:cList){
            r = new resultLine();
            r.equipmentName  = c.cllease__Contract_Equipment__r.Equipment_Description1__c;
            r.recordName = c.name;
            r.fee =  c.cllease__Fee_Definition__r.name;
            feeTotal = feeTotal + c.cllease__Original_Amount__c;
            taxtotal = taxTotal  + c.cllease__Tax_Due__c;
            totalTotal = totalTotal + c.cllease__Original_Amount__c +  c.cllease__Tax_Due__c;
            r.className = 'rightJustify';
            r.feeAmount =  string.valueOf(c.cllease__Original_Amount__c);
            r.taxAmount = string.valueOf(c.cllease__Tax_Due__c);
            Decimal total = c.cllease__Original_Amount__c + c.cllease__Tax_Due__c;
            r.totalAmount = string.valueOf(total);
            results.add(r);
        }

        Map<ID,cllease__Lease_account_Due_Details__c> billMap = new Map<ID,cllease__Lease_account_Due_Details__c>();

        List<cllease__Lease_account_Due_Details__c> bList = new List<cllease__Lease_account_Due_Details__c>();
        bList = [select Id
                ,cllease__Due_Type_Description__c
                from cllease__Lease_account_Due_Details__c
                where invoiced_In__c = :recordId
                ];
        for (cllease__Lease_account_Due_Details__c b:blist){
            billMap.put(b.id,b);

        }

        List<cllease__Due_Detail_Lines__c> eList = new List<cllease__Due_Detail_Lines__c>();
        eList = [select Id
                ,name
                ,cllease__bill__c
                ,cllease__contract_equipment__r.equipment_description1__c
                ,cllease__Tax_Due_Amount__c
                ,cllease__Rental_Due_Amount__c
                ,cllease__total_due_amount__c
                from cllease__Due_Detail_Lines__c
                where cllease__bill__c in :billMap.keySet()
                order by cllease__Contract_Equipment__r.Equipment_Description1__c
                ];


         for (cllease__Due_Detail_Lines__c e:eList){
            r = new resultLine();
            r.equipmentName = e.cllease__Contract_Equipment__r.Equipment_Description1__c;
            r.recordName = e.name;
            
            r.fee = billMap.get(e.cllease__bill__c).cllease__Due_Type_Description__c;

            r.feeAmount =  string.valueOf(e.cllease__Rental_Due_Amount__c);
            feeTotal = feeTotal + e.cllease__Rental_Due_Amount__c;
            r.taxAmount = string.valueOf(e.cllease__Tax_Due_Amount__c);
            taxTotal = taxTotal + e.cllease__Tax_Due_Amount__c;
            r.totalAmount = string.valueOf(e.cllease__total_due_amount__c);
            totalTotal = totalTotal + e.cllease__total_due_amount__c;
            system.debug('REsult is ' + r);
            results.add(r);
        }

        r = new resultLine();
        r.equipmentName = 'Totals';
        r.fee = '';
        r.feeAmount = string.valueOf(feeTotal);
        r.taxAmount = string.valueOf(taxTotal);
        r.totalAmount = string.valueOf(totalTotal);
        r.className = 'makeBold';
        results.add(r);
        
        return results;
    }

    /********************************************************************************************
   	* get new bills and charges
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static List<resultLine> getNewBillsAndCharges(String recordId){
        
         /* get original charges */

         List<cllease__charge__c> cList = new List<cllease__Charge__c>();
         cList = [select Id
                ,name
                ,cllease__Original_Amount__c
                ,cllease__Tax_Due__c
                ,cllease__Fee_Definition__r.name
                ,cllease__Contract_Equipment__r.Equipment_Description1__c
                from cllease__Charge__c
                where invoiced_In__c = :recordId
                order by cllease__Contract_Equipment__r.Equipment_Description1__c
                ];

        /* get billd */
        Map<ID,cllease__Lease_account_Due_Details__c> billMap = new Map<ID,cllease__Lease_account_Due_Details__c>();

        List<cllease__Lease_account_Due_Details__c> bList = new List<cllease__Lease_account_Due_Details__c>();
        bList = [select Id
                ,cllease__Due_Type_Description__c
                from cllease__Lease_account_Due_Details__c
                where invoiced_In__c = :recordId
                ];

        for (cllease__Lease_account_Due_Details__c b:blist){
            billMap.put(b.id,b);
        }

        List<cllease__Due_Detail_Lines__c> eList = new List<cllease__Due_Detail_Lines__c>();
        eList = [select Id
                ,name
                ,cllease__bill__c
                ,cllease__contract_equipment__r.equipment_description1__c
                ,cllease__Tax_Due_Amount__c
                ,cllease__Rental_Due_Amount__c
                ,cllease__total_due_amount__c
                from cllease__Due_Detail_Lines__c
                where cllease__bill__c in :billMap.keySet()
                order by cllease__Contract_Equipment__r.Equipment_Description1__c
                ];

        
        /* get adjustments */
        List<adjustment__c> aList = new List<adjustment__c>();
        aList = [select Id
                ,adjustment_type__c
                ,credit__c
                ,debit__c
                ,charge__c
                ,Charge__r.Name  
                ,Due_Detail_Line__r.Name  
                ,Due_Detail_Line__c
                ,tax_amount__c
                ,equipment__c
                from adjustment__c
                where invoice__c = :recordId
          ];
        
        Map<String,List<Adjustment__c>> adjMap = new Map<String,List<Adjustment__c>>();
        for (Adjustment__c a:aList){
            if (a.charge__c != null){
                List<Adjustment__c> tempList = new List<Adjustment__c>();

                if (adjMap.get(a.charge__c) == null){
                    templist.add(a);
                }
                else{
                    tempList = adjMap.get(a.charge__c);
                }
                adjMap.put(a.charge__c,tempList);
            }
            if (a.due_detail_line__c != null){
                List<Adjustment__c> tempList = new List<Adjustment__c>();

                if (adjMap.get(a.due_detail_line__c) == null){
                    templist.add(a);
                }
                else{
                    tempList = adjMap.get(a.due_detail_line__c);
                }
                adjMap.put(a.due_detail_line__c,tempList);
            }
        }

        /* now we have a map with all adjustments */

        resultLine  r = new resultLine();

        List<resultLine> results = new List<resultLine>();


        /* go through bills and adjust */
        for (cllease__Due_Detail_Lines__c e:elist){

            List<Adjustment__c> adjList = adjMap.get(e.id);  //list of adjustments to this bill
            Decimal amount = e.cllease__Rental_Due_Amount__c;
            Decimal tax = e.cllease__Tax_Due_Amount__c;
            Decimal total = e.cllease__total_due_amount__c;

            for (Adjustment__c adj:adjList){
                amount = amount - adj.credit__c;
                tax = tax - adj.tax_amount__c;
                total = total - amount - tax;
            }
            if (total > 0 ){
                r = new resultLine();
                r.equipmentName = e.cllease__contract_equipment__r.equipment_description1__c;
                r.fee = billMap.get(e.cllease__bill__c).cllease__Due_Type_Description__c;
                r.feeAmount = string.valueOf(amount);
                r.taxAmount = string.valueOf(tax);
                r.totalAmount = string.valueOf(total);
                results.add(r);
            }
        
        }
        /* go through charges and adjust */
             
        return results;
    }    

}