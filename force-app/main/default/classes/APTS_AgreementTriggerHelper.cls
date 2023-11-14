/**
* @Name: APTS_AgreementTriggerHelper
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: TriggerHelper for Agreement Trigger.
-----------------------------------------------------------------------------------------------
MODIFY:
07/21/22: Not needed for the Accelerator offering.
**/
public class APTS_AgreementTriggerHelper{
    /*
    public static void activateFullySignedAgreement(List<Apttus__APTS_Agreement__c> newList, Map<Id,Apttus__APTS_Agreement__c> oldMap){
        Map<Id, ContentVersion> agmtSignedDocs = new Map<Id, ContentVersion>() ;
        Map<id,id> contDocIdMap = new Map<Id,Id>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        Map<Id,ContentVersion> signedAtmts = new Map<Id,ContentVersion>();
        if (newList != null && newList.size()==1){        
            Set<Id> agmtIds = new Set<Id>();
                        
            for(Apttus__APTS_Agreement__c agmt: newList) {                                
                Agreement_Process_Flow_Setting__mdt[] flowmapping  = [SELECT MasterLabel,Auto_Activation__c FROM Agreement_Process_Flow_Setting__mdt where Agreement_Process_Flow_Short_Name__c = :agmt.APTS_Process_Flow__c ];                
                System.debug('Auto Activation Flag -'+flowmapping[0].Auto_Activation__c);       		
                if (agmt.Apttus__Status__c == APTS_Constants.AGMT_STATUS_FULLY_SIGNED && oldMap.get(agmt.Id).Apttus__Status__c != agmt.Apttus__Status__c &&
                    flowmapping[0].Auto_Activation__c == true)
                    agmtIds.add(agmt.Id);
            		System.debug('agmtIds-'+agmtIds);
            }
                
            //Querying the Fully Sogned agreement attahments 
            if(!agmtIds.isEmpty()){             
                cdlList = [select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:agmtIds];
                for(ContentDocumentLink cdLink : cdlList){
                    contDocIdMap.put(cdLink.ContentDocumentId,cdLink.LinkedEntityId);
                }
                ContentVersion signedAtmt;
                if(!contDocIdMap.isEmpty()){
                    String attName = '';
                    for(ContentVersion cv : [select id,VersionData,ContentDocumentId,Title from ContentVersion where ContentDocumentId IN:contDocIdMap.keySet()]){
                        attName = cv.Title.toLowerCase();
                        if((attName).contains(APTS_Constants.AGMT_SIGNED_DOC_KEY)){
                            signedAtmt = new ContentVersion();
                            agmtSignedDocs.put(contDocIdMap.get(cv.ContentDocumentId),cv);
                            signedAtmt.VersionData = cv.VersionData;
                            signedAtmt.PathOnClient = cv.Title+'.PDF';
                            signedAtmts.put(cv.ContentDocumentId,signedAtmt);
                        }
                    }
                }
            }
           System.debug('agmtSignedDocs-'+agmtSignedDocs);
            if(!agmtSignedDocs.isEmpty()){
                try{
                    for(Apttus__APTS_Agreement__c agmt: newList){
                        //If the agreement has Signed documnt calling Activate and publish to repositary API's
                        if(agmtSignedDocs.containsKey(agmt.Id)){
                            Id attmtId = agmtSignedDocs.get(agmt.Id).ContentDocumentId;
                            List<Id> selectedDocIds = new List<Id> ();
                            List<Id> removableDocIds = new List<Id> ();
                            selectedDocIds.add(attmtId);
                            if(!Test.isRunningTest()){
                                Boolean res = Apttus.AgreementWebService.activateAgreement(agmt.Id, selectedDocIds, removableDocIds);
                                if(res){                                    
                                     Boolean publishRes = Apttus.AgreementWebService.publishToChatterRepository(agmt.Id, attmtId);
                                    if(!publishRes)
                                        agmt.addError('Publishing documents to chatter failed');
                                }else
                                    agmt.addError('Agreement Activation failed');
                            }
                        }
                    }
                    
                   //Creating signed docuemnts back to agreement attachments because after activation signed copies are getting deleted from attachments
                    
                    insert signedAtmts.values();
                    System.debug('  '+agmtSignedDocs);
                    List<ContentDocumentLink> contDocLinks = new List<ContentDocumentLink>();
                    ContentDocumentLink contDocLink = null;
                    Map<id,ContentVersion> cvMap = new Map<Id,ContentVersion>([select id,ContentDocumentId from ContentVersion where Id IN:signedAtmts.values()]);
                    for(Id cd : signedAtmts.keySet()){
                        contDocLink = new ContentDocumentLink();
                        contDocLink.ShareType ='V';
                        contDocLink.LinkedEntityId = contDocIdMap.get(cd);
                        contDocLink.ContentDocumentId = cvMap.get(signedAtmts.get(cd).Id).ContentDocumentId;
                        contDocLinks.add(contDocLink);
                    }
                    
                    insert contDocLinks;
                }catch(Exception ex){
                    System.debug(ex.getMessage()+ex.getCause()+ex.getLineNumber());
                }
            }
        }
    }
    
    public static void AgreementActive(List<Apttus__APTS_Agreement__c> newList, Map<Id,Apttus__APTS_Agreement__c> oldMap){
        for(Apttus__APTS_Agreement__c agr :newList){
            system.debug('record pushed>>>'+agr);
            if(agr.Apttus__Status__c == 'Activated' && oldMap.get(agr.Id).Apttus__Status__c != agr.Apttus__Status__c){
                //if(!system.isBatch()){
                    //APTS_IntegrationController.submitRequest(agr.Id);
                    System.enqueueJob(new APTS_IntegrationController(agr.Id));
                //}
            }
        }
    }
     
    public static void AgreementDocFormatInsert(List<Apttus__APTS_Agreement__c> newList){
        if(newList.size()>0){
            update newList;
        }
    }
     
    public static void AgreementDocFormatUpdate(List<Apttus__APTS_Agreement__c> newList){
        Agreement_Process_Flow_Setting__mdt[] threatMappings = [SELECT DeveloperName,Agreement_Process_Flow_Short_Name__c,AgreementOutputFormats__c,Agreement_Record_Type__c,Agreement_Process_Flow__c FROM Agreement_Process_Flow_Setting__mdt];
        if(threatMappings.size()>0 && threatMappings != null){
            Map<string,string> processFlowMap = new Map<String, String>();
            for(Agreement_Process_Flow_Setting__mdt apfs:threatMappings){
                if(apfs != null && apfs.Agreement_Process_Flow_Short_Name__c != null)
                processFlowMap.put(apfs.Agreement_Process_Flow_Short_Name__c,apfs.AgreementOutputFormats__c);
            }
            for(Apttus__APTS_Agreement__c agr :newList){
                if(processFlowMap.size()>0 && processFlowMap != null && agr.APTS_Process_Flow__c != null){
                    agr.Apttus__AllowableOutputFormats__c = processFlowMap.get(agr.APTS_Process_Flow__c); 
                  }
            }
        }
    }
    */
}