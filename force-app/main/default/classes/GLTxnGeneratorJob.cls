global class GLTxnGeneratorJob extends cllease.GLTransactionGeneratorJob {
    global GLTxnGeneratorJob() {
        super();
    }

    global GLTxnGeneratorJob(Date sodDate, String query) {
        super(sodDate, query);
    }

    global GLTxnGeneratorJob(Date sodDate, Set<Id> branchIds, Set<Id> contractIds) {
        super(sodDate, branchIds, contractIds);
    }

    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
        Set<Id> contractIds = new Set<Id>();

       for(SObject s : scope){
           contractIds.add(s.id);
       }
       GLTxnGeneratorHandler glEntries = new GLTxnGeneratorHandler(contractIds, this.sodDate);
       glEntries.process();
    }
}