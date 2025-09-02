public with sharing class PathOpportunityFieldManager {
   
    @AuraEnabled 
   public static List<String>  getFieldList (String objectStep){

     List<String> listFields= new List<String>();
     listFields= objectStep.split(' ');
    
     // use schema get describe class and write a wrapper with the response, with api field, value...
        return listFields;
        //opportunityWrapper = JSON.deserialize(currentOppRecordTypePath.Metadata, pathAssistantDTO.pathAssistantWrapper.class); 
        
   }
}