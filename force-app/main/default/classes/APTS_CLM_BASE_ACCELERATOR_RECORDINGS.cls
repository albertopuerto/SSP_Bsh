public with sharing class APTS_CLM_BASE_ACCELERATOR_RECORDINGS {
//public without sharing class APTS_CLM_BASE_ACCELERATOR_RECORDINGS {
@auraEnabled
    public static List<ContentDocument> getFiles(Id objectId){
    	
        Apttus__APTS_Agreement__c agr = [SELECT APTS_Process_Flow__c FROM Apttus__APTS_Agreement__c WHERE Id=:objectId];
        
        Agreement_Process_Flow_Setting__mdt[] sflowmapping  = [SELECT Help_Me_Understand__c, Show_Me_Flow__c FROM Agreement_Process_Flow_Setting__mdt where Agreement_Process_Flow_Short_Name__c = :agr.APTS_Process_Flow__c];
        string showMeFlow = string.valueOf(sflowmapping[0].Show_Me_Flow__c);
        string helpMeUnderstand = string.valueOf(sflowmapping[0].Help_Me_Understand__c);
        List<ContentDocument> reg =new LIST<ContentDocument>([SELECT Id,title FROM ContentDocument where Id = :showMeFlow OR Id = :helpMeUnderstand]);
    return reg;
    }
    
}