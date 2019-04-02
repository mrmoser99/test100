/*********************************************************************************************
*	This executes the batchexposurecalc process; keep batch size to 5 or less
*
* ChangeLog:
*
*	6/1/18 - MRM Created Class
*
************************************************************************************************/
global class ExecuteExposureCalc implements Schedulable{ 

	global void execute(SchedulableContext SC){
		id batchinstanceid = database.executeBatch(new BatchExposureCalc(),5); 
	}
  
}