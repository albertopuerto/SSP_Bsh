/**
* @description Trigger to create Price Elements when Order Items are inserted
* @author ...
* @date 2025
*/
trigger OrderItemTrigger on OrderItem (after insert) {
    fflib_SObjectDomain.triggerHandler(OrderItemHandler.class);
}