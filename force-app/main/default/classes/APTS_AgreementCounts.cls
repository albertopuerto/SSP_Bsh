public class APTS_AgreementCounts {
    @AuraEnabled
    public static Integer getActionRequiredCount(){
        List<Apttus__APTS_Agreement__c> agreementList =  [SELECT id
                       FROM Apttus__APTS_Agreement__c
                       WHERE ownerid =: userinfo.getUserId()];
        return agreementList.size();
    }
    @AuraEnabled
    public static Integer getNeedsAttentionCount(){
        List<Apttus__APTS_Agreement__c> agreementList =  [SELECT id
                       FROM Apttus__APTS_Agreement__c
                       WHERE Apttus__Contract_End_Date__c >= :System.Today() and Apttus__Contract_End_Date__c <= :System.Today()+30];
        return agreementList.size();
    }
    @AuraEnabled
    public static String getListViewDetail(String objectName,String viewName){
        return APTS_ListViewIdGeneric.getListViewDetail(objectName,viewName);
    }
}