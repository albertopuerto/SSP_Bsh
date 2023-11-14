/**
* @Name: APTS_IntegrationServiceBaseImpl
* @Author: @Apttus
* @CreateDate: 2/26/2019
* @Description: This is a class which shall make methods defined in interface 'APTS_IntegrationServiceInterface' available to be overridden.
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/
public abstract class APTS_IntegrationServiceBaseImpl implements APTS_IntegrationServiceInterface {
    
    //Exception Class for all intgeration failures.
    public class IntegrationServiceException extends Exception{}

    /*
    @Method : This method shall fetch Integration Repository record for corresponding operation
    @Param  : sOperation: Operation Name of Integration Repository .
    */
    public APTS_IntegrationMasterWrapper.IntegrationWrapper getIntegrationWrapper(final String sOperation){
        system.debug('Inside the serviceimpl class');
        System.debug(LoggingLevel.DEBUG, '[APTS_IntegrationServiceBaseImpl].constructor');

        final APTS_IntegrationMasterWrapper.IntegrationWrapper oWrapper = new APTS_IntegrationMasterWrapper.IntegrationWrapper();

        final List<APTS_Integration_Repository__c> lstIntgRepository = [SELECT Id, APTS_Log_Messages__c, APTS_Endpoint__c FROM APTS_Integration_Repository__c WHERE APTS_Operation_Name__c = :sOperation AND APTS_isActive__c=true LIMIT 1];

        if(lstIntgRepository.isEmpty()) {
            throw new IntegrationServiceException(APTS_Constants.EXCEPTION_REPOSITORY_NOT_FOUND);
        } else if(lstIntgRepository[0].APTS_Log_Messages__c) {
            oWrapper.oRepository = lstIntgRepository[0];
            oWrapper.oTransaction = new APTS_Integration_Transaction__c();
            oWrapper.oTransaction.APTS_Integration_Repository__c = oWrapper.oRepository.Id;
        } else {
            oWrapper.oRepository = lstIntgRepository[0];
            oWrapper.oTransaction = null;
        }
        
        return oWrapper;
    }

    /*
    @Method : This method shall include any housekeeping operations like preparing data/records before making call out
    @Param  : None
    */
    public virtual void beforeInvoke(String sInputParam){
    }
    
    
    /*
    @Method : This method shall make an actual callout using parameters populated in request
    @Param  : Serialized version of wrapper class whose parameters can be used to populate request
              while making call out               
    */
    
    public virtual void invoke(List<APTS_Integration_Set_Header__c> header){
    }
    
    
    /*
    @Method : This method shall be used to carry out clean-up activities / log transactions after call out
    @Param  : None
    */
    public virtual String afterInvoke(){
        return null;
    }
   

}