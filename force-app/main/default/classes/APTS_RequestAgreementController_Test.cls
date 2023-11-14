@isTest
public class APTS_RequestAgreementController_Test {
    testMethod static void RequestAgreementControllerTest(){
        String objname = 'Apttus__APTS_Agreement__c';
        Test.startTest();
        List<RecordType> recTypeList = APTS_RequestAgreementController.getRecordTypeList(objname);
        Test.stopTest();
        system.assert(recTypeList.size()>0);
    }
}