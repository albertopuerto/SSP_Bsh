@isTest
private class AthenaAccountNotificationBatchTest {
    
    @testSetup
    static void setupTestData() {
        User currentUser = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()];
        
        // Create test accounts with current user as owner
        Account oldAccount = (Account)TestFactory.createSObject(new Account(), false);
            oldAccount.Name = 'Test Account Old';
            oldAccount.pkl_Status__c = 'Created in Athena';
            oldAccount.dtm_DatetimeofcreationinAthena__c = System.now().addDays(-16);
            oldAccount.OwnerId = currentUser.Id;
        insert oldAccount;
       
    }
    
    @isTest
    static void testBatchExecution() {         
        
        Test.startTest();
        
        // Execute the batch job
        AthenaAccountNotificationBatch batch = new AthenaAccountNotificationBatch();
        Database.executeBatch(batch);        
        Test.stopTest();        
       DateTime fourteenDaysAgo = System.now().addDays(-14);
        List<Account> selectedAccounts = [
            SELECT Id, Name, OwnerId, Owner.Email, Owner.Name, 
                   pkl_Status__c, dtm_DatetimeofcreationinAthena__c 
            FROM Account 
            WHERE pkl_Status__c = 'Bosch Partner Number not Received' 
            AND dtm_DatetimeofcreationinAthena__c <= :fourteenDaysAgo
        ];
        System.assertEquals(1, selectedAccounts.size(), 'Retrieved 1 account');
    }
    
    @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        
        // Test the schedulable interface
        AthenaAccountNotificationBatch schedulable = new AthenaAccountNotificationBatch();
        String jobId = System.schedule('Test Athena Batch Job', '0 0 1 * * ?', schedulable);
        
        Test.stopTest();
        
        // Verify job was scheduled
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
    }
}