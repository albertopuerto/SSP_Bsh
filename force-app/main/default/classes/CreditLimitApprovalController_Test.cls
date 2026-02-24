@isTest
public class CreditLimitApprovalController_Test {

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
    static void quoteDontHaveToolCoordinator(){
        Test.startTest();
        SBQQ__Quote__c quote= [Select id,lkp_ToolCoordinator__c from SBQQ__Quote__c LIMIT 1];
        System.assertEquals(null, quote.lkp_ToolCoordinator__c);
        Boolean hasSubProducts= CreditLimitApprovalController.hasSubsProducts(quote.Id);
        System.assertEquals(false,hasSubProducts);
        Test.stopTest();
    }
    
    @isTest
    static void quoteHaveToolCoordinatorButTheProductHasNotTheType(){
        Test.startTest();
        SBQQ__Quote__c quote= [Select id,lkp_ToolCoordinator__c from SBQQ__Quote__c LIMIT 1];
        Contact cont = [SELECT id from Contact LIMIT 1];
        quote.lkp_ToolCoordinator__c= cont.Id;
        update quote;
        System.assertNotEquals(null, quote.lkp_ToolCoordinator__c);
        Boolean hasSubProducts= CreditLimitApprovalController.hasSubsProducts(quote.Id);
        System.assertEquals(false,hasSubProducts);
        Test.stopTest();
    }
    
    @isTest
    static void quoteHaveToolCoordinatorAndTheProductHasTheType(){
        Test.startTest();
        SBQQ__Quote__c quote= [Select id,lkp_ToolCoordinator__c from SBQQ__Quote__c LIMIT 1];
        Contact cont = [SELECT id from Contact LIMIT 1];
        Product2 product= [select id from Product2 LIMIT 1];
        product.pkl_MaterialType__c= 'SUBS';
        update product;
       
        Boolean hasSubProducts= CreditLimitApprovalController.hasSubsProducts(quote.Id);
        System.assertEquals(true,hasSubProducts);
        Test.stopTest();
    }
    
    @isTest
    static void creditLimitGetQuote(){
        Test.startTest();
        
        SBQQ__Quote__c quoteToSend= [Select id from SBQQ__Quote__c LIMIT 1];
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'vertexSuccess'];
		String vertexBody = sr.Body.toString();
        HttpCalloutMock res1 = new HTTPMockGenerator(200, vertexBody);
            
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'creditLimitQuoteOrderExceded'];
		String creditLimitBody = sr2.Body.toString();
        HttpCalloutMock res2 = new HTTPMockGenerator(200, creditLimitBody);
        String remainingUrlVertex = '/sap-tax-service/tax/v1/quote';
        HttpMultiRequestMockGenerator multiMock = new HttpMultiRequestMockGenerator();
        multiMock.putMock('https://api.status.salesforce.com/v1/instances/DEU114S/status',new HTTPMockGenerator(200, '{"status":"OK"}'));
		multiMock.putMock('callout:vertex_usernamePass'+ remainingUrlVertex,res1);
		multiMock.putMock('callout:creditLimitCheckOuathCallout',res2);
        
        Test.setMock(HttpCalloutMock.class, multiMock);
        SBQQ__Quote__c quote= CreditLimitApprovalController.callCreditLimit(quoteToSend.Id);
        
        System.assertNotEquals(null, quote.cur_CreditLimit__c);
        
        System.assertNotEquals(null, quote.cur_Current_Credit_Limit_including_VAT__c);
         
        Test.stopTest();
    }
}