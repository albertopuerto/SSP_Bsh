public with sharing class pathOpportunityFieldManager {
   
    @AuraEnabled 
   public static String  getObjectRecordTypes (String objectStep){

     List<String> listFields= new List<String>();
     listFields= objectStep.split(' ');
     for(Integer x=0; x< listFields.size(); x++){
          Schema.DescribeFieldResult f = Opportunity.listFields[x].getDescribe();
          Schema.sObjectType sourceType = f.getSObjectType();
          System.debug('sourceType ' +sourceType);
     }
     // use schema get describe class and write a wrapper with the response, with api field, value...
        return 'test';
        //opportunityWrapper = JSON.deserialize(currentOppRecordTypePath.Metadata, pathAssistantDTO.pathAssistantWrapper.class); 
        
   }
}