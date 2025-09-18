public with sharing class CreditLimitCallouts {

    public static HttpResponse startVertexCallouts(Boolean isAccount, Boolean isQuote,Boolean isOrder,SBQQ__Quote__c quoteToCalculate,Order orderToCalculate){

        Http vertexHttp= new Http();
        HttpRequest vertexRequest = new HttpRequest();
        HttpResponse vertexResponse = new HttpResponse();    
            
        Date todayDate = Date.today();
        DateTime todayDateTime = DateTime.now();

        String remainingUrl = '/sap-tax-service/tax/v1/quote';

        vertexRequest.setEndpoint('callout:vertex_usernamePass'+ remainingUrl);
    
        vertexRequest.setHeader('Content-Type','application/json');

        vertexRequest.setMethod('POST');

        String finalVertexBody;
        
        if(isQuote && quoteToCalculate.SBQQ__Status__c == 'Accepted'){

            // Si no es accepted bloquearlo por js y ponerle un tooltip
            //  dto = new VertexBodyDTO(DateTime.now(), quoteToCalculate.Bill_To_Country__c);
            String bodyWrapper = JSON.serialize(VertexIntManager.createRequest(todayDateTime,quoteToCalculate.SBQQ__Account__r.BillingCountry));
            finalVertexBody = CreditLimitUtilMethods.formatRequest(bodyWrapper);
                
        }else if(isOrder && orderToCalculate.Status == 'Activated'){
                
        	String bodyWrapper = JSON.serialize(VertexIntManager.createRequest(todayDateTime,orderToCalculate.Account.BillingCountry));
            finalVertexBody = CreditLimitUtilMethods.formatRequest(bodyWrapper);
              
        }
        
        
        vertexRequest.setBody(finalVertexBody);

        List<SBQQ__Quote__c> listQuotesToUpdate = new List<SBQQ__Quote__c>();
        List<Order> listOrdersToUpdate = new List<Order>();

        System.debug(vertexRequest.getBody());
        vertexResponse = vertexHttp.send(vertexRequest);
        System.debug('aaaaa'+vertexResponse.getBody());
        
        return vertexResponse;
        
    }
    
    public static HttpResponse startCreditLimitCallouts(Boolean isAccount, Boolean isQuote,Boolean isOrder,String orgId,SBQQ__Quote__c quoteToCalculate,Order orderToCalculate,Account actualAccount){
        
        HttpResponse creditLimitResponse = new HttpResponse();
        HttpRequest request = new HttpRequest();
        Http creditLimitHttp= new Http();

        //    VertexMethods.wrapperResponse responseBody = new VertexMethods.wrapperResponse();
    
        request.setHeader('Content-Type','application/json');
        request.setHeader('accept','application/json');

        request.setMethod('POST');

      //  CreditLimitWrapperManager wrapperClass= new CreditLimitWrapperManager();
  
        // CreditLimit.wrapperResponse responseBody= new CreditLimit.wrapperResponse();

        String finalCreditLimitBody;

        if(isQuote && quoteToCalculate.SBQQ__Status__c == 'Accepted'){

        	request.setEndpoint('callout:creditLimitCheckOuathCallout');

            String bodyWrapper = JSON.serialize(CreditLimitWrapperManager.createCreditWorthinessRequest(orgId,quoteToCalculate.Current_Credit_Limit_including_VAT__c,quoteToCalculate.CurrencyIsoCode,quoteToCalculate.SBQQ__Account__r.txt_AthenaUUID__c ));
            finalCreditLimitBody= CreditLimitUtilMethods.formatRequest(bodyWrapper);
                
         }else if(isOrder && orderToCalculate.Status == 'Activated'){
             
         	 request.setEndpoint('callout:creditLimitCheckOuathCallout');
                
             String bodyWrapper = JSON.serialize(CreditLimitWrapperManager.createCreditWorthinessRequest(orgId,orderToCalculate.Current_Credit_Limit_including_VAT__c,orderToCalculate.CurrencyIsoCode,orderToCalculate.Account.txt_AthenaUUID__c));
              
             finalCreditLimitBody= CreditLimitUtilMethods.formatRequest(bodyWrapper);
              
         }else if(isAccount){   
             
         	request.setEndpoint('callout:creditLimitAccountOuathCallout');
                
            String bodyWrapper = JSON.serialize(CreditLimitWrapperManager.createAccountRequest(orgId,actualAccount.BillingCountry,actualAccount.txt_AthenaUUID__c));
              
            finalCreditLimitBody= CreditLimitUtilMethods.formatRequest(bodyWrapper);
             
         }
        
         request.setBody(finalCreditLimitBody);
      
         List<SBQQ__Quote__c> listQuotesToUpdate = new List<SBQQ__Quote__c>();
         List<Order> listOrdersToUpdate = new List<Order>();

         System.debug(request.getBody());
        
         // revisar si se puede hacer con el get status code
         if(request.getBody() != null && request.getBody() != ''){
             
         	creditLimitResponse = creditLimitHttp.send(request);
             
         }
        
        System.debug('responsee'+ creditLimitResponse.getBody());
         return creditLimitResponse;
            
    }
}