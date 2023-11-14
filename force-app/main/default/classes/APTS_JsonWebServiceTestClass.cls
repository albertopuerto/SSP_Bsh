@isTest
public class APTS_JsonWebServiceTestClass
{
    static testMethod void testJsonWebService()
      {  
         // Insert proposal record
         /*Apttus_Proposal__Proposal__c propObj = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Approval_Stage__c = 'Draft');
         insert propObj;*/
                
         //Insert Integration Repository record
         /*APTS_Integration_Repository__c repositorySO = new APTS_Integration_Repository__c(Name='TestJSONWebservice',
                                                       APTS_Operation_Name__c='TestJSONWebservice',
                                                       APTS_Implementation_Class__c='APTS_SampleJSONServiceImpl',
                                                       APTS_Endpoint__c='https://na85.salesforce.com/services/apexrest/ProcessQuote/',
                                                       APTS_Log_Messages__c = True,
                                                       APTS_Logs_Retention_Days__c = Integer.valueOf(1),
                                                       APTS_isActive__c = True);
         insert repositorySO;                                                       
        
         Test.startTest();
         
         PageReference pageRef = Page.APTS_IntegrationPage;
         Test.setCurrentPage(pageRef); 
         
         Apttus_Proposal__Proposal__c propSO = [Select Id, Name from Apttus_Proposal__Proposal__c where Id =:propObj.Id];
         
         APTS_IntegrationController controllerSO = new APTS_IntegrationController();
         controllerSO.quoteName = propSO.Name;
         controllerSO.selectedCode = '200';
         controllerSO.selectedStatus = 'Presented';
         Test.setMock(HttpCalloutMock.class, new APTS_JsonWebServiceMock()); 
         controllerSO.save();
         
         Test.stopTest();*/
      
      }
      
      
    static testMethod void testRetryOperation()
      {
         
         /*String CRON_EXP = '0 0 0 15 3 ? *';
          
         //Insert Integration Repository record
         APTS_Integration_Repository__c repositorySO = new APTS_Integration_Repository__c(Name='TestJSONWebservice',
                                                       APTS_Operation_Name__c='TestJSONWebservice',
                                                       APTS_Implementation_Class__c='APTS_SampleJSONServiceImpl',
                                                       APTS_Endpoint__c='https://na85.salesforce.com/services/apexrest/ProcessQuote/',
                                                       APTS_Log_Messages__c = True,
                                                       APTS_Logs_Retention_Days__c = Integer.valueOf(1),
                                                       APTS_isActive__c = True);
         insert repositorySO;      
        
         //Insert Integration Transaction record
         APTS_Integration_Transaction__c transactionSO = new APTS_Integration_Transaction__c(APTS_Status__c = 'Failed', APTS_Perform_Retry__c = True, APTS_Integration_Repository__c = repositorySO.Id);
         insert transactionSO;
          
         Test.startTest();
         String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new APTS_RetryOperationSchedule());
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
         System.assertEquals(CRON_EXP, ct.CronExpression);
         System.assertEquals(0, ct.TimesTriggered);
         Test.stopTest();*/
      
      }
      
      
      static testMethod void testDeleteTransactionData()
      {
         
         /*String CRON_EXP = '0 0 0 15 3 ? *';
          
         //Insert Integration Repository record
         APTS_Integration_Repository__c repositorySO = new APTS_Integration_Repository__c(Name='TestJSONWebservice',
                                                       APTS_Operation_Name__c='TestJSONWebservice',
                                                       APTS_Implementation_Class__c='APTS_SampleJSONServiceImpl',
                                                       APTS_Endpoint__c='https://na85.salesforce.com/services/apexrest/ProcessQuote/',
                                                       APTS_Log_Messages__c = True,
                                                       APTS_Logs_Retention_Days__c = -1,
                                                       APTS_isActive__c = True);
         insert repositorySO;      
        
         //Insert Integration Transaction record
         APTS_Integration_Transaction__c transactionSO = new APTS_Integration_Transaction__c(APTS_Status__c = 'Failed', APTS_Perform_Retry__c = True, APTS_Integration_Repository__c = repositorySO.Id);
         insert transactionSO;
          
         Test.startTest();
         String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new APTS_DeleteTransactionRecordsSchedule());
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
         System.assertEquals(CRON_EXP, ct.CronExpression);
         System.assertEquals(0, ct.TimesTriggered);
         Test.stopTest();*/
      
      }
      
      
      static testMethod void testProcessQuote1()
      {
      
         
         // Insert proposal record
        /* Apttus_Proposal__Proposal__c propObj = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Approval_Stage__c = 'Draft');
         insert propObj;   
         
         APTS_IntegrationMasterWrapper.TestJSONRequestWrapper requestWrapper = new APTS_IntegrationMasterWrapper.TestJSONRequestWrapper();
         requestWrapper.quotationId = propObj.Id;
         requestWrapper.requestCode = '200';
         requestWrapper.status = 'Presented';
         String JSONReq = JSON.serialize(requestWrapper);
         
         Test.startTest();   
         RestRequest request = new RestRequest();
         RestResponse response = new RestResponse();
         
         request.requestUri = 'https://na85.salesforce.com/services/apexrest/ProcessQuote/';
         request.httpMethod = 'POST';
         request.addHeader('Content-Type', 'application/json'); 
         request.requestBody = Blob.valueof(JSONReq);
         
         RestContext.request = request;
         RestContext.response = response;
         
         APTS_ProcessQuote.doPost();
         Test.stopTest();*/
      
      }
      
      
      static testMethod void testProcessQuote2()
      {
      
         
         // Insert proposal record
         /*Apttus_Proposal__Proposal__c propObj = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Approval_Stage__c = 'Draft');
         insert propObj;   
         
         APTS_IntegrationMasterWrapper.TestJSONRequestWrapper requestWrapper = new APTS_IntegrationMasterWrapper.TestJSONRequestWrapper();
         requestWrapper.quotationId = propObj.Id;
         requestWrapper.requestCode = '500';
         requestWrapper.status = 'Presented';
         String JSONReq = JSON.serialize(requestWrapper);
         
         Test.startTest();   
         RestRequest request = new RestRequest();
         RestResponse response = new RestResponse();
         
         request.requestUri = 'https://na85.salesforce.com/services/apexrest/ProcessQuote/';
         request.httpMethod = 'POST';
         request.addHeader('Content-Type', 'application/json'); 
         request.requestBody = Blob.valueof(JSONReq);
         
         RestContext.request = request;
         RestContext.response = response;
         
         APTS_ProcessQuote.doPost();
         Test.stopTest();*/
      
      }
      
}