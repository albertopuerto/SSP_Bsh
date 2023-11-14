/*************************************************************
@Name: APTS_MergeEventTriggerTest
@Author:Apttus
@Description: Tests APTS_MergeEventTrigger,APTS_MergeEventTriggerHandler,APTS_MergeEventTriggerHelper

******************************************************************/
@isTest
private class APTS_MergeEventTriggerTest{

    static testMethod void myUnitTest() {
        /*
        //Create a new Account
        Account testacc = new Account();
        testacc.Name = 'Test Account';
        testAcc.Role__c='ETDE Domestic Customer';
     	testAcc.Type='Internal';

        insert testacc;
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;

        //Create new agreement
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.Apttus__Account__c = testacc.Id;
       
        agreement.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('MSA').getRecordTypeId();
        agreementList.add(agreement);
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c();
        agreement1.Apttus__Account__c = testacc.Id;
         agreement1.Apttus__Non_Standard_Legal_Language__c = true;
        agreement1.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('NDA').getRecordTypeId();
        agreementList.add(agreement1);
        insert agreementList;
        
        
        //Start Test
        Test.startTest();
        List<Apttus__MergeEvent__c> mergeEventList = new List<Apttus__MergeEvent__c>();
        Apttus__MergeEvent__c mergeEvent  = new Apttus__MergeEvent__c();
        mergeEvent.Name = 'Check In' ;
        mergeEvent.Apttus__Action__c = 'Check In' ;
        mergeEvent.Apttus__DocumentInfo__c = 'Final' ;      
             
        mergeEvent.Apttus__AgreementId__c = agreementList[0].id ;   
        mergeEventList.add(mergeEvent);
        Apttus__MergeEvent__c mergeEvent1  = new Apttus__MergeEvent__c();
        mergeEvent1.Name = 'Generate' ;
        mergeEvent1.Apttus__Action__c = 'Generate' ;
        mergeEvent1.Apttus__AgreementId__c = agreementList[0].id ;  
        mergeEvent1.Apttus__DocumentInfo__c = 'Draft' ;         
        mergeEventList.add(mergeEvent1);
        Apttus__MergeEvent__c mergeEvent2  = new Apttus__MergeEvent__c();
        mergeEvent2.Name = 'Generate' ;
        mergeEvent2.Apttus__Action__c = 'Generate' ;
        mergeEvent2.Apttus__AgreementId__c = agreementList[1].id ; 
        mergeEvent2.Apttus__DocumentInfo__c = 'Draft' ;         
        mergeEventList.add(mergeEvent2);
        insert mergeEventList;
        mergeEventList[2].Name = 'Generate2' ;
        update mergeEventList;
       
        
       
            
        //Stop Test
        Test.stopTest();
        
       */
        
        
    }
    
    
}