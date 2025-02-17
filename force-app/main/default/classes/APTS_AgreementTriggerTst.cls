/**
* @Name: APTS_AgreementTriggerTst
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: Test Class for Agreement Trigger.
-----------------------------------------------------------------------------------------------
**/

@isTest
private class APTS_AgreementTriggerTst {

@isTest static void autoActivateAgreementTest() {
    Account testAcc = new Account();
    testAcc.Name = 'testAccountforTestClass';
    testAcc.Role__c='ETDE Domestic Customer';
    testAcc.Type='Internal';
    testAcc.pkl_INCOTerms1__c = 'DAP – Delivered at Place';
    testAcc.txt_INCOTerms2__c = 'Wolfsburg';
    testAcc.pkl_Language__c = 'German';
    testAcc.pkl_PaymentTerms__c = 'Net 15';
    insert testAcc;
    
    Opportunity opp = new Opportunity();
    opp.Name ='testOpptyforTestClass';
    opp.CloseDate = system.today()+4;
    opp.StageName = 'Prospecting';
    opp.pklTypeOfOffering__c = 'SW';
    opp.pklTypeOfOpportunity__c = 'LTA';
    opp.pklLeadingSolutionField__c = 'DAP';
    opp.AccountId = testAcc.Id;
    
    insert opp;
    
    APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;

    
    Apttus__APTS_Agreement__c agg = new Apttus__APTS_Agreement__c();
    agg.name = 'testAgreementforTestclass';
    agg.APTS_Internal_Legal_Entity__c = testAcc.Id;
    agg.APTS_Type_of_Signature__c ='Esignature';
    agg.Apttus__Contract_Start_Date__c = system.today();
    agg.Apttus__Account__c = testAcc.Id;
    agg.Apttus__Status__c = 'Ready for Signatures';
    insert agg;
    
    ContentVersion att = new ContentVersion();
    att.VersionData= blob.valueOf('abcd');
    att.PathOnClient = 'signedDoc.PDF';
    
    insert att;
    
    ContentVersion cv = [select id,ContentDocumentId from contentVersion where id =: att.Id];
    
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = cv.ContentDocumentId;
    cdl.LinkedEntityId = agg.Id;
    cdl.ShareType ='V';
    insert cdl;
    
    Test.StartTest();
    agg.Apttus__Status__c = 'Fully Signed';
    update agg;
    Test.stopTest();
}
    
}