
public with sharing class CustomPathDTO {
    public class ClosedStatus{
         @AuraEnabled public String value;
         @AuraEnabled public String label;
    }
    
    public class PathAssistantStep{
        @AuraEnabled public List<String> fieldNames;
        @AuraEnabled public String info;
        @AuraEnabled public String picklistValueName;
    }

    public class CustomPathContext
    {
        @AuraEnabled public Boolean active;
        @AuraEnabled public String entityName;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String masterLabel;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public String urls;
        @AuraEnabled public String currentStage;
        @AuraEnabled public String finalStage;
        @AuraEnabled public String closeFlow;
        @AuraEnabled public List<pathAssistantStep> pathAssistantSteps;
        @AuraEnabled public List<String> lostStages;
        @AuraEnabled public List<String> wonStages;
        @AuraEnabled public List<String> closedStatus;
        @AuraEnabled public List<String> nonClosedStatus;
        @AuraEnabled public List<String> lostReasons;
        @AuraEnabled public Map<String, Integer> stageDurations;
        
    }
}