@IsTest
public with sharing class AthenaBusinessPartnerDTO_Test {

    //Creates test user
    private static User setupTestUser() {
        return (User) TestFactory.createSObject(new User(),'TestFactoryDefaults.IntegrationUserDefaults', true);
    }

    /**
    *@description create and run payload
    */
    @IsTest
    public static void testFromJson(){

        User testUser = setupTestUser();

        System.runAs(testUser){

            String testValidJson = AthenaTestDataFactory.loadJson('AthenaBPValidPayload');

            Test.startTest();
            AthenaBusinessPartnerDTO dto = AthenaBusinessPartnerDTO.fromJson(testValidJson);
            AthenaBusinessPartnerDTO dtoEmpty = AthenaBusinessPartnerDTO.fromJson('');
            Test.stopTest();

            Assert.areNotEqual(null, dto, 'DTO must not be null.');
            Assert.areEqual('1000904207', dto.boschPartnerNumber, 'Missmatch for boschPartnerNumber.');
            Assert.areEqual('Organization', dto.boschPartnerCategory, 'Category should be "Organization".');
            Assert.areEqual('Tech', dto.searchTerm1, 'Should be "Tech"');
            Assert.areEqual('+34915551234', dto.phone, 'Phone number is not correct.');


        }
    }
}