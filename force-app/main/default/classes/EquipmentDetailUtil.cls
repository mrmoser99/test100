/**
 * Description: Following Util class helps in processing any operations related to Equipment Detail Object (clcommon)
 *
 **/
public with sharing class EquipmentDetailUtil {	

	public static String nsPrefix = 'cllease__';

	/**
	 * Following method helps in Retrieving Equipment Details from Contract Equipment Ids.
	 * @params: Set of Contract Equipment Ids
	 **/
	public static List<clcommon__Equipment_Detail__c> getEquipmentDetails(Set<String> recordIds, Boolean isEquipmentIds) {
		
		// Creating Dynamic query for Equipment Detail object using ExecutionContext
		try {
			
			String eqpDetailFields = fetchAllCustomFields('clcommon__Equipment_Detail__c');
        	//String nsPrefix = CustomSettingsUtil.getNSWithUnderScore();
        	String eqpDetailsContractEqpField = nsPrefix + 'Contract_Equipment__c';

       	 	// Creating Dynamic query for Equipment Detail object
        	String query = ' SELECT '+ eqpDetailFields +
	                        ' FROM clcommon__Equipment_Detail__c ';

	        if(isEquipmentIds) {
	        	query += ' WHERE '+ eqpDetailsContractEqpField +' IN :recordIds ';
	        } else {
	        	query += ' WHERE Id IN :recordIds ';
	        }

	        query += ' ORDER BY Name';

	        System.debug(LoggingLevel.DEBUG, ' Equipment Detail Query: '+query);
	        return Database.query(query);

		} catch(Exception e) {
			throw new CLSCustomException('Exception during Querying Equipment Details: '+e.getMessage()); 
		}
	}

	/**
	 *	Following method helps in creating the Equipment to Equipment Details field mapping
	 **/
	public static Map<String, String> getEqptoEqpDetailFieldMap() {

		Map<String, String> eqpDetailFieldByEqpField = new Map<String, String>();

		try {
			String contractEquipmentObjectAPIName 	= nsPrefix + 'Contract_Equipment__c';
        	String eqpDetailObjectAPIName 			= 'clcommon__Equipment_Detail__c';        	

        	// Extracting field for Contract Equipment and Equipment Details for field type check
        	Map<String, FieldProperties> contractEqpFieldProperties 	= getObjectFieldProperties(contractEquipmentObjectAPIName);
        	Map<String, FieldProperties> eqpDetailFieldProperties 		= getObjectFieldProperties(eqpDetailObjectAPIName);

        	System.debug(LoggingLevel.DEBUG, 'contractEqpFieldProperties key: '+contractEqpFieldProperties.keySet());
        	System.debug(LoggingLevel.DEBUG, 'eqpDetailFieldProperties key: '+eqpDetailFieldProperties.keySet());

        	// Extracting Contract Equipment to Equipment detial mapping from HQ branch attached to User using BranchUtil
			cllease__Office_Name__c hqBranch = cllease.BranchUtil.getBranch();
			String branchId = hqBranch.Id;
			System.debug(LoggingLevel.DEBUG, 'Current Branch: '+hqBranch);
			cllease__Office_Name__c retBranch = [SELECT Name, Id,
                                   cllease__Mark_Suspended_After_Days__c,
                                   cllease__Write_Off_Suggestion_Days__c,
                                   cllease__Parent_Office__c,
                                   cllease__Current_System_Date__c,
                                   cllease__Equipment_To_Equipment_Detail_Mapping__c
                                   FROM cllease__Office_Name__c
                                   WHERE Id = :branchId];

			if(retBranch.cllease__Equipment_To_Equipment_Detail_Mapping__c == null) {
				throw new CLSCustomException('Missing Equipment to Equipment Details mapping from Company Setup'); 
			}

			String jsonStr = retBranch.cllease__Equipment_To_Equipment_Detail_Mapping__c;
			List<EqpToEqpDetailMapping> eqpDetailToEqpMapping = (List<EqpToEqpDetailMapping>)JSON.deserialize(jsonStr, List<EqpToEqpDetailMapping>.class);

			// Looping over all Equipment to Equipment Detail mapping for map creation
			for(EqpToEqpDetailMapping mapping : eqpDetailToEqpMapping){
				// Skipping the Map creation for Fields in case any mapping has null value
				if(mapping.eqpFieldAPIName == null || mapping.eqpDetailFieldAPIName == null) {
					continue;
				}
				String equipmentFieldName = mapping.eqpFieldAPIName.toLowerCase();
				String eqpDetailFieldName = mapping.eqpDetailFieldAPIName.toLowerCase();

				System.debug(LoggingLevel.DEBUG, 'Equipment FieldAPI Name: '+contractEqpFieldProperties.get(equipmentFieldName));
				System.debug(LoggingLevel.DEBUG, 'Equipment Detail FieldAPI Name: '+eqpDetailFieldProperties.get(eqpDetailFieldName));

				// Mapped fields should be Currency, Decimal or Integer for Rollup Calculations from Equipment Details to Contract Equipments
				if( (String.valueOf(contractEqpFieldProperties.get(equipmentFieldName).type).equalsIgnoreCase('CURRENCY')
						&& (contractEqpFieldProperties.get(equipmentFieldName).type == eqpDetailFieldProperties.get(eqpDetailFieldName).type))
					|| (String.valueOf(contractEqpFieldProperties.get(equipmentFieldName).type).equalsIgnoreCase('DOUBLE')
						&& (contractEqpFieldProperties.get(equipmentFieldName).type == eqpDetailFieldProperties.get(eqpDetailFieldName).type))
					|| (String.valueOf(contractEqpFieldProperties.get(equipmentFieldName).type).equalsIgnoreCase('INTEGER')
						&& (contractEqpFieldProperties.get(equipmentFieldName).type == eqpDetailFieldProperties.get(eqpDetailFieldName).type)) ) {
					
					// Adding mapping fields to map only if field types are matching and types are Curency, Double or Integer 
					eqpDetailFieldByEqpField.put(equipmentFieldName, eqpDetailFieldName);
				}
        	} 

        	System.debug(LoggingLevel.DEBUG, 'eqpDetailFieldByEqpField : '+eqpDetailFieldByEqpField);
        	// Returning created Equipment to Equipment Detail Map
        	return eqpDetailFieldByEqpField;
    	
		} catch(Exception e) {
			throw new CLSCustomException('Exception during Equipment to Equipment Details Creation: '+e.getMessage()); 
		} 		
	}

	/** 
	 * Following Utility to get all Equipment Details from specified Contracts 
	 **/
	public static Map<Id, Map<Id, clcommon__Equipment_Detail__c>> getEquipmentDetailsMapForContracts(Set<String> contracts, Set<String> statusList) {

		Map<Id, Map<Id, clcommon__Equipment_Detail__c>> contractEqpDetailsMap = new Map<Id, Map<Id, clcommon__Equipment_Detail__c>>();
		Map<Id, Id> contractEqpToContractMap = new Map<Id, Id>();

		try {
			// 1. Querying contract details with Contract Equipments with Non Terminated Contracts
			// Initializing ExecutionContext Object for dynamic query creation.
	        List<cllease__Contract_Equipment__c> equipmentList = [SELECT Id, cllease__Contract__c
				                                         FROM cllease__Contract_Equipment__c
				                                         WHERE cllease__Contract__c IN :contracts
				                                            AND cllease__Status__c IN :statusList];

			if(equipmentList.size() == 0) {
				throw new CLSCustomException('Contracts doesn\'t has any Contract Equipments to retrive for processing.');
			}

			// Processing Contract Equipments for querying Equipment Details
			Set<String> equipmentIds = new Set<String>();
			for(cllease__Contract_Equipment__c equipment: equipmentList) {
				contractEqpToContractMap.put(equipment.Id, equipment.cllease__Contract__c);
				equipmentIds.add(equipment.Id);
			}

			//
			List<clcommon__Equipment_Detail__c> eqpDetailList = getEquipmentDetails(equipmentIds, true);

			for(clcommon__Equipment_Detail__c eqpDetail : eqpDetailList) {
				if(statusList.contains(eqpDetail.clcommon__Status__c)) {
					Id contractId = contractEqpToContractMap.get(eqpDetail.cllease__Contract_Equipment__c);
					Map<Id, clcommon__Equipment_Detail__c> tempMap = contractEqpDetailsMap.get(contractId);
					if(tempMap == null) {
						tempMap = new Map<Id, clcommon__Equipment_Detail__c>();
					}
					tempMap.put(eqpDetail.Id, eqpDetail);
					contractEqpDetailsMap.put(contractId, tempMap);
				}				
			}

			return contractEqpDetailsMap;

		} catch(Exception e) {
			throw new CLSCustomException('Exception during Equipment to Equipment Details Creation: '+e.getMessage()); 
		}
	}

	/**
	 * Following method helps in creating default custom metadata types
	 **/
	public static void createEquipmentCustomMetadataTypes() {

		Map<String, String> eqpToEqpDetailMap = new Map<String, String>{
			nsPrefix + 'Dealer_Fees__c'				=> 'clcommon__Dealer_Fees__c' ,
			nsPrefix + 'Estimated_Selling_Price__c'	=> 'clcommon__Estimated_Selling_Price__c' ,
			nsPrefix + 'Other_Financed_Fees__c'		=> 'clcommon__Other_Financed_Fees__c' ,
			nsPrefix + 'Residual_Amount__c'			=> 'clcommon__Residual_Amount__c' ,
			nsPrefix + 'Subvention__c'				=> 'clcommon__Subvention__c' ,
			nsPrefix + 'Subsidy__c'					=> 'clcommon__Subsidy__c'
		};

		List<EqpToEqpDetailMapping> mappings = new List<EqpToEqpDetailMapping>();
		EqpToEqpDetailMapping eqpMapping;
		for(String fieldKey : eqpToEqpDetailMap.keySet()) {
			eqpMapping = new EqpToEqpDetailMapping(fieldKey, eqpToEqpDetailMap.get(fieldKey));
			mappings.add(eqpMapping);
		}

		String eqpMappingStr = JSON.serialize(mappings);

		// Inserting the mapping only to HQ Company
		List<cllease__Office_Name__c> branches = [SELECT Id, Name, cllease__Equipment_To_Equipment_Detail_Mapping__c 
										FROM cllease__Office_Name__c];

		for(cllease__Office_Name__c branch : branches) {
			branch.cllease__Equipment_To_Equipment_Detail_Mapping__c = eqpMappingStr;
		}
		update branches;
		System.debug(LoggingLevel.ERROR, 'after Updating company for mapping: '+branches);
	}

	public static String fetchAllCustomFields(String type) {
        String nameSpace =  nsPrefix;
        //system.debug(logginglevel.ERROR, '### namespace from commonUtil: '+nameSpace);
        boolean nameSpaceExists = false;
        if ((nameSpace != null)
                && ((nameSpace.length() > 0))) {
            nameSpaceExists = true;
        }
        String newType;
        if (nameSpace != null && nameSpace.contains('__'))
            newType = (nameSpaceExists) ? nameSpace + type : type;
        else
            newType = (nameSpaceExists) ? nameSpace + '__' + type : type;
        //system.debug(logginglevel.ERROR, '#### newType: '+newType);
        Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(newType);
        Map<String, Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();
        //because I always want name and ID to be selected
        String fields = ' Name, Id , ';
        for (String key : fieldsMap.keySet()) {
            if (key.endsWith('__c')) {
                /*String startsWithStr = String.valueof(fieldsMap.get(key));
                if (nameSpaceExists) {
                    if  (startsWithstr.startsWith(nameSpace)) {
                        //fields = fields + key + ',';
                        fields = fields + startsWithstr.remove(namespace) + ',';
                    }
                } else {*/
                
                fields = fields + key + ',';
                //}
            }
        }
        if (fields.endsWith(',')) {
            fields = fields.substring(0, fields.length() - 1);
        }
        //system.debug(logginglevel.ERROR, '#### after fields: '+fields);
        return fields;
    }

    public static Map<String, FieldProperties> getObjectFieldProperties(String objName) {
        Map<String, FieldProperties> allFields = new Map<String, FieldProperties>();

        if (objName == null || String.isEmpty(objName)) {
            return allFields;
        }

        // Make the describe call
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[] {objName});
        Map<String, Schema.SobjectField> fieldsMap = results[0].fields.getMap();

        for (String f : fieldsMap.keySet()) {
            FieldProperties fP = new FieldProperties();

            Schema.DescribeFieldResult obj = fieldsMap.get(f).getDescribe();

            String name = obj.getName().toLowerCase();

            fP.name = name;
            fP.label = obj.getLabel();
            fP.type = obj.getType();
            fP.isAutoNumber = obj.isAutoNumber();
            fP.isCalculated = obj.isCalculated();
            fP.isCustom = obj.isCustom();
            fP.isAccessible = obj.isAccessible();

            Integer relationshipOrder = obj.getRelationshipOrder();
            fP.isParentLink = (relationshipOrder != null && relationshipOrder == 0) ? true : false;

            List<sObjectType> targetSObjects = obj.getReferenceTo();

            if (targetSObjects.size() > 0) {
                fP.isLookup = true;

                fP.lookupObject = targetSObjects.get(0);
            } else {
                fP.isLookup = false;

                fP.lookupObject = null;
            }

            allFields.put(fP.name, fP);
        }

        return allFields;
    }


    public class FieldProperties {
        public String name;
        public String label;
        public Schema.DisplayType type;
        public boolean isAutoNumber;
        public boolean isCalculated;
        public boolean isCustom;
        public boolean isLookup;
        public sObjectType lookupObject;
        public boolean isAccessible;
        public boolean isParentLink;

        public FieldProperties() {
        }

        public override String toString() {
            return 'Name: ' + name + ', ' +
                   'Label: ' + label + ', ' +
                   'Type: ' + type + ', ' +
                   'Auto Number?: ' + isAutoNumber + ', ' +
                   'Calculated?: ' + isCalculated + ', ' +
                   'Custom?: ' + isCustom + ', ' +
                   'Lookup?: ' + isLookup + ', ' +
                   'Accessible?: ' + isAccessible + ', ' +
                   'Parent Link?: ' + isParentLink;
        }
    }


	/**
	 * Following class helps in serialize and deserialize the Equipment to Equipment Mapping json objects
	 **/
	class EqpToEqpDetailMapping {
		public String eqpFieldAPIName;
		public String eqpDetailFieldAPIName;
		public EqpToEqpDetailMapping(String eqpFieldAPIName, String eqpDetailFieldAPIName) {
			this.eqpFieldAPIName = eqpFieldAPIName;
			this.eqpDetailFieldAPIName = eqpDetailFieldAPIName;
		}
	}

}