@isTest
private class APTS_IntegrationController_Test {
    
    @isTest static void testupsert() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new APTS_JsonWebServiceMock()); 
        APTS_integration_Allowed__c integrationallowed = new APTS_integration_Allowed__c();
        integrationallowed.Name = 'Integration_Allowed';
        integrationallowed.APTS_Allow_Callout__c = true;
        insert  integrationallowed;
        APTS_Integration_Repository__c rep = new APTS_Integration_Repository__c();
        rep.Name='test';
        rep.APTS_Service_Type__c = 'REST';
        rep.APTS_Implementation_Class__c = 'APTS_AgreementIntegrationService';
        rep.APTS_Operation_Name__c = 'submitrequest';
        rep.APTS_Body_Implementation_Class__c ='APTS_CreateJSONBodyController';
        rep.APTS_isActive__c = true;
        rep.APTS_Log_Messages__c = true;
        rep.APTS_Endpoint__c = 'test';
        insert rep;
        
        Account testAcc = new Account();
        testAcc.Name = 'test';
        testAcc.Role__c='ETDE Domestic Customer';
        testAcc.Type='Internal';
        testAcc.pkl_Language__c = 'German';
        testAcc.pkl_PaymentTerms__c = 'Net 15';
        insert testAcc;
        
        Apttus__APTS_Agreement__c newAg = new Apttus__APTS_Agreement__c();
        newAg.Name = 'test';
        newAg.Apttus__Account__c = testAcc.Id;
        newAg.Apttus__Status_Category__c ='Request';
        newAg.Apttus__Status__c = 'Request';
        insert newAg;
        
        Test.startTest();
        system.enqueueJob(new APTS_IntegrationController(newAg.Id));
        Test.stopTest();
    }   
}