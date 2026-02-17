@isTest
public class CreditLimitApprovalController_Test {

    @TestSetup
    static void setupTestData() {
        Account testAccountList = (Account)TestFactory.createSObject(new Account(),'TestFactoryDefaults.AccountDefaults', false);
        //testAccountList[0].pkl_PaymentTerms__c= 'Due on receipt';
        System.debug(testAccountList.RecordTypeId);
        insert testAccountList;
        
        Contact[] testContactList = (Contact[])TestFactory.createSObjectList(new Contact(), 1);
        testContactList[0].AccountId = testAccountList.Id;
        insert testContactList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        //quoteList[0].SBQQ__Account__r = testAccountList[0];
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
}