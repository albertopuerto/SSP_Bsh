/*************************************************************
@Name: APTS_CreateAgreementPageCtrlTest
@Author:Apttus
@Description: Tests APTS_CreateAgreementPageController

******************************************************************/
@isTest
private class APTS_CreateAgreementPageCtrlTest{

    static testMethod void myUnitTest() {
        
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;

        
        Apttus__WizardDesign__c wizardDesign = new Apttus__WizardDesign__c();
        wizardDesign.Name = 'Agreement Request Portal';
        wizardDesign.Apttus__Status__c = 'Activated';
        insert wizardDesign;

        //Start Test
        Test.startTest();
        
        //Initialize the page
      ApexPages.StandardController sc = new ApexPages.StandardController(wizardDesign);
        APTS_CreateAgreementPageController Ctrl = 
            new APTS_CreateAgreementPageController(sc);
        
        //execute doRedirect method
        Ctrl.doRedirect();
       
        Test.stopTest();
        
        
    }
    
    
}