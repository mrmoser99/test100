trigger Int_OFAC_FINCEN on Int_OFAC_FINCEN__c (before update) {

    List<Int_OFAC_FINCEN__c> oDList = new List<Int_OFAC_FINCEN__c>();
    Map<ID,String> ofacMap = new Map<ID,String>();
    
    for (Int_OFAC_FINCEN__c o:trigger.new){
    	if (o.committed__c == true){
    		ofacMap.put(o.id,'delete');
    	}
    }
    
    if (!ofacMap.isEmpty())
    	newCoUtility.deleteOfacFINCEN(ofacMap); 
}