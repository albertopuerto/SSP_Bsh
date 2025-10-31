public class CustomPath {

    @AuraEnabled
    public static CustomPathDTO.CustomPathContext getContext(Id recordId){
        try {
            Logger.debug('Getting context for recordId: ' + recordId);
            CustomPathDTO.CustomPathContext context = new CustomPathDTO.CustomPathContext();
            if (recordId != null) {
                // get object from recordId
                String objName = recordId.getSObjectType().getDescribe().getName();

                // Get Record, first time to retrieve record type
                SObject currentObj;
                String recordType = '';
                try {
                    String sQuery = 'SELECT Id, recordType.DeveloperName FROM '+objName+' WHERE Id =: recordId LIMIT 1';
                    currentObj = Database.query(String.escapeSingleQuotes(sQuery));
                    recordType = (String) currentObj.getSObject('RecordType').get('DeveloperName');
                } catch (Exception e) {
                    // Object does not have record types, not an error. Set record type to Master and continue
                    recordType = 'Master';
                }

                // Get the path settings for the current recordtype
                String keyField= objName + '_' + recordType;
                cs_CustomPathConfig__mdt pathSettings = getPathSettings(keyField);
                context = getConfig(pathSettings.metadataPath__c);
                context.closeFlow = pathSettings.closeFlow__c;
                context.finalStage = pathSettings.finalStage__c;
                
                // Get the current stage from the record
                String fieldName = context.fieldName;
                String sQuery = 'SELECT Id, '+fieldName+' FROM '+objName+' WHERE Id =: recordId LIMIT 1';
                currentObj = Database.query(String.escapeSingleQuotes(sQuery));
                context.currentStage = (String) currentObj.get(fieldName);

                // Get the lost and won stages from custom metadata
                Map<String, Object> closedStagesMap = (Map<String, Object>) JSON.deserializeUntyped(pathSettings.closed_Stages__c);
                context.lostStages = parseListObject ((List<Object>) closedStagesMap.get('Losts'));
                context.wonStages = parseListObject ((List<Object>) closedStagesMap.get('Wons'));

                // Get the stage durations from  History -- History objects may differ between standard and custom objects (i.e. opportunity and other standard objects)
                if (objName == 'Opportunity') {
                    Logger.debug('Getting stage durations for Opportunity');
                    context.stageDurations = getStagesDuration(recordId, objName, fieldName);
                }

                // Get the closed and non closed status values from the  StageName picklist
                List<String> closedStatus = new List<String>();
                List<String> nonClosedStatus = new List<String>();
                Schema.DescribeFieldResult fieldResult = currentObj.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                Logger.debug('Picklist entries retrieved: ' + JSON.serialize(ple));
                for( Schema.PicklistEntry pValue : ple){
                    if (pValue.isActive() && (context.lostStages.contains(pValue.getLabel()) || context.wonStages.contains(pValue.getLabel()))) {
                        closedStatus.add(pValue.getLabel());          
                    }           
                    else if (pValue.isActive()){
                        nonClosedStatus.add(pValue.getLabel());
                    }
                }
                context.closedStatus = closedStatus;
                context.nonClosedStatus = nonClosedStatus;
            }
            Logger.debug('Context retrieved: ' + JSON.serialize(context));
            return context;
            
        } catch (Exception e) {
            Logger.error('Error in getContext: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateStage(String value, Id recordId, String objName, String fieldName){
        Logger.debug('Updating object ' + objName + ' field ' + fieldName + ' to ' + value + ' for recordId: ' + recordId);
        try {
            String sQuery = 'SELECT Id, '+fieldName+' FROM '+objName+' WHERE Id =: recordId LIMIT 1';
            SObject currentObj = Database.query(String.escapeSingleQuotes(sQuery));
            currentObj.put(fieldName, value);
            update AS USER currentObj;
            Logger.debug('Record updated successfully.');
        } catch (Exception e) {
            Logger.error('Error in updateStage: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static cs_CustomPathConfig__mdt getPathSettings(String keyField){
        Logger.debug('Retrieving path settings for key field: ' + keyField);
        cs_CustomPathConfig__mdt pathSettings = new cs_CustomPathConfig__mdt();

        try{
            pathSettings = [SELECT metadataPath__c, closed_Stages__c, closeFlow__c, finalStage__c FROM cs_CustomPathConfig__mdt WHERE key_field__c=: keyField WITH SYSTEM_MODE];
        }catch(QueryException e){
            Logger.error('No path configuration found for key field: ' + keyField);
            return null;
        }   
        Logger.debug('Path settings retrieved: ' + JSON.serialize(pathSettings));
        return pathSettings;
    }

    private static CustomPathDTO.CustomPathContext getConfig (String metadata){
        Logger.debug('Deserializing metadata: ' + metadata);
        CustomPathDTO.CustomPathContext context = (CustomPathDTO.CustomPathContext) JSON.deserialize(metadata, CustomPathDTO.CustomPathContext.class);
        Logger.debug('Deserialized context: ' + JSON.serialize(context));
        return context;
    }

    private static List<String> parseListObject (List<Object> objList){
        Logger.debug('Parsing list of objects: ' + JSON.serialize(objList));
        List<String> strList= new List<String>();
        for(Object obj: objList){
            strList.add((String) obj);
        }
        Logger.debug('Parsed list of strings: ' + JSON.serialize(strList));
        return strList;
    }

    private static Map<string, integer> getStagesDuration (Id recordId, String objName, String stageName){
        Logger.debug('Retrieving stage durations for recordId: ' + recordId + ' and object: ' + objName);
        String objHistory = objName + 'History';
        String parentField = objName + 'Id';
        if (objName.endsWith('__c')){
            objHistory = objName.replace('__c', '__History');
            parentField = 'ParentId';
        }
        String sQuery = 'SELECT '+stageName+', CreatedDate FROM '+objHistory+' WHERE '+parentField+' =: recordId ORDER BY CreatedDate ASC';
        Logger.debug('Querying history: ' + sQuery);
        List<SObject> history = Database.query(String.escapeSingleQuotes(sQuery));

        Map<String, Integer> stageDurations = new Map<String, Integer>();
        for (Integer i = 0; i < history.size(); i++) {
            String stage = (String)history[i].get(stageName);
            Date startDate = ((DateTime)history[i].get('CreatedDate')).date();
            Date endDate = (i + 1 < history.size()) ? ((DateTime)history[i + 1].get('CreatedDate')).date() : Date.today();

            Integer days = startDate.daysBetween(endDate);
            Integer addDays = stageDurations.containsKey(stage) ? stageDurations.get(stage) : 0;
            stageDurations.put(stage, addDays + days);
        }
        Logger.debug('Stage durations calculated: ' + JSON.serialize(stageDurations));
        return stageDurations;
    }

}