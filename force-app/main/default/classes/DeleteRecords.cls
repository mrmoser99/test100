/**
 * Author: Cloud Lending Solutions
 * DescriptionFollowing class helps in deleting records of specified query from org.
 * 
 **/
public class DeleteRecords implements Database.Batchable<SObject> {
    String query;
    public DeleteRecords(String querystr) {
        this.query = querystr;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, Sobject[] scope) {
        delete scope;
    }
    public void finish(Database.BatchableContext context) {
        
    }
}

/*

/////////////////////////////////// part-1///////////////////////////////////

List<String> queries = new List<String> {
    'select id from GL_Transaction_Detail__c',
    'select id from Lease_Payment_Detail__c',
    'select id from Lease_Payment_Transaction__c',
    'select id from Due_Detail_Lines__c',
    'select id from Lease_account_Due_Details__c',
    'select id from Lease_Trx_Lines__c',
    'select id from Lease_Trx_Header__c',
    'select id from Disbursement_Transaction__c',
    'select id from Charge__c',
    'select id from other_transaction__c',
    'select id from Payment_Stream__c',
    'select id from Rental_Stream__c',
    'select id from Residual_Stream__c',
    'select id from Fee_Stream__c',
    'select id from Initial_Direct_Cost_Stream__c',
    'select id from Rental_Accrual_Stream1__c',
    'select id from Dep_Streams__c',
    'select id from Subsidy_Stream__c',
    'select id from Cash_Account_Balance__c',
    'select id from Contract_Fees__c',
    'select id from Subsidy__c',
    'select id from Asset_Return__c',
    'select id from Insurance_Policy_Equipment__c',
    'select id from Insurance_Policy__c',
    'select id from Expense_Fees__c',
    'select id from Contract_Parties__c',
    'select id from Payment_Schedule__c'
};
// running batch job
DeleteRecords dr;
for(String query: queries) {
    dr = new DeleteRecords(query);
    Database.executeBatch(dr);
}

/////////////////////////////////// part-2///////////////////////////////////


String query;
DeleteRecords dr;

//// part-2
query = 'select id from Contract_Equipment__c';
dr = new DeleteRecords(query);
Database.executeBatch(dr, 90);
/// part-3 
query = 'select id from Lease_account__c';
dr = new DeleteRecords(query);
Database.executeBatch(dr);

*/