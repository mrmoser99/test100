global class ExecuteBridgerPasswordMaint implements Schedulable{ 

	global void execute(SchedulableContext SC){
		id batchinstanceid = database.executeBatch(new BatchBridgerPasswordMaint(),250);  
	}
  
}