trigger Int_OFAC on Int_OFAC__c (after update) {
    
    List<Int_OFAC__c> oDList = new List<Int_OFAC__c>();
    Map<ID,String> ofacMap = new Map<ID,String>();
    
    for (Int_OFAC__c o:trigger.new){
    	if (o.committed__c == true){
    		ofacMap.put(o.id,'delete');
    	}
    }
    
    if (!ofacMap.isEmpty())
    	newCoUtility.deleteOfac(ofacMap);
}