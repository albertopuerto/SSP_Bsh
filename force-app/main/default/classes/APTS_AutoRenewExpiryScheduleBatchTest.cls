/**
* @Name: APTS_AutoRenewExpiryScheduleBatchTest
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: Test Class for Agreement Auto Renew and Expiry Scheduler batch.
-----------------------------------------------------------------------------------------------
**/

@isTest
private class APTS_AutoRenewExpiryScheduleBatchTest{

@isTest static void CreateAgreementTest() {
    Account acc = new Account();
    acc.Name = 'testAccountforTestClass';
    acc.Role__c='ETDE Domestic Customer';
    acc.Type='Internal';
	acc.pkl_INCOTerms1__c = 'CIF - Cost, Insurance, and Freight';
    acc.txt_INCOTerms2__c = 'Wolfsburg';
    acc.pkl_Language__c = 'German';
    insert acc;
    
    Opportunity opp = new Opportunity();
    opp.Name ='testOpptyforTestClass';
    opp.CloseDate = system.today()+4;
    opp.StageName = 'Prospecting';
    opp.AccountId = acc.Id;
    opp.pklTypeOfOpportunity__c = 'LTA';
    opp.pklLeadingSolutionField__c = 'DAP';
    opp.pklTypeOfOffering__c = 'SW';
    insert opp;
    
    APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
    insert obj;
    
    List<Apttus__APTS_Agreement__c> listAggInsert = new List<Apttus__APTS_Agreement__c>();
    Apttus__APTS_Agreement__c agg1 = new Apttus__APTS_Agreement__c();
    agg1.name = 'testAgreementforTestclass';
    agg1.APTS_Internal_Legal_Entity__c = acc.Id;
    agg1.APTS_Type_of_Signature__c ='Esignature';
    agg1.Apttus__Contract_Start_Date__c = system.today() - 2;
    agg1.Apttus__Contract_End_Date__c = system.today();
    agg1.Apttus__Account__c = acc.Id;
    agg1.Apttus__Auto_Renewal__c = true;
    agg1.Apttus__Auto_Renew_Term_Months__c = 12;
    agg1.Apttus__Status__c = 'Ready for Signatures';
    listAggInsert.add(agg1);
    
    Apttus__APTS_Agreement__c agg2 = new Apttus__APTS_Agreement__c();
    agg2.name = 'testAgreementforTestclass';
    agg2.APTS_Internal_Legal_Entity__c = acc.Id;
    agg2.APTS_Type_of_Signature__c ='Esignature';
    agg2.Apttus__Contract_Start_Date__c = system.today() - 2;
    agg2.Apttus__Contract_End_Date__c = system.today();
    agg2.Apttus__Account__c = acc.Id;
    agg2.Apttus__Auto_Renewal__c = false;
    listAggInsert.add(agg2);
    insert listAggInsert;
    
    DateTime now  = DateTime.now();
    DateTime nextRunTime = now.addMinutes(1);
    String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                    nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                    nextRunTime.month() + ' ? ' + nextRunTime.year();
    System.debug(LoggingLevel.INFO, '#### calculated cronString is ' + cronString);
    
    Test.StartTest();
    APTS_AutoExpiryRenewalBatchScheduler sch = new APTS_AutoExpiryRenewalBatchScheduler();
    system.schedule('testing scheduler',cronString,sch);
    Test.stopTest();
}
    
}