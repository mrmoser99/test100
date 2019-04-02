public class ContractTerminationController {
    
    public boolean termqheader1 = false; 
    public static void contractTermination(set<String> ContractRollOverQuoteIds){
        set<String> contractids = new set<String>();
        Set<String> Equipmentids = new Set<String>();
        Set<cllease__Termination_Quote_Header__c> termintionqheaaderlist = new Set<cllease__Termination_Quote_Header__c>();
        List<cllease__Termination_Quote_Header__c> Terminationquotelist = [select id,cllease__Status__c,cllease__Quote_Amount__c,cllease__Contract__c from cllease__Termination_Quote_Header__c where id in :ContractRollOverQuoteIds];
		termintionqheaaderlist.addAll(Terminationquotelist);
        String ContracId ;
        For(cllease__Termination_Quote_Header__c ctq:Terminationquotelist){
            ContracId=ctq.cllease__Contract__c;
        }
		contractids.add(ContracId);
        List<cllease__Contract_Equipment__c> units = new List<cllease__Contract_Equipment__c>();
        units = [select id from cllease__Contract_Equipment__c where cllease__Contract__c =:ContracId];
        for(cllease__Contract_Equipment__c u:units){
            Equipmentids.add(u.id);
        }
        System.debug('Listttttttttttttof Contrcatids'+contractids);
        System.debug('Listttttttttttttof equipmentids'+Equipmentids);
        Boolean isEquipmentLevelTermination=true;
        cllease.TerminationQuoteActionCtrl tqac = new cllease.TerminationQuoteActionCtrl();
        //tqac.processTermination(contractIds, equipmentIds);
       // cllease.TerminationQuoteActionCtrl.processTermination(contractids,Equipmentids,isEquipmentLevelTermination);
        
}
}