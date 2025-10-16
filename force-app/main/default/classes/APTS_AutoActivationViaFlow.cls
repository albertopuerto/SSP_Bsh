/*
This class will be used to auto activate the agreement whose status is 
In Signature and fully signed.
This class will be used from flow.
*/
public class APTS_AutoActivationViaFlow {
    @InvocableMethod (label= 'AutoActivate Agreement'
                      category='Agreement')
    public static void activateAgreement(List<String> ids){
        Map<Id, List<Apttus__DocumentVersion__c>> mapOfAgrDocVersion = new Map<Id,List<Apttus__DocumentVersion__c>>();
        List<Apttus__APTS_Agreement__c> agreementToUpdate = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> Agmts = [Select id,name,Apttus__Status__c,Apttus__Status_Category__c from Apttus__APTS_Agreement__c
                                                 where id in : ids];
        //storing matched document versions against the agreement in mapOfAgrDocVersion
        for(Apttus__DocumentVersion__c docV : [select id, Apttus__AgreementId__c, Apttus__LatestVersionId__r.Apttus__ContentId__c, Name 
                                               from Apttus__DocumentVersion__c where Apttus__AgreementId__c IN :ids]){
            List<Apttus__DocumentVersion__c> tempDocV = new List<Apttus__DocumentVersion__c>();
		//Checking if Agreement entry has already been created in map
		//If it has already been created than we will just add the document version 
		//Else we will create new entry for agreement and put the document version in it                                                    
            If(mapOfAgrDocVersion.containsKey(docV.Apttus__AgreementId__c)){
                mapOfAgrDocVersion.get(docV.Apttus__AgreementId__c).add(docV);
            }else{
                tempDocV.add(docV);
                mapOfAgrDocVersion.put(docV.Apttus__AgreementId__c, tempDocV);
            }
        }
        for(Apttus__APTS_Agreement__c agm : Agmts){
            List<Apttus__DocumentVersion__c> docVersion = new List<Apttus__DocumentVersion__c>();
            if(mapOfAgrDocVersion.containsKey(agm.Id)){
            	docVersion = mapOfAgrDocVersion.get(agm.Id);   
            }
            List<Id> selectedDocIds = new List<Id>();
            //Checking if document version is empty for current agreement
            //If it is not empty than we will call activation API and update the agreement status
            if(!docVersion.isEmpty())
            {
            		selectedDocIds.add(docVersion[0].Apttus__LatestVersionId__r.Apttus__ContentId__c);
                    Boolean res = Apttus.AgreementWebService.activateAgreement(agm.Id, selectedDocIds, null);
                    if(res){  
                        System.debug('Agreement activated');	
                        agm = changingAgreementStatus(res,agm);
                        agreementToUpdate.add(agm);
                    }
                    else{
                        agm.addError('Agreement Activation failed');
                    }  	
                   
            }
        }
        /*
           Updating the status of Agreement.
        */
        if(agreementToUpdate.size()>0){
            update agreementToUpdate;
        }
    }
    public static Apttus__APTS_Agreement__c changingAgreementStatus(Boolean res,Apttus__APTS_Agreement__c agreement ){
       
        /*
			If activation was successfull we will change the agreement status to In Effect/Activated
		*/
        if(res)
        {
            System.debug('Activation successfull');
            agreement.Apttus__Status__c = 'Activated';
            agreement.Apttus__Status_Category__c = 'In Effect';
            agreement.Apttus__Activated_Date__c = System.today();
        }
        /*
			if activation API failed then we will throw below error.
		*/
        else
        {
            agreement.addError('Agreement Activation failed');
        }
        return agreement;
    }
}