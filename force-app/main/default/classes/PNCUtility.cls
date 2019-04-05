/*******************************************************************************************************************
*   PNC Utility
*       This class holds methods to peform functions with PNC Payer Express
* 
*	Change Log: 
*	4/4/19 - MRM Created
*
********************************************************************************************************************/
public with sharing class PNCUtility {
    
       
    /*************************************************************************************************
    * 
    * voidInvoice 
	*	
	* 
    *************************************************************************************************/
    public static boolean voidInvoice( ID invoiceId){    

        // create these lines for the invoice into the interface table, the job runs every 10 minutes so it will be picked up
         /*
        1|BILLDATA|PNC|3517|SUM|04132018|110039 
        RecordType|ReferenceNumber|OtherData|dtStatement|dtDue|BillerInvoiceNo|NameFirst|MiddleName|NameLast|CompanyName|Address|Address2|City|State|Zip|Phone|Fax|PreviousBalance|PaymentReceived|CurrentCharges|AmountDue|EmailAddress|FDICode|PmtTypeAllowed|BillStatus|MasterNumber|OpenField1|OpenField2|Message|CustomerCode|SalesTax|PurchaseID|DeliveryZip|Discount Amount|FreightShippingAmt|DutyAmt|ItemCommodityCode|ProductName|ProductCode|Quantity|UnitofMeasure|UnitCost|DiscPerLineItem|LineItemTotal|DisplayField1
        6|0000000419|0000000419|04/16/2018|05/11/2018|INV-0000000057||||THE EVANGELICAL LUTHERAN CHURCH OF THE REDEMPTION IN PHILADELPHIA|8001 Bustleton Ave||Philadelphia|PA|19152-2801||||||249.19|||CC;DEBIT;CREDIT|||||||||||||||||||||LES-0000000306
        9|1|249.19|0|0
        */
        List<Int_PX_Billing__c> bList = new List<Int_PX_Billing__c>();

        Int_PX_Billing__c b = new Int_PX_Billing__c();
        Datetime dt = DateTime.now();
        b.line_data__c = ' 1|BILLDATA|PNC|3517|SUM|' + dt.format('MMddyyyy') + '|' + dt.format('hhmmss');
        bList.add(b);

        b = new Int_PX_Billing__c();
        b.line_data__c = 'RecordType|ReferenceNumber|OtherData|dtStatement|dtDue|BillerInvoiceNo|NameFirst|MiddleName|NameLast|CompanyName|Address|Address2|City|State|Zip|Phone|Fax|PreviousBalance|PaymentReceived|CurrentCharges|AmountDue|EmailAddress|FDICode|PmtTypeAllowed|BillStatus|MasterNumber|OpenField1|OpenField2|Message|CustomerCode|SalesTax|PurchaseID|DeliveryZip|Discount Amount|FreightShippingAmt|DutyAmt|ItemCommodityCode|ProductName|ProductCode|Quantity|UnitofMeasure|UnitCost|DiscPerLineItem|LineItemTotal|DisplayField1';
        bList.add(b);

        Invoice__c i = [SELECT Balance_Amount__c
            ,Balance_Due_Amount__c
            ,Billed_Amount__c
            ,Bill_To_Account__c
            ,Charged_Amount__c
            ,Customer_Name__c
            ,Id
            ,LS_Contract__c
            ,LS_Contract__r.name
            ,Name
            ,Total_Amount_Due__c 
            FROM Invoice__c
            where id = :invoiceId
            ]; 

        Account a = [select account_number__c
                    ,name
                    from Account
                    where id = :i.bill_to_account__c
                    ];

        b = new Int_PX_Billing__c();
        
        b.line_data__c =               
            '6|' + 
            a.account_number__c + '|' + a.account_number__c + '|' + 
            dt.format('dd/MM/yyyy') + '|' + 
            dt.format('dd/MM/yyyy') + '|' + 
            i.name  + '|' + 
            '|' +
            '|' +
            '|' +
          
            a.name + '|' + 
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            string.valueOf(i.total_amount_due__c) +
            '|' +
            '|' +
            '|' +
            'CC;DEBIT;CREDIT' + '|' + 'Expired' + 
            '|' +
            '|' +
           
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            '|' +
            i.LS_Contract__r.name;
        bList.add(b);

        b = new Int_PX_Billing__c();
        
        b.line_data__c =  '9|1|' + string.valueOf(i.total_amount_due__c) + '|0|0';

        blist.add(b);

        insert bList;

        return true;

    }    
}
  		
