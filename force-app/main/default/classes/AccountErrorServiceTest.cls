@IsTest
public class AccountErrorServiceTest {
    
    @IsTest
    static void testSuccessfulErrorHandling() {
        // Create a test Account using TestFactory
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].pkl_Status__c = 'Sent to Athena';
        insert testAccountList;
        Account testAccount = testAccountList[0];
        
        // Prepare test request body for REQ5
        String requestBody = '{"businessPartnerCreateError": {' +
            '"Id": "' + testAccount.Id + '",' +
            '"Status Code": "400",' +
            '"Status Text": "Creation of Business Partner in Athena Failed",' +
            '"CorrelationId": "test-correlation-123"' +
        '}}';
        
        Test.startTest();
        // Call the AccountErrorService method
        String responseString = AccountErrorService.handlePostRequest(requestBody);
        Test.stopTest();
        
        // Parse response (RESP5 format)
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        
        // Assert that the response matches expected RESP5 format
        System.assertEquals('0', response.get('errorcode'), 'Error code should be 0 for success');
        System.assertEquals('Error processed successfully', response.get('errorMessage'), 'Success message should match');
        System.assertEquals('test-correlation-123', response.get('correlationId'), 'CorrelationId should match');
        System.assertEquals(String.valueOf(testAccount.Id), response.get('Id'), 'Account Id should match');
        
        // Verify account status was updated to "Error in sending to Athena"
        Account updatedAccount = [SELECT pkl_Status__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('Error in sending to Athena', updatedAccount.pkl_Status__c, 'Account status should be updated to Error in sending to Athena');
        
        // Verify that the response is not empty
        System.assertNotEquals(responseString, null, 'Response should not be null');
        System.assertNotEquals(responseString, '', 'Response should not be empty');
    }
    
    @IsTest
    static void testMultipleAccountsProcessing() {
        // Create multiple test Accounts using TestFactory
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 3);
        for (Integer i = 0; i < testAccountList.size(); i++) {
            testAccountList[i].pkl_Status__c = 'Sent to Athena';
        }
        insert testAccountList;
        
        Test.startTest();
        
        // Process error for each account
        for (Integer i = 0; i < testAccountList.size(); i++) {
            Account testAccount = testAccountList[i];
            
            String requestBody = '{"businessPartnerCreateError": {' +
                '"Id": "' + testAccount.Id + '",' +
                '"Status Code": "400",' +
                '"Status Text": "Creation of Business Partner in Athena Failed",' +
                '"CorrelationId": "correlation-' + i + '"' +
            '}}';
            
            String responseString = AccountErrorService.handlePostRequest(requestBody);
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
            
            // Assert successful processing for each account
            System.assertEquals('0', response.get('errorcode'), 'Error code should be 0 for account ' + i);
            System.assertEquals('correlation-' + i, response.get('correlationId'), 'CorrelationId should match for account ' + i);
        }
        
        Test.stopTest();
        
        // Verify all accounts have been updated
        List<Account> updatedAccounts = [SELECT Id, pkl_Status__c FROM Account WHERE Id IN :testAccountList];
        System.assertEquals(3, updatedAccounts.size(), 'All 3 accounts should be found');
        
        for (Account acc : updatedAccounts) {
            System.assertEquals('Error in sending to Athena', acc.pkl_Status__c, 'All accounts should have error status');
        }
    }
}