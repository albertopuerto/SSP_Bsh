public class pathOpportunity {
@AuraEnabled
   public static List<String>  getNonClosedStatusValues(){
       List<String> statusList= new List<String>();
       Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry pValue : ple){
           if (pValue.isActive() && pValue.getLabel() !='Won (Awarded)' && pValue.getLabel() !='Lost' && pValue.getLabel() !='Project Cancelled' && pValue.getLabel() !='Invalid Data') {
               statusList.add(pValue.getLabel());
               
           }
           
       }
       statusList.add('Closed');
       return statusList;
   }

@AuraEnabled 
   public static String  getOpportunityActualStage(String opportunityId){
        Opportunity currentOpp = [SELECT StageName from Opportunity where Id=: opportunityId];
        

        //opportunityWrapper = JSON.deserialize(currentOppRecordTypePath.Metadata, pathAssistantDTO.pathAssistantWrapper.class); 
        return currentOpp.StageName;
   }

@AuraEnabled
   public static List<String>  getClosedStatusValues(){
       List<String> statusList= new List<String>();
       Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry pValue : ple){
           if (pValue.isActive() && (pValue.getLabel() =='Won (Awarded)' || pValue.getLabel() =='Lost' || pValue.getLabel() !='Project Cancelled' || pValue.getLabel() !='Invalid Data')) {
               statusList.add(pValue.getLabel());          
           }
           
       }
       return statusList;
   }

@AuraEnabled 
   public static pathAssistantDTO.pathAssistantStep  getOpportunityFields(String opportunityId,String newStage){
    //CAda vez que se cambia la etapa, traer los campos asociados a esa etapa. Volvemos a consultar la oportunidad y la metadata
    //la metadata da igual porque es un custom metadata que se cachea
        pathAssistantDTO.pathAssistantWrapper opportunityWrapper = new pathAssistantDTO.pathAssistantWrapper ();
        Opportunity currentOpp = [SELECT Id,StageName,recordType.DeveloperName from Opportunity where Id=: opportunityId];
        String keyField= 'Opportunity'+currentOpp.recordType.DeveloperName;

        Opportunity_Path_Info__mdt PathSettings = new Opportunity_Path_Info__mdt();
        try{
            PathSettings = [SELECT metadataPath__c from Opportunity_Path_Info__mdt where key_field__c=: keyField];
        }catch(QueryException e){
            System.debug('error'+ e.getMessage());
            return null;
        }   
        // String pathData = JSON.serialize(opportunityPathData.metadataPath__c);
        opportunityWrapper = (pathAssistantDTO.pathAssistantWrapper) JSON.deserialize(PathSettings.metadataPath__c, pathAssistantDTO.pathAssistantWrapper.class);
        System.debug('aaaaaa ' +opportunityWrapper);


        pathAssistantDTO.pathAssistantStep currentOppStep= new pathAssistantDTO.pathAssistantStep();

        for(pathAssistantDTO.pathAssistantStep pathStep: opportunityWrapper.pathAssistantSteps){
            if(pathStep.picklistValueName == newStage){
                currentOppStep= pathStep;
                break;
            }
        }

        System.debug('last step ' +currentOppStep);

        
        //opportunityWrapper = JSON.deserialize(currentOppRecordTypePath.Metadata, pathAssistantDTO.pathAssistantWrapper.class); 
        return currentOppStep;
   }

    @AuraEnabled 
    public static Map<String, pathAssistantDTO.pathAssistantStep> getOpportunityGuidance(String opportunityId){

        pathAssistantDTO.pathAssistantWrapper opportunityWrapper = new pathAssistantDTO.pathAssistantWrapper ();
        Opportunity currentOpp = [SELECT Id,StageName,recordType.DeveloperName from Opportunity where Id=: opportunityId];
        String keyField= 'Opportunity'+currentOpp.recordType.DeveloperName;

        Opportunity_Path_Info__mdt pathSettings = new Opportunity_Path_Info__mdt();
        try{
            pathSettings = [SELECT metadataPath__c from Opportunity_Path_Info__mdt where key_field__c=: keyField];
        }catch(QueryException e){
            System.debug('error'+ e.getMessage());
            return null;
        }   
        // String pathData = JSON.serialize(opportunityPathData.metadataPath__c);
        opportunityWrapper = (pathAssistantDTO.pathAssistantWrapper) JSON.deserialize(pathSettings.metadataPath__c, pathAssistantDTO.pathAssistantWrapper.class);
        System.debug('aaaaaa ' +opportunityWrapper);


        Map<String, pathAssistantDTO.pathAssistantStep> mapSteps= new Map<String, pathAssistantDTO.pathAssistantStep>();

        for(pathAssistantDTO.pathAssistantStep pathStep: opportunityWrapper.pathAssistantSteps){
            system.debug('step ' +pathStep.picklistValueName);
            system.debug('info ' +pathStep);
            mapSteps.put(pathStep.picklistValueName, pathStep);
        }

        system.debug('map steps ' +mapSteps);  
        
        //opportunityWrapper = JSON.deserialize(currentOppRecordTypePath.Metadata, pathAssistantDTO.pathAssistantWrapper.class); 
        return mapSteps;
   }

@AuraEnabled
   public static List<String>  getCloseReasons(){
       List<String> closeReasonsList= new List<String>();
       Schema.DescribeFieldResult fieldResult = Opportunity.pkl_LossReason__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry pValue : ple){
           if (pValue.isActive() && pValue.getLabel() !='Won (Awarded)' && pValue.getLabel() !='Lost' && pValue.getLabel() !='Project Cancelled' && pValue.getLabel() !='Invalid Data') {
               closeReasonsList.add(pValue.getLabel());
               
           }
           
       }
       return closeReasonsList;
   }
 
}