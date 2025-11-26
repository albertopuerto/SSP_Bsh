@IsTest
private class AthenaBusinessPartnerService_Test {

    @TestSetup
    private static void setupUserAccess() {

        User usr = (User) TestFactory.createSObject(new User(),'TestFactoryDefaults.IntegrationUserDefaults', true);

        ID permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'BusinessPartnerAPI'].Id;

        TestFactory.createSObject(new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = usr.Id), true);

    }

    private static User getIntegrationUser(){
        return [SELECT Id FROM User WHERE Alias = 'userInt' LIMIT 1];
    }

     /**
     * @description Creates minimal reference data required by the service:
     *              one SalesArea__c and one BoschPartnerFunction__c.
     */
    private static void setupReferenceData(){

        TestFactory.createSObject(new SalesArea__c(pkl_DistributionChannel__c = 'A1', pkl_Division__c = '01', pkl_SalesOrg__c = 'DEM5'), true);
        TestFactory.createSObject(new BoschPartnerFunction__c(txt_PartnerFunction__c = 'SP'), true);

    }

    /**
     * @description New Account, SalesAreaLink__c and BoschPartner_PartnerFunction__c are created.
     */
    @IsTest
    static void testProcessCreateNew() {

        String testJson = AthenaTestDataFactory.getValidPayload();
        User testUser = getIntegrationUser();
        setupReferenceData();

        AthenaBusinessPartnerDTO dto = AthenaBusinessPartnerDTO.fromJson(testJson);

        System.runAs(testUser){
            Test.startTest();
            AthenaBusinessPartnerService.SvcResult res = AthenaBusinessPartnerService.process(dto);
            Test.stopTest();

            Assert.areEqual(true, res.isCreated, 'Expected isCreated = true for new Account');
            Assert.areNotEqual(null, res.accountId, 'AccountId should not be null');
            Assert.areNotEqual(null, res.salesAreaLinkId, 'SalesAreaLink__c should be created');
            Assert.areNotEqual(null, res.partnerFunctionId, 'BoschPartner_PartnerFunction__c should be created');

            // Check if Account exists
            Account acc = [SELECT Id, Name, txt_AthenaUUID__c, CurrencyIsoCode
                        FROM Account
                        WHERE Id = :res.accountId];
            Assert.areEqual('1000904207', acc.txt_AthenaUUID__c, 'Account should exist.');
         }
    }

    /**
     * @description Existing Account is updated (not created again).
     */
    @IsTest
    static void testProcessUpdateExisting() {

        String testJson = AthenaTestDataFactory.getValidPayload();
        User testUser = getIntegrationUser();
        setupReferenceData();

        AthenaBusinessPartnerDTO dtoCreate = AthenaBusinessPartnerDTO.fromJson(testJson);

        System.runAs(testUser){
            Test.startTest();
            AthenaBusinessPartnerService.SvcResult resCreate = AthenaBusinessPartnerService.process(dtoCreate);

            Id accId = resCreate.accountId;
            Assert.areNotEqual(null, accId, 'Account should have been created in first call');

            AthenaBusinessPartnerDTO dtoUpdate = AthenaBusinessPartnerDTO.fromJson(testJson);
            dtoUpdate.organizationName = 'Updated Org Name';


            AthenaBusinessPartnerService.SvcResult resUpdate = AthenaBusinessPartnerService.process(dtoUpdate);
            Test.stopTest();

            Assert.areEqual(accId, resUpdate.accountId, 'Should update the same Account');

            Account accAfter = [SELECT Name FROM Account WHERE Id = :accId];
            Assert.areEqual('Updated Org Name', accAfter.Name, 'Org should be updated.');
        }
    }

}