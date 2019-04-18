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