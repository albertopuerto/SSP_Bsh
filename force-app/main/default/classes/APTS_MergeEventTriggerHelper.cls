/**
* @Name: APTS_MergeEventTriggerHelper
* @Author: Apttus
* @CreateDate: 30-July-2019
* @Description: Helper class for APTS_MergeEventTrigger.
---------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
    ---------------------------------------------------------------------------------------------
    MODIFY:
    07/21/22: Not needed for the Accelerator offering.
**/
public class APTS_MergeEventTriggerHelper {

    /**
    * @Description : To  Update Approval Status on Agreement based on Check in-Final 
    * @CreateDate: 30-July-2019
    * @Owner : Apttus
    
    */
    /*
    public static void updateApprovalStatus(List<Apttus__MergeEvent__c> listMergeEventNew) {
       List<Apttus__APTS_Agreement__c> updateAgreementList = new List<Apttus__APTS_Agreement__c>();
       set<Id> agreementIds = new set<Id>();
       Map<Id,Apttus__APTS_Agreement__c> agreementMap = new Map<Id,Apttus__APTS_Agreement__c>();
       
        //Added by Chandan on 12/11/2019: to read short process flow name for Self Serve
        Agreement_Process_Flow_Setting__mdt[] flowmapping  = [SELECT MasterLabel,Agreement_Process_Flow_Short_Name__c FROM Agreement_Process_Flow_Setting__mdt where MasterLabel = 'Self-serve process flow'];
        string processFlowName = string.valueOf(flowmapping[0].Agreement_Process_Flow_Short_Name__c);
       //Chandan Addition ends
        
        for (Apttus__MergeEvent__c mergeEvent : listMergeEventNew) {
            agreementIds.add(mergeEvent.Apttus__AgreementId__c);
        }
        for(Apttus__APTS_Agreement__c agreementObj : [SELECT Id,RecordTypeId,RecordType.Name,Apttus__Non_Standard_Legal_Language__c,APTS_Process_Flow__c FROM Apttus__APTS_Agreement__c WHERE Id IN :agreementIds ]) {
            agreementMap.put(agreementObj.Id,agreementObj);
        }
        for (Apttus__MergeEvent__c mergeEvent : listMergeEventNew) {
           
            if(mergeEvent.Name == 'Check In' && mergeEvent.Apttus__Action__c == 'Check In' && mergeEvent.Apttus__DocumentInfo__c == 'Final') {
                updateAgreementList.add(new Apttus__APTS_Agreement__c(Id = mergeEvent.Apttus__AgreementId__c, Apttus__Status__c = 'Ready for Signatures',Apttus__Status_Category__c = 'In Signatures'));
            } else if(mergeEvent.Name == 'Generate') {
                if(agreementMap.containsKey(mergeEvent.Apttus__AgreementId__c)) {
                    Apttus__APTS_Agreement__c agr = agreementMap.get(mergeEvent.Apttus__AgreementId__c);
                    //updated by Chandan on 12/11/2019 : for setting up status category and status for self-serve and other flow
                    if(agr.APTS_Process_Flow__c == processFlowName) {                    
                        updateAgreementList.add(new Apttus__APTS_Agreement__c(Id = mergeEvent.Apttus__AgreementId__c, Apttus__Status__c = 'Ready for Signatures',Apttus__Status_Category__c = 'In Signatures'));
                    }                    
                    else{
                        updateAgreementList.add(new Apttus__APTS_Agreement__c(Id = mergeEvent.Apttus__AgreementId__c, Apttus__Status__c = 'Author Contract',Apttus__Status_Category__c = 'In Authoring'));
                    }
                    
                }
            }              
            
        }
        if (!updateAgreementList.isEmpty()) {           
            update updateAgreementList;
        }        
       
    }
    */
}