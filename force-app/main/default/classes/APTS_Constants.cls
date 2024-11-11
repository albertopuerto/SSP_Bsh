public without sharing class APTS_Constants {

    //BEG: Integration Constant
    public static final String QUERY_TXNREC = 'SELECT Id, LastModifiedDate, APTS_Integration_Repository__c FROM APTS_Integration_Transaction__c WHERE LastModifiedDate < ';
    public static final String INTREPO_TESTSOAPWEBSERVICES = 'TestSOAPWebservices';
    public static final String INTREPO_TESTSOAPWEBSERVICE = 'TestSOAPWebservice';
    public static final String INTREPO_TESTJSONWEBSERVICE = 'submitrequest';
    
    public static final String EXCEPTION_REPOSITORY_NOT_FOUND = 'Integration Repository not available for this operation.';
    public static final String INTSTATUS_FAILED = 'Failed';
    public static final String INTSTATUS_SUCCESS = 'Success';
    //END: Integration Constants
    
    //BEG: Other Constants
    public static final String AGMT_STATUS_FULLY_SIGNED = 'Fully Signed';
    public static final String AGMT_TYPE_OF_SIGNATURE = 'Esignature';
    public static final String AGMT_SIGNED_DOC_KEY = 'signed';
    //END: Other Constants
    
    
}