/**
* @author       APB
* @description  PropagateMainContactRoleTest: Class used to test the flow propagate main contact role
*/
@IsTest
public class PropagateMainContactRoleTest {

    @IsTest
    public static void testPropagateRole(){

        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);

        System.runAs(productManagerUser){
            Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
            insert testAccountList;

            Contact[] testContactList = (Contact[])TestFactory.createSObjectList(new Contact(), 1);
            testContactList[0].AccountId = testAccountList[0].Id;
            testContactList[0].mpkl_RoleMainAccount__c = '0001';
            testContactList[0].pkl_Language__c = 'English';
            testContactList[0].pkl_Status__c = 'Active';
            testContactList[0].pkl_AccountGroup__c = 'ETDE Contact ETCN Contact';

            insert testContactList;

            AccountContactRelation acr = [Select Id,mpkl_PartnerRoles__c from AccountContactRelation WHERE ContactId =: testContactList[0].Id AND AccountId =: testAccountList[0].Id LIMIT 1];
            Assert.areEqual('0001', acr.mpkl_PartnerRoles__c, 'Role should be 0001');
        }
    }
}