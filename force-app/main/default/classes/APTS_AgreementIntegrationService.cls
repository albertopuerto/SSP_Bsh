/**
* @Name: APTS_SampleJSONServiceImpl
* @Author: @Apttus
* @CreateDate: 2-26-2019
* @Description: This is a class which shall make callout to extneral service.
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/
public with sharing class APTS_AgreementIntegrationService extends APTS_IntegrationServiceBaseImpl {
    private final String OPERATION_NAME = APTS_Constants.INTREPO_TESTJSONWEBSERVICE;
    public static string resp;
    private static APTS_IntegrationMasterWrapper.IntegrationWrapper oIntegrationWrapper;
    //private APTS_IntegrationMasterWrapper.TestJSONRequestWrapper oRequestWrapper;
    private static APTS_IntegrationMasterWrapper.TestJSONResponseWrapper oResponseWrapper;
    private APTS_Error_Code_Repository__c errorCodeSO;
    private final String SUCCESS_CODE = '200';
    public class IntegrationServiceException extends Exception{}

    //Class initializer block to initialize Integration Wrapper on class load.
    /*{
        //Get Common Wrapper from base class.
        this.oIntegrationWrapper = super.getIntegrationWrapper(OPERATION_NAME);
    }*/
    public APTS_AgreementIntegrationService(){
        system.debug('Inside the serviceimpl class');
        System.debug(LoggingLevel.DEBUG, '[APTS_IntegrationServiceBaseImpl].constructor');

        
        
    }
    
    public void beforeInvoke(String sInputParams,String operationName){
        //Deserialize input parameters
        //this.oRequestWrapper = (APTS_IntegrationMasterWrapper.TestJSONRequestWrapper)JSON.deserialize(sInputParams, APTS_IntegrationMasterWrapper.TestJSONRequestWrapper.class);
        oIntegrationWrapper = new APTS_IntegrationMasterWrapper.IntegrationWrapper();

        final List<APTS_Integration_Repository__c> lstIntgRepository = [SELECT Id, APTS_Log_Messages__c, APTS_Endpoint__c FROM APTS_Integration_Repository__c WHERE APTS_Operation_Name__c = :operationName AND APTS_isActive__c=true LIMIT 1];

        if(lstIntgRepository.isEmpty()) {
            throw new IntegrationServiceException(APTS_Constants.EXCEPTION_REPOSITORY_NOT_FOUND);
        } else if(lstIntgRepository[0].APTS_Log_Messages__c) {
            system.debug('here');
            oIntegrationWrapper.oRepository = lstIntgRepository[0];
            oIntegrationWrapper.oTransaction = new APTS_Integration_Transaction__c();
            oIntegrationWrapper.oTransaction.APTS_Integration_Repository__c = oIntegrationWrapper.oRepository.Id;
        } else {
            
            oIntegrationWrapper.oRepository = lstIntgRepository[0];oIntegrationWrapper.oTransaction = null;
        }
        //If Transaction needs to be logged then oTransaction would not have null assigned in base class. 
        system.debug('Inside main beforeInvoke'+sInputParams);
        system.debug('Inside main beforeInvoke'+oIntegrationWrapper.oTransaction);
        if(oIntegrationWrapper.oTransaction != null){
        system.debug('Inside main beforeInvoke2'+sInputParams);
            //this.oIntegrationWrapper.oTransaction.APTS_Quote_Proposal__c = this.oRequestWrapper.quotationId;
            oIntegrationWrapper.oTransaction.APTS_Request_Payload__c = sInputParams;
        }
    }
    
    public override void invoke(List<APTS_Integration_Set_Header__c> header){
        
        system.debug('Inside main Invoke');
        //String response;
        try {
            //Set Request Time Stamp before making call out.
            if(oIntegrationWrapper.oTransaction != null){
                oIntegrationWrapper.oTransaction.APTS_Request_Timestamp__c = Datetime.now();
            }

            //Make callout to REST web service. 
            system.debug('Inside main Invoke endpointurl'+oIntegrationWrapper.oRepository.APTS_Endpoint__c);
            system.debug('Inside main Invoke body'+oIntegrationWrapper.oTransaction.APTS_Request_Payload__c);
            String endpoint = oIntegrationWrapper.oRepository.APTS_Endpoint__c;
            String payload = oIntegrationWrapper.oTransaction.APTS_Request_Payload__c;
            //APTS_AgreementIntegrationService.makecallout(endpoint,payload);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            for(APTS_Integration_Set_Header__c headvalue: header){
                req.setHeader(headvalue.Name, headvalue.APTS_Value__c );
            }
            req.setEndpoint(endpoint);
            
            req.setBody(payload);
            
            HTTPResponse res = http.send(req);
            resp = res.getBody();
            system.debug('resp value'+resp);
            oResponseWrapper = (APTS_IntegrationMasterWrapper.TestJSONResponseWrapper)JSON.deserialize(resp,APTS_IntegrationMasterWrapper.TestJSONResponseWrapper.class);
            System.debug('[Response] : '+oResponseWrapper);
                                   
            //Set Response Time Stamp before making call out.
            if(oIntegrationWrapper.oTransaction != null){
                oIntegrationWrapper.oTransaction.APTS_Response_Timestamp__c = Datetime.now();
                //oIntegrationWrapper.oTransaction.APTS_Status__c = oResponseWrapper.results.errors.statusCode ;
                oIntegrationWrapper.oTransaction.APTS_Perform_Retry__c = false;
                oIntegrationWrapper.oTransaction.APTS_Response_Payload__c = JSON.serialize(oResponseWrapper);
            }
                 
        //System.debug(LoggingLevel.DEBUG, '[APTS_SampleSOAPServiceImpl].invoke result: ' + this.result);
        } catch (Exception e) {if(oIntegrationWrapper.oTransaction != null){oIntegrationWrapper.oTransaction.APTS_Stack_Trace__c = e.getStackTraceString();oIntegrationWrapper.oTransaction.APTS_Status__c = APTS_Constants.INTSTATUS_FAILED;
            }
            system.debug('exception'+ e);
        }
    }
    //@future(callout = true)
    public override String afterInvoke(){
        try {
            if(oIntegrationWrapper.oTransaction != null) {
                
                insert oIntegrationWrapper.oTransaction;
            }
            
        } catch (Exception e) {}

        return JSON.serialize(oResponseWrapper);
    }
}