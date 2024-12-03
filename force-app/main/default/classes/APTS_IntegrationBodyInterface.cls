/**
* @Name: APTS_IntegrationBodyInterface
* @Author: @Apttus
* @CreateDate: 2/26/2019
* @Description: This interface declares methods that needs to be defined by classes implementing this interface 
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/
public interface APTS_IntegrationBodyInterface{
    
    /*
    @Method : This method shall include any housekeeping operations like preparing data for request before making call out
    @Param  : sInputParam
    */
    String createJSONBody(Id objectvalue);
    
    
}