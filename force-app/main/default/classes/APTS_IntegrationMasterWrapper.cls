/**
* @Name: APTS_IntegrationMasterWrapper
* @Author: @Apttus
* @CreateDate: 2/26/2019
* @Description: This is a common wrapper class for all integration request and response.
---------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
**/
public with sharing class APTS_IntegrationMasterWrapper {
    //Common Wrapper across all the implementig class.
    public class IntegrationWrapper {
        public APTS_Integration_Repository__c oRepository {get; set;}
        public APTS_Integration_Transaction__c oTransaction {get; set;}
    }
    
    //Wrapper class for JSON Request
    public class GenerateTokenRequestWrapper{
        public String clientid{get;set;}
        public String clientsecret{get;set;}
        public String username{get;set;}
        public String passwrd {get;set;}
    }
    
    public class Results {
        public String referenceId;
        public String id;
        public List<Errors> errors;
    }
     public class Errors {
        public String statusCode;
        public String message;
        public List<String> fields;
    }
    //Wrapper class for JSON Response
    public class TestJSONResponseWrapper{
        public Boolean hasErrors;
        public List<Results> results;
        public String statusCode {get;set;}
        public String status {get;set;}
    }
}