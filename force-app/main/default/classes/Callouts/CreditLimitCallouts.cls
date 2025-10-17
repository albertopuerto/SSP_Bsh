/**
* @author       APB
* @description  CreditLimitCallouts: Class used to do the vertex and credit limit callouts
*/
public with sharing class CreditLimitCallouts {

    public static final String REMAININGURL = '/sap-tax-service/tax/v1/quote';

    /**
	* @author       APB
	* @description  getVertexInformation method
	* @param		quoteToCalculate SBQQ__Quote__c
    * @param		orderToCalculate Order
	* @return		HttpResponse
	*/
    public static HttpResponse getVertexInformation(SBQQ__Quote__c quoteToCalculate,Order orderToCalculate){

        Http vertexHttp= new Http();
        HttpRequest vertexRequest = new HttpRequest();
        HttpResponse vertexResponse = new HttpResponse();

        DateTime todayDateTime = DateTime.now();

        vertexRequest.setEndpoint('callout:vertex_usernamePass'+ REMAININGURL);
        vertexRequest.setHeader('Content-Type','application/json');

        vertexRequest.setMethod('POST');

        String finalVertexBody;

        if(quoteToCalculate != null && quoteToCalculate.SBQQ__Status__c == 'Accepted'){

            String bodyWrapper = JSON.serialize(VertexIntManager.createRequest(todayDateTime,quoteToCalculate.SBQQ__Account__r.BillingCountry));
            finalVertexBody = CreditLimitUtilMethods.formatRequest(bodyWrapper);

        }else if(orderToCalculate != null && orderToCalculate.Status == 'Activated'){
        	String bodyWrapper = JSON.serialize(VertexIntManager.createRequest(todayDateTime,orderToCalculate.Account.BillingCountry));
            finalVertexBody = CreditLimitUtilMethods.formatRequest(bodyWrapper);
        }
        vertexRequest.setBody(finalVertexBody);
        vertexResponse = vertexHttp.send(vertexRequest);

        return vertexResponse;

    }

    /**
	* @author       APB
	* @description  startCreditLimitCallouts method
	* @param		quoteToCalculate SBQQ__Quote__c
    * @param		orderToCalculate Order
    * @param		actualAccount Account
	* @return		HttpResponse
	*/
    public static HttpResponse startCreditLimitCallouts(SBQQ__Quote__c quoteToCalculate,Order orderToCalculate,Account actualAccount){

        String orgId = [SELECT Id FROM Organization WITH USER_MODE LIMIT 1].Id;
        HttpResponse creditLimitResponse = new HttpResponse();
        HttpRequest request = new HttpRequest();
        Http creditLimitHttp= new Http();

        request.setHeader('Content-Type','application/json');
        request.setHeader('accept','application/json');

        request.setMethod('POST');
        String finalCreditLimitBody;

        if(quoteToCalculate != null && quoteToCalculate.SBQQ__Status__c == 'Accepted'){

        	request.setEndpoint('callout:creditLimitCheckOuathCallout');

            String bodyWrapper = JSON.serialize(CreditLimitWrapperManager.createCreditWorthinessRequest(quoteToCalculate.cur_Current_Credit_Limit_including_VAT__c,quoteToCalculate.CurrencyIsoCode,quoteToCalculate.SBQQ__Account__r.txt_AthenaUUID__c ));
            finalCreditLimitBody= CreditLimitUtilMethods.formatRequest(bodyWrapper);

        }else if(orderToCalculate != null && orderToCalculate.Status == 'Activated'){

         	request.setEndpoint('callout:creditLimitCheckOuathCallout');
            String bodyWrapper = JSON.serialize(CreditLimitWrapperManager.createCreditWorthinessRequest(orderToCalculate.cur_Current_Credit_Limit_including_VAT__c,orderToCalculate.CurrencyIsoCode,orderToCalculate.Account.txt_AthenaUUID__c));
            finalCreditLimitBody= CreditLimitUtilMethods.formatRequest(bodyWrapper);

        }else if(actualAccount != null){

         	request.setEndpoint('callout:CreditLimitOuathAccount');
            String bodyWrapper = JSON.serialize(CreditLimitWrapperManager.createAccountRequest(orgId,actualAccount.BillingCountry,actualAccount.txt_AthenaUUID__c));
            finalCreditLimitBody= CreditLimitUtilMethods.formatRequest(bodyWrapper);

        }

        request.setBody(finalCreditLimitBody);

        if(request.getBody() != null && request.getBody() != ''){
            creditLimitResponse = creditLimitHttp.send(request);
        }

        return creditLimitResponse;

    }
}