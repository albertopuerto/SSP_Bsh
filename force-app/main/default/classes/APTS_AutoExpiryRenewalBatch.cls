/**
* @Name: APTS_AutoExpiryRenewalBatch
* @Author: Apttus
* @CreateDate: 01-Aug-2019
* @Description: This class is to auto Expiry/Renew Agreements which are expiring today.
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/

global class APTS_AutoExpiryRenewalBatch implements Database.Batchable<sObject>{

String query = 'SELECT Id, Apttus__Auto_Renewal__c, Apttus__Auto_Renew_Term_Months__c, Apttus__Contract_End_Date__c,Apttus__Status__c FROM Apttus__APTS_Agreement__c where Apttus__Contract_End_Date__c =   today';


global Database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
    }

global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<Apttus__APTS_Agreement__c > listAgreementsToUpdate = new List<Apttus__APTS_Agreement__c >();

   for(sObject sObj : scope){
        Apttus__APTS_Agreement__c ObjAgr = (Apttus__APTS_Agreement__c)sObj;
        if(ObjAgr.Apttus__Auto_Renewal__c){
            if(ObjAgr.Apttus__Auto_Renew_Term_Months__c != null && ObjAgr.Apttus__Contract_End_Date__c != null){
                ObjAgr.Apttus__Contract_End_Date__c = ObjAgr.Apttus__Contract_End_Date__c.AddMonths(Integer.ValueOf(ObjAgr.Apttus__Auto_Renew_Term_Months__c));//updates End Date with Renewal Term Months
                ObjAgr.Apttus__Auto_Renewal__c = false;// set Auto Renewal to false
                listAgreementsToUpdate.add(ObjAgr);
            }
        }
        else{
            ObjAgr.Apttus__Status__c = 'Expired';//Setting agreement status to Expired
            listAgreementsToUpdate.add(ObjAgr);
        }
    }

    Database.SaveResult[] srList = Database.Update(listAgreementsToUpdate, false);
    
}
global void finish(Database.BatchableContext BC){
}
}