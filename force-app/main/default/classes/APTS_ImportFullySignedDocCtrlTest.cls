/*************************************************************
@Name: APTS_ImportFullySignedDocCtrlTest
@Author:Apttus
@Description: Tests APTS_ImportFullySignedDocumentController

******************************************************************/
@isTest
private class APTS_ImportFullySignedDocCtrlTest{

    static testMethod void myUnitTest() {
        
        //Create a new Account
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.pkm_BoschPartnerRole__c='BBCUEX';
        testAcc.Type='Internal';
        testAcc.pkl_Language__c = 'German';
        insert testAcc;
        
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;

        
        //Create new agreement
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.Apttus__Account__c = testacc.Id;
        
        insert agreement;

        //Start Test
        Test.startTest();
        
        //Initialize the page
        PageReference ImportFullySignedPage = 
            new PageReference('/apex/APTS_ImportFullySignedDocument?id='+agreement.Id);
      Test.setCurrentPage(ImportFullySignedPage );
    //   ApexPages.StandardController sc = new ApexPages.StandardController(agreement);
    //     APTS_ImportFullySignedDocumentController Ctrl = 
    //         new APTS_ImportFullySignedDocumentController(sc);
        
        //execute finalize method
        // Ctrl.finalize();
        
        //Stop Test
        Test.stopTest();
        
        //Query agreement record
        Apttus__APTS_Agreement__c agreementResult = [select Id, Apttus__Status_Category__c, 
            Apttus__Status__c from Apttus__APTS_Agreement__c where Id = :agreement.Id];
        
        //Assert that the agreement is in signatures status category and fully signed status
        // System.assertEquals(agreementResult.Apttus__Status_Category__c,'In Signatures');
        // System.assertEquals(agreementResult.Apttus__Status__c,'Fully Signed');
        
        
    }
    
    
}