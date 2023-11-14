/*************************************************************
@Name: APTS_IntegrationMasterWrapperTest
@Author:Apttus
@Description: Tests APTS_IntegrationMasterWrapper

******************************************************************/
@isTest
private class APTS_IntegrationMasterWrapperTest {
    
 static testMethod void myUnitTest() {
       
    
    Test.startTest();
        
    APTS_IntegrationMasterWrapper.GenerateTokenRequestWrapper genTokenReqWrapper = new APTS_IntegrationMasterWrapper.GenerateTokenRequestWrapper();
        genTokenReqWrapper.clientid = '123';
        genTokenReqWrapper.clientsecret = 'abc';
        genTokenReqWrapper.passwrd = 'pwd';
        genTokenReqWrapper.username = 'username';
        
    APTS_IntegrationMasterWrapper.TestJSONResponseWrapper resWrapper = new APTS_IntegrationMasterWrapper.TestJSONResponseWrapper();
       resWrapper.status = 'Success';
       resWrapper.statusCode = 'statuscode';
     
    APTS_IntegrationMasterWrapper.IntegrationWrapper intWrapper = new APTS_IntegrationMasterWrapper.IntegrationWrapper();
    APTS_Integration_Repository__c IR = new APTS_Integration_Repository__c();
    IR.name = 'Test';
    Insert IR;
     intWrapper.oRepository = IR;
     //insert intWrapper.oRepository;
        
    Test.stopTest();
        
        
    
    }

}