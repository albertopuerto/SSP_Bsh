public class LogCalloutInformation {
    @InvocableMethod(label='Log HTTP Callout information')
    public static void logCalloutInformation(List<LogCalloutInfo> logCalloutInfoList) {
        
        LoggerSettings__c logSetting  =  [SELECT Id,LoggingLevel__c,IsDataMaskingEnabled__c,DefaultNumberOfDaysToRetainLogs__c,IsAnonymousModeEnabled__c,IsApexSystemDebugLoggingEnabled__c from LoggerSettings__c where Name='Logger Settings (Organization)' LIMIT 1]; 
        
        for (LogCalloutInfo logCalloutInfo : logCalloutInfoList) {
       		
            Logger.INFO('Starting flow'+ logCalloutInfo.flowName );
            Http http= new Http();
          
            HttpRequest request = new HttpRequest();
            
            HttpResponse response = new HttpResponse();
            
            try{

                if(logCalloutInfo.httpRequestBody != null && logCalloutInfo.httpMethod != null && logCalloutInfo.httpEndpoint != null){    
                    request.setMethod(logCalloutInfo.httpMethod);
                    request.setEndpoint(logCalloutInfo.httpEndpoint);
                    request.setBody(logCalloutInfo.httpRequestBody);
                }

                if(logCalloutInfo.httpResponseBody != null && logCalloutInfo.httpStatus != null && logCalloutInfo.httpStatusCode != null){
                    response.setBody(logCalloutInfo.httpResponseBody);
                    response.setStatus(logCalloutInfo.httpStatus);
                    response.setStatusCode(logCalloutInfo.httpStatusCode);
                }

                Logger.info('HTTP Callout Request and Response')
                .addTags(logCalloutInfo.logTags.split(','))
                .setHttpRequestDetails(request)
                .setHttpResponseDetails(response)
                .setRecordId(logCalloutInfo.recordIdString);
                
                if(logCalloutInfo.exceptionMessage != null && logCalloutInfo.exceptionType != null && logCalloutInfo.exceptionStacktrace != null){
                    Logger.error('Exception error details '+ logCalloutInfo.exceptionType + logCalloutInfo.exceptionMessage + logCalloutInfo.exceptionStacktrace )
                    .addTags(logCalloutInfo.logTags.split(','))
                    .setRecordId(logCalloutInfo.recordIdString);
                }
                
                if(LogCalloutInfo.logMessage != null){
                   Logger.error( logCalloutInfo.flowName ,LogCalloutInfo.logMessage)
                   .addTags(logCalloutInfo.logTags.split(','))
                   .setRecordId(logCalloutInfo.recordIdString);
                }
                
            }catch(Exception ex){
                Logger.error('Error while creating the log'+ ex.getMessage())
                .setRecordId(logCalloutInfo.recordIdString);
            }finally{
                Logger.saveLog();
            }
            
        }
         
    }
}