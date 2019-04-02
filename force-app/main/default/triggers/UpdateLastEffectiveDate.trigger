trigger UpdateLastEffectiveDate on cllease__Insurance_Policy__c (After Update, After Insert) {
List<id> ContractIds=new List<Id>();
Map<id,Date> InsuranceMap = new Map<id,Date>();
for(cllease__Insurance_Policy__c Insp:Trigger.new){
//ContractIds.add(Insp.cllease__Contract__c);
InsuranceMap.put(Insp.cllease__Contract__c,Insp.cllease__Effective_To__c);}
 List<cllease__Lease_Account__c> updateContracts=new List<cllease__Lease_Account__c>();
 
  for(cllease__Lease_Account__c obj:[select id,Insurance_Effective_date__c from cllease__Lease_Account__c where id IN :InsuranceMap.Keyset() /*and cllease__Lease_Status__c<>'Partial Application'*/] ){
  obj.Insurance_Effective_date__c=InsuranceMap.get(obj.id);
  updateContracts.add(obj);
  }
  If(updateContracts.size()>0)
     Update updateContracts;


}