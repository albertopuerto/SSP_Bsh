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