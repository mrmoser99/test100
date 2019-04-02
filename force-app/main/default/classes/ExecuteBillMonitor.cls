global class ExecuteBillMonitor implements Schedulable{ 

	global void execute(SchedulableContext SC){
		id batchinstanceid = database.executeBatch(new BatchGenWatchBilling(),250); 
	}
  
}