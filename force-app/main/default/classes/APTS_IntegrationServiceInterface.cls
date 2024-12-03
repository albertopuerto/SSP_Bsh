/**
* @Name: APTS_IntegrationServiceInterface
* @Author: @Apttus
* @CreateDate: 2/26/2019
* @Description: This interface declares methods that needs to be defined by classes implementing this interface 
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/
public interface APTS_IntegrationServiceInterface {
    
    /*
    @Method : This method shall include any housekeeping operations like preparing data for request before making call out
    @Param  : sInputParam
    */
    void beforeInvoke(String sInputParam,String sOperationName);
    
    
    /*
    @Method : This method shall make an actual callout using parameters populated in request
    @Param  : Serialized version of wrapper class whose parameters can be used to populate request
              while making call out               
    */
    
    void invoke(List<APTS_Integration_Set_Header__c> header);
    
    
    /*
    @Method : This method shall be used to carry out clean-up activities / log transactions after call out
    @Param  : None
    */
    String afterInvoke();
    
}