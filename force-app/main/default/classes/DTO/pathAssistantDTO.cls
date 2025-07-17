public with sharing class pathAssistantDTO {

    public class pathAssistantStep{
        public List<String> fieldNames;
        public String info;
        public String picklistValueName;
    }
    public class pathAssistantWrapper
    {
        public Boolean active;
        public String entityName;
        public String fieldName;
        public String masterLabel;
        public List<pathAssistantStep> pathAssistantSteps;
        public String recordTypeName;
        public String urls;
    }
}