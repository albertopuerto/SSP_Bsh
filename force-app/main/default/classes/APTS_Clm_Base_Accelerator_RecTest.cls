/*************************************************************
@Name: APTS_Clm_Base_Accelerator_RecTest
@Author: Apttus
@CreateDate: 01/07/2020
@Description: Tests APTS_CLM_BASE_ACCELERATOR_RECORDINGS

******************************************************************
@ModifiedBy: 
@ModifiedDate: 
@ChangeDescription: 

******************************************************************/
@isTest
public class APTS_Clm_Base_Accelerator_RecTest{
    @testSetup static void setupTest()
    {
        Account testAcc = new Account();
        testAcc.Name = 'Faust Alchemical Supplies';
        testAcc.Role__c='ETDE Domestic Customer';
    	testAcc.Type='Internal';
		insert testAcc;
        
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;
        
        Apttus__APTS_Agreement__c newAg = new Apttus__APTS_Agreement__c();
        newAg.Name = 'Binding Contract';
        newAg.Apttus__Account__c = testAcc.Id;
        newAg.Apttus__Contract_End_Date__c = Date.Today().AddYears(24);
        newAg.Apttus__Status_Category__c ='Request';
        newAg.Apttus__Status__c = 'Request';        
        insert newAg;
        
        
    }
    
    static testmethod void recordingTest()
    {
        Apttus__APTS_Agreement__c a = [SELECT Id, Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c LIMIT 1][0];    
        APTS_CLM_BASE_ACCELERATOR_RECORDINGS.getFiles(a.id);
    }
}