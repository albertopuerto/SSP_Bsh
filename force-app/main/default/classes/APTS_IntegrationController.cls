/**
* @Name: APTS_IntegrationController
* @Author: @Apttus
* @CreateDate: 8/26/2019
* @Description: This is a controller class invoked by trigger/processbuilder
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/

public class APTS_IntegrationController implements Queueable, Database.AllowsCallouts{
    public static String status{get;set;}
    public String OPERATION_NAME = APTS_Constants.INTREPO_TESTJSONWEBSERVICE;
    public Id agrmntId;
    public APTS_IntegrationController(Id agrId){
        this.agrmntId = agrId;
    }
    public void execute(QueueableContext qc){
        status = 'Error';
        APTS_IntegrationMasterWrapper.TestJSONResponseWrapper responseSO = new APTS_IntegrationMasterWrapper.TestJSONResponseWrapper();
        //if(!test.isRunningTest()){
             responseSO = APTS_IntegrationFactory.invokeSubmitRequest(agrmntId,OPERATION_NAME);
        //}else{
           // responseSO.hasErrors = false;
        //}
        
        system.debug('responseSO >>>'+responseSO );                
        if(responseSO.hasErrors != false){ 
            status = 'Error'; 
            system.debug('Error>>> '+status);
        }
        else{
            status = 'Success';
            system.debug('Success>>> '+status);
        }
    }
}