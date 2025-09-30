@isTest
public class CreditGetAuthorizationsTest {
	
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
	static void testAuthCallouts() {
    	// Set mock callout class
    	
        Account testAccount = [SELECT Id from Account LIMIT 1];
        SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c from SBQQ__Quote__c LIMIT 1];
        quoteTest.SBQQ__Status__c='Accepted';
        update quoteTest;
        
        Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new VertexMockClass());
    	// This causes a fake response to be sent
    	// from the class that implements HttpCalloutMock.
    	HttpResponse response = CreditLimitCallouts.startVertexCallouts(false, true, false, quoteTest.Id, quoteTest, null);
    	// Verify that the response received contains fake values
    	String contentType = response.getHeader('Content-Type');
    	Assert.isTrue(contentType == 'application/json');
    	String actualValue = response.getBody();
    	System.debug(response.getBody());
    	CreditLimitGetAuthorizations.getAuthorizationToken(testAccount.Id);
        Test.stopTest();
	}
}