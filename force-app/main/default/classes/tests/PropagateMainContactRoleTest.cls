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
        
        // Populate ACR Partner Roles to satisfy validation rule
        AccountContactRelation acr = [SELECT Id, mpkl_PartnerRoles__c 
                                      FROM AccountContactRelation 
                                      WHERE ContactId = :testContactList[0].Id 
                                      AND AccountId = :testAccountList[0].Id 
                                      LIMIT 1];
        
        acr.mpkl_PartnerRoles__c = '0001';
        update acr;
    }
    
    @IsTest
    public static void testPropagateRoleFromContactToACR(){
        
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id, mpkl_RoleMainAccount__c FROM Contact LIMIT 1];
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        
        System.runAs(productManagerUser){
            Test.startTest();
            
            // Update Contact role
            testContact.mpkl_RoleMainAccount__c = '0003';
            update testContact;
            
            Test.stopTest();
            
            // Verify ACR was updated by Flow
            AccountContactRelation acr = [SELECT Id, mpkl_PartnerRoles__c 
                                          FROM AccountContactRelation 
                                          WHERE ContactId = :testContact.Id 
                                          AND AccountId = :testAccount.Id 
                                          LIMIT 1];
            
            Assert.areEqual('0003', acr.mpkl_PartnerRoles__c, 'ACR Partner Role should be updated to 0003');
        }
    }
    
    @IsTest
    public static void testPropagateRoleFromACRToContact(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id, mpkl_RoleMainAccount__c FROM Contact LIMIT 1];
        
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        System.runAs(productManagerUser){
            Test.startTest();
            
            // Get the ACR
            AccountContactRelation acr = [SELECT Id, mpkl_PartnerRoles__c 
                                          FROM AccountContactRelation 
                                          WHERE ContactId = :testContact.Id 
                                          AND AccountId = :testAccount.Id 
                                          LIMIT 1];
            
            // Update Partner Roles on ACR - this should trigger the Flow
            acr.mpkl_PartnerRoles__c = '0003';
            update acr;
            
            Test.stopTest();
            
            // Verify Contact was updated by Flow
            Contact updatedContact = [SELECT Id, mpkl_RoleMainAccount__c 
                                      FROM Contact 
                                      WHERE Id = :testContact.Id];
            Assert.areEqual('0003', updatedContact.mpkl_RoleMainAccount__c, 'Contact Role should be updated to 0003');
        }
    }
}