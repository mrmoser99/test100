public class CreatePermissionsBatchJob implements Database.Batchable<String> {
    public Map < String, String > returnMap;
    public CreatePermissionsBatchJob() {
        returnMap = new Map < String, String > ();
        returnMap = permissionsets();
    }


    public Map < String, String > permissionsets() {
        Map < String, String > returnMap = new Map < String, String > ();
        returnMap.put('Originate_Configuration_R', 'Originate_Configuration');
        returnMap.put('Originate_Configuration_RCE', 'Originate_Configuration');
        returnMap.put('Originate_Transaction_R', 'Originate_Transaction');
        returnMap.put('Originate_Transaction_RCE', 'Originate_Transaction');

        returnMap.put('Lease_Configuration_R', 'Lease_Configuration');
        returnMap.put('Lease_Configuration_RCE', 'Lease_Configuration');
        returnMap.put('Lease_Transaction_R', 'Lease_Transaction');
        returnMap.put('Lease_Transaction_RCE', 'Lease_Transaction');

        returnMap.put('Collection_Configuration_R', 'Collection_Configuration');
        returnMap.put('Collection_Configuration_RCE', 'Collection_Configuration');
        returnMap.put('Collection_Transaction_R', 'Collection_Transaction');
        returnMap.put('Collection_Transaction_RCE', 'Collection_Transaction');

        returnMap.put('ClCommon_Configuration_R', 'ClCommon_Configuration');
        returnMap.put('ClCommon_Configuration_RCE', 'ClCommon_Configuration');
        returnMap.put('ClCommon_Transaction_R', 'ClCommon_Transaction');
        returnMap.put('ClCommon_Transaction_RCE', 'ClCommon_Transaction');

        return returnMap;
    }

    public Iterable < string > start(Database.BatchableContext BC) {
        List < String > returnList = new List < String > ();
        returnList.addAll(returnMap.keyset());
        return returnList;
    }


    public void execute(Database.BatchableContext info, List < String > scopeList) {
        try {
            system.debug('===============returnMap=========' + returnMap);
            system.debug('===============scopeList=========' + scopeList);
            List < String > sObjList = new List < String > ();
            String psName = scopeList.get(0);
            system.debug('===============psName=========' + psName);
            String staticResourceName = returnMap.get(psName);
            system.debug('===============staticResourceName=========' + staticResourceName);

            StaticResource sr = [Select Id, Name, body from StaticResource where Name = : staticResourceName];
            sObjList.addAll(sr.body.toString().Split(';'));
            system.debug('===============sObjList=========' + sObjList);
            system.debug('===============sObjList size=========' + sObjList.size());
            PermissionSetCreator psc = new PermissionSetCreator(psName);
            if (psName.endswith('RCE')) {
              psc.RCEPermissionsWithFields(sObjList);

            } else {
              psc.ReadOnlyPermissionsWithFields(sObjList);

            }
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());            
            
        }
        
    }

    public void finish(Database.BatchableContext info) { }

}