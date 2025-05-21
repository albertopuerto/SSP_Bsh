@isTest
public class LogCalloutInformation_Test {

    @isTest
    public static void startMethod(){
        
        
        LoggerSettings__c logSetting = new LoggerSettings__c();
        logSetting.Name='Logger Settings (Organization)';
        logSetting.LoggingLevel__c= 'FINEST';
        logSetting.IsDataMaskingEnabled__c= false;
        logSetting.DefaultNumberOfDaysToRetainLogs__c= 90;
        logSetting.IsAnonymousModeEnabled__c= false;
        logSetting.IsApexSystemDebugLoggingEnabled__c= true;
        insert logSetting;
        
        List<LogCalloutInfo> listCalloutWrapps = new List<LogCalloutInfo>(); 
        
        Account[] accountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
		accountList[0].Name = 'TestAccount1';
        
        insert accountList;
        
        LogCalloutInfo logWrapp = new LogCalloutInfo();
        
        logWrapp.flowName='Account Update Nebula Show Errors';
        logWrapp.httpEndpoint='Text endpoint';
        logWrapp.httpMethod='GET';
        logWrapp.httpRequestBody='We have a request for retrieving the account with id 001218921';
        logWrapp.logMessage='Error while retrieving the accounts ';
        logWrapp.logTags='Method to retrieve accounts';
        logWrapp.recordIdString= accountList[0].Id;
        logWrapp.saveLogEntry= true;
        
        listCalloutWrapps.add(logWrapp);
        
        Test.startTest();
        LogCalloutInformation.logCalloutInformation(listCalloutWrapps);
        Test.stopTest();
    }
}