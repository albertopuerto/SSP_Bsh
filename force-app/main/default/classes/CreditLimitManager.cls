/**
* @author       APB
* @description  CreditLimitCallouts: Class that manage all the process from the credit limit lightning web component
*/
public with sharing class CreditLimitManager {

    public static List<SBQQ__Quote__c> listQuotesToUpdate = new List<SBQQ__Quote__c>();
    public static List<Order> listOrdersToUpdate = new List<Order>();

    /**
	* @author       APB
	* @description  method to take the currency of the actual account
	* @param		objectAPIName String
    * @param		objectRecordId String
	* @return		String
	*/
    @AuraEnabled
    public static String  getObjectCurrency(String objectAPIName,String objectRecordId) {

    	String objCurrency;
        Set<Id> objectIds = new Set<Id>();
        objectIds.add(objectRecordId);
        if(objectAPIName == 'Account'){
            objCurrency = new AccountSelector().selectById(objectIds)[0].CurrencyIsoCode;
        }

        return objCurrency;
    }

    /**
	* @author       APB
	* @description  method to take the actual account
    * @param		objectRecordId String
	* @return		List<Account>
	*/
    @AuraEnabled(cacheable=true)

    public static List<Account>  getAccountFields(String objectRecordId) {

    	List<Account> listAccounts= new List<Account>();

        Set<Id> objectIds = new Set<Id>();
        objectIds.add(objectRecordId);
        listAccounts = new AccountSelector().selectById(objectIds);

        return listAccounts;
    }

    /**
	* @author       APB
	* @description  method that depending on the object api name calls to the respective method to get the limit
	* @param		objectAPIName String
    * @param		objectRecordId String
	* @return		CreditLimitWrappers.creditLimitInfoWrapper
	*/
    @AuraEnabled
    public static CreditLimitWrappers.creditLimitInfoWrapper callGetLimit(String objectAPIName,String objectRecordId) {

        CreditLimitWrappers.creditLimitInfoWrapper lastInfoWrapper = new CreditLimitWrappers.creditLimitInfoWrapper();
        try{

            if(objectAPIName =='Account'){
                lastInfoWrapper=getAccountLimit(objectRecordId);
            }else if(objectAPIName =='SBQQ__Quote__c'){
                lastInfoWrapper=getQuoteLimit(objectRecordId,objectAPIName);
            }else if(objectAPIName =='Order'){
                lastInfoWrapper=getOrderLimit(objectRecordId,objectAPIName);
            }

        }catch(Exception ex){
            lastInfoWrapper.message= ex.getMessage() + ' ' + ex.getLineNumber();
            lastInfoWrapper.success= false;

        	Logger.error('APX-EXC-00002, - We found an error during the Credit Limit process - '+ ex.getMessage())
            .addTags(new List<String>{'APX-EXC'})
            .setRecordId(objectRecordId);
        }finally{
        	saveLog();
        }
        return lastInfoWrapper;
    }

    /**
	* @author       APB
	* @description  method to get the order or quote credit limit
	* @param		quoteToCalculate SBQQ__Quote__c
    * @param		orderToCalculate Order
    * @param		objectApiName String
	* @return		CreditLimitWrappers.creditLimitInfoWrapper
	*/
    @AuraEnabled
    public static CreditLimitWrappers.creditLimitInfoWrapper getLimit(SBQQ__Quote__c quoteToCalculate,Order orderToCalculate,String objectApiName){

        CreditLimitWrappers.creditLimitInfoWrapper lastInfoWrapper = new CreditLimitWrappers.creditLimitInfoWrapper();

        CreditLimitWrappers.wrapperResponse responseBody;

        CreditLimitWrappers.CreditWorthiness creditWorthiness= new CreditLimitWrappers.CreditWorthiness();

        HttpResponse creditLimitResponse;

        creditLimitresponse = creditLimitCallouts.startCreditLimitCallouts(quoteToCalculate,orderToCalculate,null);

        if(creditLimitresponse != null  && creditLimitresponse.getStatusCode()== 200){

            responseBody= (CreditLimitWrappers.wrapperResponse)JSON.deserialize(CreditLimitUtilMethods.formatResponse(creditLimitresponse.getBody()), CreditLimitWrappers.wrapperResponse.class);
            creditWorthiness= responseBody.Envelope.Body.CreditWorthinessResponse.CreditWorthiness;

        }else{

            String objectRecordId = quoteToCalculate != null ? quoteToCalculate.Id : orderToCalculate.Id;

            lastInfoWrapper.message= creditLimitresponse.getBody();
            lastInfoWrapper.status= creditLimitresponse.getStatusCode();
            lastInfoWrapper.success= false;
            Logger.error('APX-INT-00004, - Error while doing the credit limit callout for the object - '+ objectApiName+'-'+ creditLimitresponse.getStatusCode() +'-'+creditLimitresponse.getBody())
            .addTags(new List<String>{'APX-INT'})
            .setRecordId(objectRecordId);
        }

        if(creditWorthiness != null){

                lastInfoWrapper.message= creditWorthiness.CreditLimit == null ? 'The account has not a correct bosch partner id' : ' ';
                lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                lastInfoWrapper.success= creditWorthiness.CreditLimit == null ? false : true;
            for(CreditLimitWrappers.CheckingDescs description :creditWorthiness.CheckingDescription){
                if(description.dollar.contains('Credit limit')){

                    lastInfoWrapper.message= description.dollar;
                    lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                    lastInfoWrapper.success= false;

                }
            }
        }

        return lastInfoWrapper;
    }

    /**
	* @author       APB
	* @description  method that call vertex and update the cur_Current_Credit_Limit_including_VAT__c of the quote and then calls to credit limit
	* @param		objectRecordId String
    * @param		objectApiName String
	* @return		CreditLimitWrappers.creditLimitInfoWrapper
	*/
    @AuraEnabled
    public static CreditLimitWrappers.creditLimitInfoWrapper getquoteLimit(String objectRecordId,String objectApiName) {
        Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(objectRecordId);

        SBQQ__Quote__c quotetoCalculate = new QuoteSelector().selectQuoteInfo(quoteIds)[0];

        CreditLimitWrappers.creditLimitInfoWrapper lastInfoWrapper = new CreditLimitWrappers.creditLimitInfoWrapper();

        HttpResponse vertexResponse= new HttpResponse();
        VertexMethods.wrapperResponse vertexResponseBody = new VertexMethods.wrapperResponse();

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { SBQQ__Quote__c.SObjectType});
        vertexResponse = CreditLimitCallouts.getVertexInformation(quoteToCalculate,null);

        if(vertexResponse != null && vertexResponse.getStatusCode()== 200){

            vertexResponseBody= (VertexMethods.wrapperResponse)JSON.deserialize(CreditLimitUtilMethods.formatResponse(vertexResponse.getBody()), VertexMethods.wrapperResponse.class);

            for(VertexMethods.responseItem taxItem: vertexResponseBody.items){
                for(VertexMethods.responseTaxes tax: taxItem.taxes){

                    quoteToCalculate.cur_Current_Credit_Limit_including_VAT__c = (quoteToCalculate.SBQQ__NetAmount__c * tax.taxRate)/100 + quoteToCalculate.SBQQ__NetAmount__c;
                    uow.registerDirty(quoteToCalculate);
                }
            }
            // method used to call credit limit
            lastInfoWrapper=getLimit(quoteToCalculate,null,objectApiName);

            uow.commitWork();

        }else{
            Logger.error('APX-INT-00003, - Error while retrieving the quote vertex callout - '+ vertexResponse.getStatusCode() +'-'+vertexResponse.getBody())
            .addTags(new List<String>{'APX-INT'})
            .setRecordId(objectRecordId);
        }

        return lastInfoWrapper;
    }

    /**
	* @author       APB
	* @description  method that call vertex and update the cur_Current_Credit_Limit_including_VAT__c of the order and then calls to credit limit
	* @param		objectRecordId String
    * @param		objectApiName String
	* @return		CreditLimitWrappers.creditLimitInfoWrapper
	*/
    @AuraEnabled
    public static CreditLimitWrappers.creditLimitInfoWrapper getOrderLimit(String objectRecordId,String objectApiName) {
        Set<Id> orderIds = new Set<Id>();

        orderIds.add(objectRecordId);
        Order orderToCalculate= new OrderSelector().selectOrderInfo(orderIds)[0];

        CreditLimitWrappers.creditLimitInfoWrapper lastInfoWrapper = new CreditLimitWrappers.creditLimitInfoWrapper();

        HttpResponse vertexResponse= new HttpResponse();
        VertexMethods.wrapperResponse vertexResponseBody = new VertexMethods.wrapperResponse();

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { Order.SObjectType,Account.SObjectType});

        vertexResponse = CreditLimitCallouts.getVertexInformation(null,orderToCalculate);

        if(vertexResponse != null && vertexResponse.getStatusCode()== 200){

            vertexResponseBody= (VertexMethods.wrapperResponse)JSON.deserialize(CreditLimitUtilMethods.formatResponse(vertexResponse.getBody()), VertexMethods.wrapperResponse.class);

            for(VertexMethods.responseItem taxItem: vertexResponseBody.items){
                for(VertexMethods.responseTaxes tax: taxItem.taxes){

                    orderToCalculate.cur_Current_Credit_Limit_including_VAT__c = (orderToCalculate.TotalAmount * tax.taxRate)/100 + orderToCalculate.TotalAmount;
                    uow.registerDirty(orderToCalculate);

                }
            }

            // method used to call credit limit
            lastInfoWrapper= getLimit(null,orderToCalculate,objectApiName);

            uow.commitWork();

        }else{
            Logger.error('APX-INT-00002, - Error while retrieving the order vertex callout - '+ vertexResponse.getStatusCode() +'-'+vertexResponse.getBody())
            .addTags(new List<String>{'APX-INT'})
            .setRecordId(objectRecordId);
        }

        return lastInfoWrapper;
    }

    /**
	* @author       APB
	* @description  Method that get the current credit limit for the account given
	* @param		objectRecordId String
	* @return		CreditLimitWrappers.creditLimitInfoWrapper
	*/
    @AuraEnabled
    public static CreditLimitWrappers.creditLimitInfoWrapper getAccountLimit(String objectRecordId) {
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(objectRecordId);

        Account actualAccount = new AccountSelector().selectById(accountIds)[0];
        String finalBodyresponse;
        CreditLimitWrappers.LogAccount logAccount = new CreditLimitWrappers.LogAccount();
        CreditLimitWrappers.accountWrapperResponse accountResponseBody;
        CreditLimitWrappers.CreditManagementAccount creditManagement = new CreditLimitWrappers.CreditManagementAccount();

        CreditLimitWrappers.creditLimitInfoWrapper lastInfoWrapper = new CreditLimitWrappers.creditLimitInfoWrapper();

        // if the account has the athena id we proceed to do the callout
        if(actualAccount.txt_AthenaUUID__c != null){

            HttpResponse creditLimitresponse = new HttpResponse();

            creditLimitresponse = creditLimitCallouts.startCreditLimitCallouts(null,null,actualAccount);

            if(creditLimitresponse != null && creditLimitresponse.getStatusCode()== 200){

                finalBodyResponse = CreditLimitUtilMethods.formatResponse(creditLimitresponse.getBody());
                accountResponseBody= (CreditLimitWrappers.accountWrapperResponse)JSON.deserialize(finalBodyresponse, CreditLimitWrappers.accountWrapperResponse.class);
                lastInfoWrapper.message= '0';
                lastInfoWrapper.success= true;

                if(accountResponseBody.Envelope.Body.CreditManagementAccountByIDResponse.Log != null){

                    logAccount = accountResponseBody.Envelope.Body.CreditManagementAccountByIDResponse.Log;

                    lastInfoWrapper.message= logAccount.Item.Note;
                    lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                    lastInfoWrapper.success= false;

                }else if(accountResponseBody.Envelope.Body.CreditManagementAccountByIDResponse.CreditManagementAccount.CreditLimitAmount != null){
                    creditManagement= accountResponseBody.Envelope.Body.CreditManagementAccountByIDResponse.CreditManagementAccount;
                    lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                    lastInfoWrapper.message= creditManagement.CreditLimitAmount.dollar != null ? creditManagement.CreditLimitAmount.dollar :'0';
                }
            }else{
                lastInfoWrapper.message= creditLimitresponse.getBody();
                lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                lastInfoWrapper.success= false;
                Logger.error('APX-INT-00001, - Error while fetching the account credit limit callout - '+ creditLimitresponse.getStatusCode() +'-'+creditLimitresponse.getBody())
                .addTags(new List<String>{'APX-INT'})
                .setRecordId(objectRecordId);
            }
        }
        return lastInfoWrapper;
    }

    /**
	* @author       APB
	* @description  Save nebula logger log
	*/
    @future(callout=true)
   	public static void saveLog(){
        Logger.saveLog();
    }
}