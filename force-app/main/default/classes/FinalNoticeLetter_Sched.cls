global class FinalNoticeLetter_Sched  implements Schedulable{
    private String sessionId;

    global FinalNoticeLetter_Sched(){
        this.sessionId = UserInfo.getSessionId();
    }
    //sessionId = UserInfo.getSessionId();
    global void execute(SchedulableContext sc) {

        //pass the session id to the class that call http and process the data in external apps
        FinalNoticeLetter fn = new FinalNoticeLetter(sessionId);
        DataBase.executeBatch(fn);
    }
}