@IsTest
public with sharing class AthenaBusinessPartnerWebService_Test {

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
     * @description AC1: New account is created (201).
     */
    @IsTest
    static void testPatchPartnerCreate() {

        String jsonBody = AthenaTestDataFactory.loadJson('AthenaBPValidPayload');
        User testUser = getIntegrationUser();
        setupReferenceData();

        System.runAs(testUser){

            RestRequest req = new RestRequest();
            req.httpMethod  = 'PATCH';
            req.requestUri  = '/services/apexrest/v1/boschpartner';
            req.requestBody = Blob.valueOf(jsonBody);

            RestResponse res = new RestResponse();
            RestContext.request  = req;
            RestContext.response = res;

            Test.startTest();
            AthenaBusinessPartnerWebService.patchPartner();
            Test.stopTest();

            Assert.areEqual(201, res.statusCode, 'Should return 201 for new partner');
            String body = res.responseBody != null ? res.responseBody.toString() : '';
            Assert.areEqual(true, body.contains('SUCCESS'), 'Response should contain SUCCESS');

            // Account should be created
            Account acc = [
                SELECT Id, txt_AthenaUUID__c, Name
                FROM Account
                WHERE txt_AthenaUUID__c = '1000904207'
                LIMIT 1
            ];

            Assert.areEqual('1000904207', acc.txt_AthenaUUID__c, 'Bosch Partner Number is not correct.');

        }
    }

    /**
     * @description AC2: Existing account is updated (200).
     */
    @IsTest
    static void testPatchPartnerUpdate() {

        String jsonBody = AthenaTestDataFactory.loadJson('AthenaBPValidPayload');
        User testUser = getIntegrationUser();
        setupReferenceData();

        System.runAs(testUser){

            Test.startTest();
            //Create PATCH
            RestRequest req1 = new RestRequest();
            req1.httpMethod  = 'PATCH';
            req1.requestUri  = '/services/apexrest/v1/boschpartner';
            req1.requestBody = Blob.valueOf(jsonBody);

            RestResponse res1 = new RestResponse();
            RestContext.request  = req1;
            RestContext.response = res1;

            AthenaBusinessPartnerWebService.patchPartner();

            //Update PATCH
            RestRequest req2 = new RestRequest();
            req2.httpMethod  = 'PATCH';
            req2.requestUri  = '/services/apexrest/v1/boschpartner';
            req2.requestBody = Blob.valueOf(jsonBody);

            RestResponse res2 = new RestResponse();
            RestContext.request  = req2;
            RestContext.response = res2;


            AthenaBusinessPartnerWebService.patchPartner();
            Test.stopTest();

            Assert.areEqual(201, res1.statusCode, 'Should return 201 for new partner');
            Assert.areEqual(200, res2.statusCode, 'Second call should return 200 (update)');

        }
    }

    /**
     * @description Invalid Category validation
     */
    @IsTest
    static void testInvalidCategoryValidation() {

        String jsonBody = AthenaTestDataFactory.loadJson('AthenaBPInvalidCategory');
        User testUser = getIntegrationUser();

        TestFactory.createSObject(new BoschPartnerFunction__c(txt_PartnerFunction__c = 'SP'), true);

        System.runAs(testUser){

            Test.startTest();

            //Create PATCH
            RestRequest req1 = new RestRequest();
            req1.httpMethod  = 'PATCH';
            req1.requestUri  = '/services/apexrest/v1/boschpartner';
            req1.requestBody = Blob.valueOf(jsonBody);

            RestResponse res1 = new RestResponse();
            RestContext.request  = req1;
            RestContext.response = res1;

            AthenaBusinessPartnerWebService.patchPartner();

            Test.stopTest();

            Assert.areEqual(400, res1.statusCode, 'Should get 400');

        }
    }

    /**
     * @description invalid Payload - missmatch with payload keys and Salesforce fields.
     */
    @IsTest
    static void testInvalidPayload() {

        String jsonBody = AthenaTestDataFactory.loadJson('AthenaBPInvalidPayload');
        User testUser = getIntegrationUser();

        TestFactory.createSObject(new BoschPartnerFunction__c(txt_PartnerFunction__c = 'SP'), true);
        TestFactory.createSObject(new SalesArea__c(pkl_DistributionChannel__c = 'A1', pkl_Division__c = '01', pkl_SalesOrg__c = 'DEM5'), true);

        System.runAs(testUser){

            Test.startTest();

            //Create PATCH
            RestRequest req1 = new RestRequest();
            req1.httpMethod  = 'PATCH';
            req1.requestUri  = '/services/apexrest/v1/boschpartner';
            req1.requestBody = Blob.valueOf(jsonBody);

            RestResponse res1 = new RestResponse();
            RestContext.request  = req1;
            RestContext.response = res1;

            AthenaBusinessPartnerWebService.patchPartner();

            Test.stopTest();

            Assert.areEqual(500, res1.statusCode, 'Should get 500');

        }
    }

    /**
     * @description No access test
     */
    @IsTest
    static void testAccessValidations() {

        String jsonBody = AthenaTestDataFactory.loadJson('AthenaBPValidPayload');
        User testUser = (User) TestFactory.createSObject(new User(),'TestFactoryDefaults.IntegrationUserDefaults', true);
        setupReferenceData();

        System.runAs(testUser){

            RestRequest req = new RestRequest();
            req.httpMethod  = 'PATCH';
            req.requestUri  = '/services/apexrest/v1/boschpartner';
            req.requestBody = Blob.valueOf(jsonBody);

            RestResponse res = new RestResponse();
            RestContext.request  = req;
            RestContext.response = res;

            Test.startTest();
            AthenaBusinessPartnerWebService.patchPartner();
            Test.stopTest();

            Assert.areEqual(500, res.statusCode, 'Should return 500');

        }
    }

}