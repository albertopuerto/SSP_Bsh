@isTest
public class SalesAreaLinkTriggerHandler_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create a test Account using TestFactory
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert testAccountList;
        
        SalesArea__c sal = (SalesArea__c)TestFactory.createSObject(new SalesArea__c(), false);
        sal.pkl_DistributionChannel__c = '01';
        sal.pkl_Division__c = '00';
        sal.pkl_SalesOrg__c = '0001';
        insert sal;
    }
    
    @isTest
    static void testHandleBeforeInsert_SingleRecord_Success() {
        // Get test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        SalesArea__c testSalesArea = [SELECT Id FROM SalesArea__c LIMIT 1];        
        Test.startTest();
        
        // Create a new SalesAreaLink record
        SalesAreaLink__c newRecord = new SalesAreaLink__c(
            mdr_Account__c = testAccount.Id,
            mdr_SalesArea__c = testSalesArea.Id,
            pkl_Currency__c = 'EUR',
            pkl_CustPricProcedure__c = '01',
            pkl_INCOTerms1__c = 'CPT - Carriage Paid To',
            pkl_PaymentTerms__c = 'Net 15',
            pkl_ShippingConditions__c = '0A',
            txt_INCOTerms2__c = 'test'
        );
        
        insert newRecord;
        
        Test.stopTest();
        
        // Verify the record was inserted successfully
        List<SalesAreaLink__c> insertedRecords = [SELECT Id FROM SalesAreaLink__c WHERE Id = :newRecord.Id];
        System.assertEquals(1, insertedRecords.size(), 'Record should be inserted successfully');
    }
    
    @isTest
    static void testHandleBeforeInsert_DuplicateRecord_Error() {
        // Get test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        SalesArea__c testSalesArea = [SELECT Id FROM SalesArea__c LIMIT 1];
        
        // Create an existing SalesAreaLink record
        SalesAreaLink__c existingRecord = new SalesAreaLink__c(
            mdr_Account__c = testAccount.Id,
            mdr_SalesArea__c = testSalesArea.Id,
            pkl_Currency__c = 'EUR',
            pkl_CustPricProcedure__c = '01',
            pkl_INCOTerms1__c = 'CPT - Carriage Paid To',
            pkl_PaymentTerms__c = 'Net 15',
            pkl_ShippingConditions__c = '0A',
            txt_INCOTerms2__c = 'test'
        );
        insert existingRecord;
        
        Test.startTest();
        
        // Try to create a duplicate record
        SalesAreaLink__c duplicateRecord = new SalesAreaLink__c(
            mdr_Account__c = testAccount.Id,
            mdr_SalesArea__c = testSalesArea.Id,
            pkl_Currency__c = 'EUR',
            pkl_CustPricProcedure__c = '01',
            pkl_INCOTerms1__c = 'CPT - Carriage Paid To',
            pkl_PaymentTerms__c = 'Net 15',
            pkl_ShippingConditions__c = '0A',
            txt_INCOTerms2__c = 'test'
        );
        
        Database.SaveResult result = Database.insert(duplicateRecord, false);
        
        Test.stopTest();
        
        // Verify the duplicate record was not inserted and error was added
        System.assertEquals(false, result.isSuccess(), 'Sales Data Customer record already exist for combination of: Sales Organization, Distribution Channel and Division');
        System.assert(result.getErrors().size() > 0, 'Error should be present');
        System.assert(result.getErrors()[0].getMessage().contains('Sales Data Customer record already exist'), 
                     'Error message should contain duplicate message');
    }
}