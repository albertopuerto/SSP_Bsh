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
    public static void testPropagateRole(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        
        System.runAs(productManagerUser){
            Test.startTest();
            
            // Verify ACR exists with correct role
            AccountContactRelation acr = [SELECT Id, mpkl_PartnerRoles__c 
                                          FROM AccountContactRelation 
                                          WHERE ContactId = :testContact.Id 
                                          AND AccountId = :testAccount.Id 
                                          LIMIT 1];
            
            Assert.areEqual('0001', acr.mpkl_PartnerRoles__c, 'Role should be 0001');
            Assert.areNotEqual('0003', acr.mpkl_PartnerRoles__c, 'Role is incorrect should be 0001');
            Test.stopTest();
        }
    }
    @IsTest
    public static void testUpdatePartnerRoles(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id, mpkl_RoleMainAccount__c FROM Contact LIMIT 1];
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        
        System.runAs(productManagerUser){
            Test.startTest();
            
            // Update the contact's main role to trigger the flow
            testContact.mpkl_RoleMainAccount__c = '0003';
            update testContact;
            
            Test.stopTest();
            
            // Verify ACR was updated with the new role from contact
            AccountContactRelation acr = [SELECT Id, mpkl_PartnerRoles__c 
                                          FROM AccountContactRelation 
                                          WHERE ContactId = :testContact.Id 
                                          AND AccountId = :testAccount.Id 
                                          LIMIT 1];
            
            Assert.areEqual('0003', acr.mpkl_PartnerRoles__c, 'Partner Role should be updated to 0003');
            Assert.areNotEqual('0001', acr.mpkl_PartnerRoles__c, 'Partner Role should no longer be 0001');
        }
    }
}