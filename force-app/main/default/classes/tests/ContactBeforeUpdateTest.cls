/**
* @author       APB
* @description  ContactBeforeUpdateTest: Class used to test the flow propagate main contact before update
*/
@isTest
public class ContactBeforeUpdateTest {

    /**
    * @author       APB
    * @description  Method used to create the records
    */
    @testSetup
    public static void createRecords(){

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


    @IsTest
    public static void succesfullUpdateOfRoleMainAccountField(){
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        Account testAccount = [Select Id from Account LIMIT 1];
        Contact testContact = [Select Id from Contact LIMIT 1];
        System.runAs(productManagerUser){

            AccountContactRelation acr = [Select Id,mpkl_PartnerRoles__c from AccountContactRelation WHERE ContactId =: testContact.Id AND AccountId =: testAccount.Id LIMIT 1];
            Assert.areEqual('0001', acr.mpkl_PartnerRoles__c, 'Role should be 0001');

            testContact.mpkl_RoleMainAccount__c = '0003;0001;';
            update testContact;

            AccountContactRelation acrModified = [Select Id,mpkl_PartnerRoles__c from AccountContactRelation WHERE ContactId =: testContact.Id AND AccountId =: testAccount.Id LIMIT 1];
            Assert.areEqual('0001;0003', acrModified.mpkl_PartnerRoles__c, 'Role should be 0001;0003');
        }
    }

    @IsTest
    public static void incorrectUpdateOfRoleMainAccountField(){
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        System.runAs(productManagerUser){

            Account testAccount = [Select Id from Account LIMIT 1];
            Contact testContact = [Select Id from Contact LIMIT 1];

            AccountContactRelation acr = [Select Id,mpkl_PartnerRoles__c from AccountContactRelation WHERE ContactId =: testContact.Id AND AccountId =: testAccount.Id LIMIT 1];
            Assert.areEqual('0001', acr.mpkl_PartnerRoles__c, 'Role should be 0001');

            testContact.mpkl_RoleMainAccount__c = '0003;0001;';
            update testContact;

            AccountContactRelation acrModified = [Select Id,mpkl_PartnerRoles__c from AccountContactRelation WHERE ContactId =: testContact.Id AND AccountId =: testAccount.Id LIMIT 1];
            Assert.areNotEqual('0001', acrModified.mpkl_PartnerRoles__c, 'Incorrect data, the role should be 0001;0003');
        }
    }

}