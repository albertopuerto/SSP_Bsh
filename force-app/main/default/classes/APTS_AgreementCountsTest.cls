@isTest
private class APTS_AgreementCountsTest {
    @isTest static void myUnitTest() {
		
        //Create a new Account
        Account testacc = new Account();
        testacc.Name = 'Test Account';
        testAcc.Role__c='ETDE Domestic Customer';
    	testAcc.Type='Internal';
        testAcc.pkl_INCOTerms1__c = 'CIF - Cost, Insurance, and Freight';
        testAcc.pkl_INCOTerms1__c = 'DAP – Delivered at Place';
        testAcc.txt_INCOTerms2__c = 'Wolfsburg';
        testAcc.pkl_Language__c = 'German';
        testAcc.pkl_PaymentTerms__c = 'Net 15';
        insert testacc;
        
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;
        
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.Apttus__Account__c = testacc.Id;
        agreement.Name = 'Test Agreement';
        agreement.OwnerId = userinfo.getUserId();
        agreement.Apttus__Contract_End_Date__c = System.Today() + 5;
        insert agreement;
        
        //Start Test
        Test.startTest();
        Integer userAgreementCount =  APTS_AgreementCounts.getActionRequiredCount();
        Integer needsAttentionCount =  APTS_AgreementCounts.getNeedsAttentionCount();
        String listView =  APTS_AgreementCounts.getListViewDetail('Apttus__APTS_Agreement__c', 'All');
        String listView2 = APTS_AgreementCounts.getListViewDetail('Agreement', 'View');
        
        String dashboard = APTS_ListViewIdGeneric.getDashboardId('');
        //String dashboard1 = APTS_ListViewIdGeneric.getDashboardId('Dashboard');
        
        //Stop Test
        Test.stopTest();
        
        
    }
}