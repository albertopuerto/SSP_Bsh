@isTest
public class OrderSelectorTest {

    @testSetup
    static void initRecords(){

        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c= '3123213';
        testAccountList[0].BillingCountry= 'Germany';
        testAccountList[0].BillingCountryCode= 'DE';
        insert testAccountList;
        
        Order[] orderList = (Order [])TestFactory.createSObjectList(new Order(),1);
        orderList[0].Status= 'Draft';
        orderList[0].AccountId= testAccountList[0].Id;
        insert orderList;
        
    }
    
    @isTest
    static void getOrder(){
        
        Set<Id> idSet = new Set<Id>();
        Test.startTest();
        Order orderTest = [SELECT Id,Status,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c from Order LIMIT 1];
		idSet.add(orderTest.Id);        
        OrderSelector os = new OrderSelector();
        List<Order> selectOrder = os.selectOrderInfo(idSet);
        Assert.areNotEqual(null, selectOrder[0], 'The quote was retrieved succesfully');
        Test.stopTest();
    }
    
}