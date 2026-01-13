@IsTest
public class AgreementPartyControllerTest {
    private static Apttus_AgreementParty__c buildValidParty(Id agreementId, Id accountId) {
        return new Apttus_AgreementParty__c(
            mdr_Agreement__c = agreementId,
            pkl_PartyRole__c = 'Customer',
            lkp_AgreementParty__c = accountId
        );
    }
    @IsTest
    static void testCreateAgreementParties_success() {        
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();        
        agreement.Name = 'Test Agreement';
        agreement.OwnerId = userinfo.getUserId();
        agreement.Apttus__Contract_End_Date__c = System.Today() + 5;
        insert agreement;

        Account acct = new Account();
        acct.Name = 'Test Account';        
    	acct.Type='Internal';
        acct.pkl_Language__c = 'German';
		
        insert acct;        
        
        Apttus_AgreementParty__c party = buildValidParty(agreement.Id, acct.Id);

        Test.startTest();
        Boolean result = AgreementPartyController.createAgreementParties(new List<Apttus_AgreementParty__c>{ party });
        Test.stopTest();

        System.assertEquals(true, result, 'Expected insert to succeed');
                
        Apttus_AgreementParty__c insertedParty = [SELECT Id, mdr_Agreement__c, lkp_AgreementParty__c, pkl_PartyRole__c 
                                                 FROM Apttus_AgreementParty__c 
                                                 WHERE Id = :party.Id];
        System.assertEquals(agreement.Id, insertedParty.mdr_Agreement__c);
        System.assertEquals(acct.Id, insertedParty.lkp_AgreementParty__c);
    }
    
    @IsTest
    static void testCreateAgreementParties_missingFields() {        
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(Name = 'Test Agreement 2');
        insert agreement;
        
        Apttus_AgreementParty__c invalidParty = new Apttus_AgreementParty__c(
            mdr_Agreement__c = agreement.Id,
            pkl_PartyRole__c = '',
            lkp_AgreementParty__c = null
        );

        Test.startTest();
        Boolean result = AgreementPartyController.createAgreementParties(new List<Apttus_AgreementParty__c>{ invalidParty });
        Test.stopTest();

        System.assertEquals(false, result, 'Expected validation to fail');
    }

    @IsTest
    static void testGetRolePicklistValues() {
        Test.startTest();
        List<String> roles = AgreementPartyController.getRolePicklistValues();
        Test.stopTest();

        System.assertNotEquals(0, roles.size(), 'Picklist values should not be empty');
        System.assert(roles.contains('Customer'), 'Expected Customer role to be present');
    }

    @IsTest
    static void testGetSignatureTypeValues() {
        Test.startTest();
        List<String> signature = AgreementPartyController.getSignatureTypeValues();
        Test.stopTest();

        System.assertNotEquals(0, signature.size(), 'Picklist values should not be empty');
        System.assert(signature.contains('Wet Ink Signature'), 'Expected Wet Ink Signature signature to be present');
    } 
    
}