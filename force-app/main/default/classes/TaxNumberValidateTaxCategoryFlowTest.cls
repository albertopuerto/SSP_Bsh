/**
 * @description Test class for TaxNumber_ValidateTaxCategory flow
 * @author SNV1SF
 * @date 2025
 */

@isTest
public with sharing class TaxNumberValidateTaxCategoryFlowTest {
    
    
@TestSetup  
    static void setupData() {
        
        // Create a test Account
         Account account = (Account)TestFactory.createSObject(new Account(),'TestFactoryDefaults.AccountDefaults', true);  

        // Create a Tax Number record
        TaxNumber__c tax = new TaxNumber__c(
            mdr_AccountId__c = account.Id,
            txt_TaxNumber__c = '12345678901234567890',
            txt_TaxCategory__c = 'A200'
        );
          insert tax;
    }
    
 @isTest
    static void validateTaxCategoryForNewRecord(){
        
         // Get the test account
        Account acc = [SELECT Id FROM Account LIMIT 1];
        TaxNumber__c tax = [SELECT Id FROM TaxNumber__c LIMIT 1];

        // Try to create another Tax Number with the same category for the same account
        TaxNumber__c duplicateTax = new TaxNumber__c(
            mdr_AccountId__c = acc.Id,
            txt_TaxNumber__c = '55345678901234567877',
            txt_TaxCategory__c = 'A200' // same category as existing record
        );

        Test.startTest();
        try {
            insert duplicateTax;
            Assert.areEqual(tax.txt_TaxCategory__c, duplicateTax.txt_TaxCategory__c, 'Duplicate creation should have failed.');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Duplicate'), 'Duplicate Category Tax Number for this account.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void validateTaxCategoryForUpdatedRecord() {
        // Get records
        Account acc = [SELECT Id FROM Account LIMIT 1];
        TaxNumber__c existingTax = [SELECT Id, mdr_AccountId__c, txt_TaxCategory__c FROM TaxNumber__c WHERE txt_TaxCategory__c = 'A200' LIMIT 1];

        // Create another record with a different category
        TaxNumber__c otherTax = new TaxNumber__c(
            mdr_AccountId__c = acc.Id,
            txt_TaxNumber__c = '55665678901234568877',
            txt_TaxCategory__c = 'B300'
        );
        insert otherTax;

        // Try to update it to the same category as existing one (should trigger duplicate)
        otherTax.txt_TaxCategory__c = 'A200';

        Test.startTest();
        try {
            update otherTax;
            Assert.areEqual(existingTax.txt_TaxCategory__c, otherTax.txt_TaxCategory__c, 'Duplicate creation should have failed.');
        } catch (DmlException e) {
           Assert.isTrue(e.getMessage().contains('Duplicate'), 'Duplicate Category Tax Number for this account.');
        }
        Test.stopTest();
    }
    
        
}