/* Name - APTS_RequestAgreementController
 * Created Date - Nov 16, 2019
 * Created By - Apttus
 * Description - This class is used in Aura component which creates Agreement from Account
 */
public class APTS_RequestAgreementController{
    @AuraEnabled
    public static List<RecordType> getRecordTypeList(String objectName){
        List<RecordType> recTypeList = new List<RecordType>();
        recTypeList = [SELECT Id, Name, DeveloperName,Description, SobjectType FROM RecordType where SobjectType =: objectName];
        return recTypeList;
    }
}