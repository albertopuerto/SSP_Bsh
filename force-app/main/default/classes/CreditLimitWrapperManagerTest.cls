@isTest
public class CreditLimitWrapperManagerTest {

    @testSetup
    static void initObjects(){
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c='123213123';
        insert testAccountList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].CurrencyIsoCode = 'EUR';
        quoteList[0].SBQQ__Account__r = testAccountList[0];
        insert quoteList;
        
        Order[] orderList = (Order [])TestFactory.createSObjectList(new Order(),1);
        orderList[0].AccountId= testAccountList[0].Id;
        insert orderList;
    }
    
    @isTest
	static void createAccountCreditLimitRequest() {
    
    	Account testAccount = [SELECT Id,BillingCountry,CurrencyIsoCode from Account LIMIT 1];
        
    	Test.startTest();
    	
        CreditLimitWrapperManager.createAccountRequest('321323', testAccount.CurrencyIsoCode, testAccount.Id);
        Test.stopTest();
	}
    
    @isTest
	static void createQuoteCreditLimitRequest() {
    
    	SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c,SBQQ__Account__c from SBQQ__Quote__c LIMIT 1];
        quoteTest.Current_Credit_Limit_including_VAT__c=10;
        quoteTest.SBQQ__Status__c='Accepted';
        update quoteTest;
        
    	Test.startTest();
    	
        CreditLimitWrapperManager.createCreditWorthinessRequest('21321312', quoteTest.Current_Credit_Limit_including_VAT__c, quoteTest.CurrencyIsoCode, quoteTest.SBQQ__Account__c);
        Test.stopTest();
	}
    
    @isTest
	static void createOrderCreditLimitRequest() {
    
    	Order orderTest = [SELECT Id,Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c,AccountId from Order LIMIT 1];
        
    	Test.startTest();
    	
        CreditLimitWrapperManager.createCreditWorthinessRequest('21321312', orderTest.Current_Credit_Limit_including_VAT__c, orderTest.CurrencyIsoCode, orderTest.AccountId);
        Test.stopTest();
	}
}