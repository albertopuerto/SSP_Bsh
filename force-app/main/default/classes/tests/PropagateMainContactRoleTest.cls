/**
* @author       APB
* @description  PropagateMainContactRoleTest: Class used to test the flow propagate main contact role
*/
@IsTest
public class PropagateMainContactRoleTest {

    /**
    * @author       APB
    * @description  Method used to create the records
    */
    @testSetup
    public static void createRecords(){


        FlowDefinitionView flowDefinitionPropagateMainContactRole = [SELECT Id,IsActive,ApiName from FlowDefinitionView WHERE ApiName = 'flw_propagate_main_contact_role' ];
        FlowDefinitionView flowDefinitionContactBeforeUpdate = [SELECT Id,IsActive,ApiName from FlowDefinitionView WHERE ApiName = 'flw_Contact_beforeUpdate' ];
        if(flowDefinitionPropagateMainContactRole.IsActive == true && flowDefinitionContactBeforeUpdate.IsActive == true){
            Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
            insert testAccountList;

            Contact[] testContactList = (Contact[])TestFactory.createSObjectList(new Contact(), 1);
            testContactList[0].AccountId = testAccountList[0].Id;
            testContactList[0].mpkl_RoleMainAccount__c = '0001';
            testContactList[0].pkl_Language__c = 'English';
            testContactList[0].pkl_Status__c = 'Active';
            testContactList[0].pkl_AccountGroup__c = 'ETDE Contact ETCN Contact';

            insert testContactList;
        }
    }

    @IsTest
    public static void testPropagateRole(){

        FlowDefinitionView flowDefinitionPropagateMainContactRole = [SELECT Id,IsActive,ApiName from FlowDefinitionView WHERE ApiName = 'flw_propagate_main_contact_role' ];
        FlowDefinitionView flowDefinitionContactBeforeUpdate = [SELECT Id,IsActive,ApiName from FlowDefinitionView WHERE ApiName = 'flw_Contact_beforeUpdate' ];
        if(flowDefinitionPropagateMainContactRole.IsActive == true && flowDefinitionContactBeforeUpdate.IsActive == true){
            Account testAccount = [Select Id from Account LIMIT 1];
            Contact testContact = [Select Id from Contact LIMIT 1];
            User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);

            System.runAs(productManagerUser){
                Test.startTest();
                AccountContactRelation acr = [Select Id,mpkl_PartnerRoles__c from AccountContactRelation WHERE ContactId =: testContact.Id AND AccountId =: testAccount.Id LIMIT 1];
                Assert.areEqual('0001', acr.mpkl_PartnerRoles__c, 'Role should be 0001');
                Assert.areNotEqual('0003', acr.mpkl_PartnerRoles__c, 'Role is incorrect should be 0001');
                Test.stopTest();
            }
        }
    }
}
