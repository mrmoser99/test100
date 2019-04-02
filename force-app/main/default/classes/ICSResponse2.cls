/*******************************************************************************************************************
*   This ICSReponse service is used to process the results of the call to ICS.
*	ICS will call this service asyncrhonously with the results of the ICS credit check.
*   There are two reserved words that could not be mapped to xml:  Id and Default....The caller must change these to Id_x and 
*	Default_x;
*
*	Change Log:
*	8/9/18 	- MRM Created
*   8/10/18 - MRM Added database logic to store response results
*   9/5/18 	- MRM added more repsonse storage....
*
********************************************************************************************************************/
global class ICSResponse2 {
	
	/* Define the structure to hold the response from ICS */
	
	global class sayHello {
	
		webservice string firstName;
		webservice string lastName;	 
	}
	
	
	
	/*******************************************************************************************************************
	*	SUBMIT ICS RESPONSE   
	*	This is the main call. Results of the ICS Response are stored in the database 
	*   The quick quote credit status will be updated as a result of this call.
	********************************************************************************************************************/
  
   	webService static string SubmitICSResponse(sayHello sayHello){
   		
   		system.debug(sayHello);
   		return 'OK';
		
   	}	
}