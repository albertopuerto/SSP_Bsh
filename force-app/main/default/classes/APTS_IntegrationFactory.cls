/**
* @Name: APTS_IntegrationFactory
* @Author: @Apttus
* @CreateDate: 2-26-2019
* @Description: This class is used to invoke business method for specific integration interface
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/
public class APTS_IntegrationFactory{
    
    /*
    @Method : Used to identify class for a specific interface
    @Param  : jsonString - operation Name to retrieve implementor class from Integration repository
    */
    
    public static String getClass(final String sOperationName){
        List<APTS_Integration_Repository__c> listIntegrationRepository = [SELECT APTS_Implementation_Class__c FROM APTS_Integration_Repository__c WHERE APTS_Operation_Name__c = :sOperationName AND APTS_isActive__c=TRUE LIMIT 1];

        return listIntegrationRepository.isEmpty()? null : listIntegrationRepository[0].APTS_Implementation_Class__c;
    }
    public static String getBodyClass(final String sOperationName){
        List<APTS_Integration_Repository__c> listIntegrationRepository = [SELECT APTS_Body_Implementation_Class__c FROM APTS_Integration_Repository__c WHERE APTS_Operation_Name__c = :sOperationName AND APTS_isActive__c=TRUE LIMIT 1];

        return listIntegrationRepository.isEmpty()? null : listIntegrationRepository[0].APTS_Body_Implementation_Class__c;
    }
    
    /*
    @Method : Used to identify class for a specific interface
    @Param  : jsonString - operation Name to retrieve implementor class from Integration repository
    */
    public static APTS_IntegrationMasterWrapper.TestJSONResponseWrapper invokeSubmitRequest(Id Value,final String sOperationName){
        List<APTS_Integration_Set_Header__c> header = new list<APTS_Integration_Set_Header__c>();
        header= [Select id,Name,APTS_Integration_Name__c,APTS_Value__c  From APTS_Integration_Set_Header__c where APTS_Integration_Name__c =:sOperationName];
        system.debug('header>>>'+header);
        String sClassName = APTS_IntegrationFactory.getClass(sOperationName);
        String sBodyClassName = APTS_IntegrationFactory.getBodyClass(sOperationName);
        String Jsonbody;
        system.debug('Sobject class>>>>> '+sBodyClassName);
        if(String.isNotBlank(sBodyClassName)){
            system.debug('inside if '+sBodyClassName);
            Type typeOfClassName = Type.forName(sBodyClassName);
            APTS_IntegrationBodyInterface obodyImpl = (APTS_IntegrationBodyInterface)typeOfClassName.newInstance();
            
            Jsonbody = obodyImpl.createJSONBody(Value);
            system.debug('Json>>>>> '+Jsonbody);
            //APTS_CreateJSONBodyController body = new APTS_CreateJSONBodyController();
            //Jsonbody = body.CompositeAPIJsonbody();
        }
        system.debug('Json string in factory>>>>> '+Jsonbody);
        APTS_IntegrationMasterWrapper.TestJSONResponseWrapper  oResWrapper = new APTS_IntegrationMasterWrapper.TestJSONResponseWrapper();

        if(String.isNotBlank(sClassName)) {
            Type typeOfClassName = Type.forName(sClassName);
            
            // Instance of implementor class (class which extends APTS_IntegrationServiceBaseImpl)           
            APTS_IntegrationServiceInterface oServiceImpl = (APTS_IntegrationServiceInterface)typeOfClassName.newInstance(); 
            
            //System.debug(LoggingLevel.DEBUG, '[APTS_IntegrationFactory] JSON.oReqWrapper' + JSON.serialize(oReqWrapper));

            oServiceImpl.beforeInvoke(Jsonbody,sOperationName);
            oServiceImpl.invoke(header);
            oResWrapper = (APTS_IntegrationMasterWrapper.TestJSONResponseWrapper)JSON.deserialize(oServiceImpl.afterInvoke(),APTS_IntegrationMasterWrapper.TestJSONResponseWrapper.class);

        }

        return oResWrapper;
    }

}