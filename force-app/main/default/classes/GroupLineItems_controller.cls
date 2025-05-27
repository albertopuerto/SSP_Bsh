/**
* @File Name : GroupLineItems_controller.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 8, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 8, 2025 |   | Initial Version
**/

public class GroupLineItems_controller {
	@AuraEnabled
	public static List <aggregateResult> loadOrderGroups(String quoteId) { 
        List <aggregateResult> orderItems = [SELECT SBQQ__QuoteLine__r.SBQQ__Group__c, SBQQ__QuoteLine__r.SBQQ__Group__r.Name, sum(TotalPrice) totalPrice, count(Id) itemsGroup FROM OrderItem WHERE OrderId =: quoteId group by SBQQ__QuoteLine__r.SBQQ__Group__r.Name,  SBQQ__QuoteLine__r.SBQQ__Group__c];
         return orderItems;
    }

	@AuraEnabled
    public static List <OrderItem> loadOrderItems(String groupId) {
        List <OrderItem> orderItems = [SELECT id, Product2.name, ftxt_ProductCode__c, Quantity, TotalPrice from orderitem where SBQQ__QuoteLine__r.SBQQ__Group__c =: groupId];
        return orderItems;
    }
}