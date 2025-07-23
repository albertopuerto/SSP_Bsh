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
   public static Opportunity  getOpportunityData(String opportunityId){
        Opportunity currentOpp = [SELECT AccountId,CloseDate,Amount,SBQQ__PrimaryQuote__c,Probability,Budget_Confirmed__c,StageName from Opportunity where Id=: opportunityId];
        
        //opportunityWrapper = JSON.deserialize(currentOppRecordTypePath.Metadata, pathAssistantDTO.pathAssistantWrapper.class); 
        return currentOpp;
   }

@AuraEnabled
   public static List<String>  getClosedStatusValues(){
       List<String> statusList= new List<String>();
       Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry pValue : ple){
           if (pValue.isActive() && pValue.getLabel() =='Won (Awarded)' || pValue.getLabel() =='Lost' || pValue.getLabel() !='Project Cancelled' || pValue.getLabel() !='Invalid Data') {
               statusList.add(pValue.getLabel());
               
           }
           
       }
       return statusList;
   }

@AuraEnabled 
   public static pathAssistantDTO.pathAssistantStep  getOpportunityFields(String opportunityId,String newStage){
        pathAssistantDTO.pathAssistantWrapper opportunityWrapper = new pathAssistantDTO.pathAssistantWrapper ();
        Opportunity currentOpp = [SELECT Id,StageName,recordType.DeveloperName from Opportunity where Id=: opportunityId];
        String keyField= 'Opportunity'+currentOpp.recordType.DeveloperName;

        Opportunity_Path_Info__mdt PathSettings = [SELECT metadataPath__c from Opportunity_Path_Info__mdt where key_field__c=: keyField];
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