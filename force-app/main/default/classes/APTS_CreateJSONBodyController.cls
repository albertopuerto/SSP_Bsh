/**
* @Name: APTS_IntegrationController
* @Author: @Apttus
* @CreateDate: 2/26/2019
* @Description: This is a controller class is to return JSON Body
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/

public class APTS_CreateJSONBodyController implements APTS_IntegrationBodyInterface{

    public String createJSONBody(Id value){
       Apttus__APTS_Agreement__c agr = [Select Id, Name, Apttus__Status__c From Apttus__APTS_Agreement__c where Id=: Value LIMIT 1];
       //Apttus__APTS_Agreement__c agr = (Apttus__APTS_Agreement__c)value;
       System.debug('got record value in json body'+agr);
       String JSON= '{"records" :[{"attributes" : {"type" : "Agreement__c", "referenceId" : "ref1"},"name" : "' + agr.Name +'","Status__c" : "'+ agr.Apttus__Status__c+'"}]}';
       system.debug('Json value'+JSON);
       return JSON;
    }

}