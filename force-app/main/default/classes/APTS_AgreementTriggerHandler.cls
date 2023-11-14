/**
* @Name: APTS_AgreementTriggerHandler
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: Triggerhandler for Agreement Trigger.
-----------------------------------------------------------------------------------------------
MODIFY:
07/21/22: Not needed for the Accelerator offering.
**/
public class APTS_AgreementTriggerHandler{
    /*
    public static void onAfterUpdate(List<Apttus__APTS_Agreement__c> newList, Map<Id,Apttus__APTS_Agreement__c> oldMap){
        APTS_integration_Allowed__c integrationallowed = APTS_integration_Allowed__c.getInstance('Integration_Allowed');
        Boolean allowcallouts = integrationallowed.APTS_Allow_Callout__c;
        APTS_AgreementTriggerHelper.activateFullySignedAgreement(newList,oldMap);
        if(allowcallouts){
            APTS_AgreementTriggerHelper.AgreementActive(newList,oldMap);
        }
    }
    public static void onAfterInsert(List<Apttus__APTS_Agreement__c> newList){APTS_AgreementTriggerHelper.AgreementDocFormatInsert(newList);
    }
    
    public static void onBeforeUpdate(List<Apttus__APTS_Agreement__c> newList, Map<Id,Apttus__APTS_Agreement__c> oldMap){
        APTS_AgreementTriggerHelper.AgreementDocFormatUpdate(newList);
    }
    */
}