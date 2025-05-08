public class LogCalloutInfo  {
    @InvocableVariable(label='Flow Name') @AuraEnabled public String flowName;
    @InvocableVariable(label='Record Id') @AuraEnabled public Id recordIdString;
    @InvocableVariable(label='Log Message') @AuraEnabled public String logMessage;
    @InvocableVariable(label='Log Tags') @AuraEnabled public String logTags;

    @InvocableVariable(label='HTTP Endpoint') @AuraEnabled public String httpEndpoint;
    @InvocableVariable(label='HTTP Method') @AuraEnabled public String httpMethod;
    @InvocableVariable(label='HTTP Request Body') @AuraEnabled public String httpRequestBody;

    @InvocableVariable(label='HTTP Response Body') @AuraEnabled public String httpResponseBody;
    @InvocableVariable(label='HTTP Status') @AuraEnabled public String httpStatus;
    @InvocableVariable(label='HTTP Status Code') @AuraEnabled public Integer httpStatusCode;

    @InvocableVariable(label='Exception Message') @AuraEnabled public String exceptionMessage;
    @InvocableVariable(label='Exception Stacktrace') @AuraEnabled public String exceptionStacktrace;
    @InvocableVariable(label='Exception Type') @AuraEnabled public String exceptionType;

    @InvocableVariable(label='Save Log Entry') @AuraEnabled public Boolean saveLogEntry;

    public LogCalloutInfo() {
        this.saveLogEntry = true;
    }
}