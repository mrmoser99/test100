/**
 * Usage:  Following job helps in closing all earlier open periods and open the current system date period
 * 	CloseAccountingPeriodsJob job = new CloseAccountingPeriodsJob(DateToRun);
 * 	Database.executeBatch(job);
 *
 **/
global with sharing class CloseAccountingPeriodsJob extends clcommon.DynamicJob {

	private static String query;
	private static Date dateToRun;
	private static final String JOB_NAME = 'AUTOMATED ACCOUNTING PERIODS CLOSE AND OPEN JOB';

    
	global CloseAccountingPeriodsJob() {
        super(JOB_NAME, initialize());
    }
    
    global CloseAccountingPeriodsJob(Date dateToRunAccountingPeriod) {
        this();
        dateToRun = dateToRunAccountingPeriod;
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'CloseAccountingPeriodsJob query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize() {
    	
    	// Query all open periods to close and included "Closed status" to avoid jobs to kick
    	// in case of all periods are closed, no open periods available,. then job will not kicked and to avoid this situation, included "closed status"
    	query = ' SELECT Id, Name, cllease__Status__c 				'+
				' FROM cllease__Period_Status__c	  				'+
				' WHERE cllease__Status__c IN (\'Open\', \'Closed\') ';

        query += ' ORDER BY Name';
        
        System.debug(LoggingLevel.ERROR, 'CloseAccountingPeriodsJob query in initialize : ' + query);
        return query;

    }  

    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {

    	List<cllease__Period_Status__c> openPeriods = (List<cllease__Period_Status__c>) scope;
    	Savepoint sp = database.setsavepoint();        
        try {
    		// A. Close all Open Periodsperiods
			for(cllease__Period_Status__c openPeriod : openPeriods) {
				openPeriod.cllease__Status__c = 'Closed';
			}

			if(openPeriods.size() > 0) {
				update openPeriods;
			}

			// Setting current system date incase of date to run is null
    		Date currentSystemDate = (dateToRun != null ? dateToRun : cllease.SystemDateUtil.getCurrentSystemDate());

			
			System.debug(LoggingLevel.ERROR, ' --- open periods: '+openPeriods);
			System.debug(LoggingLevel.ERROR, ' --- current System date '+currentSystemDate);
    		// B. Open Current System date period
    		List<cllease__Period_Status__c> toBeOpenPeriods = [SELECT Id, Name, cllease__Status__c
																FROM cllease__Period_Status__c
																WHERE cllease__Start_Date__c <= :currentSystemDate
																	AND cllease__End_Date__c >= :currentSystemDate];

			System.debug(LoggingLevel.ERROR, ' --- toBeOpenPeriods: '+toBeOpenPeriods);
    		
			for(cllease__Period_Status__c periodToOpen : toBeOpenPeriods) {
				periodToOpen.cllease__Status__c = 'Open';
			}

			if(toBeOpenPeriods.size() > 0) {
				update toBeOpenPeriods;
			}	

        } catch(exception e){           
            database.rollback(sp);           
            System.debug(LoggingLevel.ERROR, 'Exception while processing CloseAccountingPeriodsJob: '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception StackTrace: '+e.getStackTraceString());
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name='CloseAccountingPeriodsJob ', cllease__Date__c = system.today(), 
            	cllease__Message__c='Error is '+ e.getmessage() +' in line number: '+ e.getlinenumber());
       }
    }   

    public override void doInitialize() { }
    public override void doStart(Database.BatchableContext bc) { }   
    public override void doFinish(Database.BatchableContext bc) { }       	                                       
     
}