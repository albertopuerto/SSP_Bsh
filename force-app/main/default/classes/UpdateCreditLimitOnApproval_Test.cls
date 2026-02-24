@isTest
public class UpdateCreditLimitOnApproval_Test {

     @TestSetup
     static void setupTestData() {
        Account testAccountList = (Account)TestFactory.createSObject(new Account(),'TestFactoryDefaults.AccountDefaults', false);
        testAccountList.txt_AthenaUUID__c='4001000001';
        testAccountList.BillingCountry='DE';
        insert testAccountList;
        
        Contact[] testContactList = (Contact[])TestFactory.createSObjectList(new Contact(), 1);
        testContactList[0].AccountId = testAccountList.Id;
        insert testContactList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = testAccountList.Id;
        quoteList[0].cur_CreditLimit__c= 500000;
        quoteList[0].dtm_CreditLimitCheckDate__c= DateTime.now();
        //quoteList[0].lkp_BillToAccount__c= testAccountList[0].Id;
        insert quoteList;
        
        Product2[] productList = (Product2 [])TestFactory.createSObjectList(new Product2(),1);
        insert productList;
        
        SBQQ__QuoteLine__c[] quoteLineList = (SBQQ__QuoteLine__c [])TestFactory.createSObjectList(new SBQQ__QuoteLine__c(),1);
        quoteLineList[0].SBQQ__Quote__c= quoteList[0].Id;
        quoteLineList[0].SBQQ__Product__c= productList[0].Id;
        
        insert quoteLineList;
    }
    @isTest
    public static void insertApproval(){
        
        SBQQ__Quote__c quote= [select Id,cur_CreditLimit__c,dtm_CreditLimitCheckDate__c from SBQQ__Quote__c LIMIT 1];
        
        sbaa__Approval__c appr = new sbaa__Approval__c();
        appr.sbaa__Status__c = 'Requested';
        appr.Quote__c = quote.Id;
        appr.sbaa__RecordField__c = 'Quote__c';
        appr.sbaa__ApprovalStep__c = 1;
        insert appr;
        
        sbaa__Approval__c approval = [SELECT Id,cur_CreditLimit__c,dtm_CreditLimitCheckDate__c from sbaa__Approval__c LIMIT 1];
        
        Test.startTest();
        System.assertEquals( approval.cur_CreditLimit__c, quote.cur_CreditLimit__c);
        System.assertEquals(approval.dtm_CreditLimitCheckDate__c, quote.dtm_CreditLimitCheckDate__c);
        Test.stopTest();
    }
    
}