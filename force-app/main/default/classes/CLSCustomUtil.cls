/**
 *  Author: Cloud Lending Solutions
 *  Description: CLS Utilies for reusable code.
 *
 **/
public with sharing class CLSCustomUtil {
	/**
	 * Utillity to pull all fields for a object
	 * @param: ObjectAPIName
	 * @return: object fields API Names separated with comma (,)
	 */

	public static String fetchObjectFields(String objectName) {
		Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
		Map<String, Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();
		String fields = 'Id, Name, ';
		for (String key : fieldsMap.keySet()) {
			if (key.endsWith('__c')) {
				fields = fields + fieldsMap.get(key).getDescribe().getName() + ',';
			}
		}
		if (fields.endsWith(',')) {
			fields = fields.substring(0, fields.length() - 1);
		}
		return fields;
	}

	/**
	 * Internal helper for converting Set<Id> to String with comma ()
	 */
	public static String getStringFromIds(Set<Id> objectIds) {
		System.debug(LoggingLevel.ERROR, '---received IDs: '+objectIds);
		String objectIdstr = '';
		if(objectIds == null || objectIds.size() == 0) {
			return objectIdstr;
		}
		for (Id branchId : objectIds) {
			objectIdstr = objectIdstr + '\'' + String.escapeSingleQuotes(branchId) + '\'' + ',';
		}
		objectIdstr = objectIdstr + '\'\'';
		return objectIdstr;
	}

	/**
	 * Internal helper for converting Set<Id> to String with comma ()
	 */
	public static String getStringsFromList(List<String> objectNames) {
		System.debug(LoggingLevel.ERROR, '---received IDs: '+objectNames);
		String objectNamestr = '';
		if(objectNames == null || objectNames.size() == 0) {
			return objectNamestr;
		}
		for (String branchId : objectNames) {
			objectNamestr = objectNamestr + '\'' + String.escapeSingleQuotes(branchId) + '\'' + ',';
		}
		objectNamestr = objectNamestr + '\'\'';
		return objectNamestr;
	}

	/**
	 * Get the Vertex Custom Settings
	 **/
	public static VertexApi__c getVertexConfiguration() {
		VertexApi__c vertexParams = VertexApi__c.getInstance();
        if (vertexParams == null) {
            vertexParams = VertexApi__c.getOrgDefaults(); // defaulting
        }
        return vertexParams;
	}
}