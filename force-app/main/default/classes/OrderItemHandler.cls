public with sharing class OrderItemHandler extends fflib_SObjectDomain {
 
    // ️ Required constructor to pass records to the fflib base class
    public OrderItemHandler(List<OrderItem> records) {
        super(records);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OrderItemHandler(sObjectList);
        }
    }

 
    // 🔹 Override onAfterInsert event
    public override void onAfterInsert() {
        List<PriceElement__c> priceElementsToInsert = new List<PriceElement__c>();
 
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { PriceElement__c.SObjectType});
        try {
         for (OrderItem oi : (List<OrderItem>) Records) {
             if (oi == null) continue;
 
                PriceElement__c pe = new PriceElement__c();
                pe.lkp_OrderItem__c = oi.Id;
                pe.num_ConditionRateValue__c = oi.TotalPrice;
                pe.pkl_ConditionCurrency__c = oi.CurrencyIsoCode;
                pe.pkl_ConditionType__c = 'Manual Discount';
                uow.registerNew(pe);
            
         }
            uow.commitWork();
        } catch (Exception ex) {
                System.debug('⚠️ ❌ Failed to insert PriceElements: ' + ex.getMessage());
            }
 
    }
}