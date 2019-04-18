public with sharing class NewCoUtility2 {

	private static boolean alreadyUpdated = false;

	public static boolean hasAlreadyUpdated() {
        return alreadyUpdated; 
    } 
    public static void setAlreadyUpdated() {
        alreadyUpdated = true;
    }
}