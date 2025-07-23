
public with sharing class pathAssistantDTO {

    
    public class pathAssistantStep{
        @AuraEnabled public List<String> fieldNames;
        @AuraEnabled public String info;
        @AuraEnabled public String picklistValueName;
    }
    public class pathAssistantWrapper
    {
        @AuraEnabled public Boolean active;
        @AuraEnabled public String entityName;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String masterLabel;
        @AuraEnabled public List<pathAssistantStep> pathAssistantSteps;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public String urls;
    }


    public class pathAssistantFieldsWrapper
    {
        @AuraEnabled public String entityId;

    }
}