@IsTest
public with sharing class ContentDocumentDomain_Tests {

    //Creates test user
    private static User setupTestUser() {
        return (User) TestFactory.createSObject(new User(),'TestFactoryDefaults.SalesReadUserDefaults', true);
    }

    //Creates a test docunment
    private static Id createDoc(String title) {
        ContentVersion cv = (ContentVersion) TestFactory.createSObject(
            new ContentVersion(
            Title = title,
            PathOnClient = title + '.txt',
            VersionData = Blob.valueOf('file body')
            ),
        true
            );
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
    }

    @IsTest
    static void onAfterDeleteWithNoRecords(){
        User testUser = setupTestUser();

        System.runAs(testUser){
            Test.startTest();
            new ContentDocumentDomain(new List<ContentDocument>()).onAfterDelete();
            Test.stopTest();

            Assert.isTrue(true, 'Method must execute without error when there are no records.');
        }
    }

    @IsTest
    static void deletesRelatedContentWhenDocumentDeleted() {
        User testUser = setupTestUser();

        System.runAs(testUser){
            Id docId = createDoc('Doc-One');

            SBQQ__RelatedContent__c rc = (SBQQ__RelatedContent__c) TestFactory.createSObject(
                new SBQQ__RelatedContent__c(
                SBQQ__ExternalId__c = String.valueOf(docId)
                ),
            true
                );

            Test.startTest();
            delete new ContentDocument(Id = docId);
            Test.stopTest();

            Assert.areEqual(0, [SELECT COUNT() FROM SBQQ__RelatedContent__c WHERE Id = :rc.Id],
            'Related document must be deleted.'
                );
        }
    }

    @IsTest
    static void noErrorWhenNoRelatedContent() {
        User testUser = setupTestUser();

        System.runAs(testUser){
            Id docId = createDoc('No-Relations');

            Test.startTest();
            delete new ContentDocument(Id = docId);
            Test.stopTest();

            Integer cnt = [SELECT COUNT() FROM SBQQ__RelatedContent__c WHERE SBQQ__ExternalId__c = :String.valueOf(docId)];
            Assert.areEqual(0, cnt, 'There should be no related records.');
        }
    }

    @IsTest
    static void bulkDeleteRemovesAllRelated() {
        User testUser = setupTestUser();

        System.runAs(testUser){
            Id d1 = createDoc('Bulk-1');
            Id d2 = createDoc('Bulk-2');
            Id d3 = createDoc('Bulk-3');

            insert new List<SBQQ__RelatedContent__c>{
                new SBQQ__RelatedContent__c(SBQQ__ExternalId__c = String.valueOf(d1)),
                new SBQQ__RelatedContent__c(SBQQ__ExternalId__c = String.valueOf(d2))
            };

            Test.startTest();
            delete new List<ContentDocument>{
                new ContentDocument(Id = d1),
                new ContentDocument(Id = d2),
                new ContentDocument(Id = d3)
            };
            Test.stopTest();

            Integer left = [
            SELECT COUNT() FROM SBQQ__RelatedContent__c
            WHERE SBQQ__ExternalId__c IN :new Set<String>{
            String.valueOf(d1), String.valueOf(d2), String.valueOf(d3)
            }
            ];
            Assert.areEqual(0, left, 'All related records must be deleted.');
        }
    }
}