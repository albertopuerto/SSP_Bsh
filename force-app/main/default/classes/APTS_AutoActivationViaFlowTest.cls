@isTest
public class APTS_AutoActivationViaFlowTest {
	@isTest
    public static void AutoActivationTest(){
        Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c();
        agmt.Apttus__Contract_Start_Date__c = System.today() - 1;
        agmt.Apttus__Contract_End_Date__c = System.today();
        insert agmt;
        agmt.Apttus__Status__c = 'Fully Signed';
        agmt.Apttus__Status_Category__c = 'In Signature';
        update agmt;
        List<id> Ids = new List<id>();
        Ids.add(agmt.Id);
        ContentVersion att = new ContentVersion();
        att.VersionData= blob.valueOf('abcd');
        att.PathOnClient = 'signedDoc.PDF';
        
        insert att;
        
        ContentVersion cv = [select id,ContentDocumentId from contentVersion where id =: att.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = agmt.Id;
        cdl.ShareType ='V';
        insert cdl;
        
        Attachment at = new Attachment();
        at.ParentId = agmt.Id;
        at.Name = agmt.Name + 'signed.pdf';
        at.Body = blob.toPdf('This is for testing');
        insert at;
        
        ContentDocumentLink cdl2 = [select Id,ContentDocumentId from ContentDocumentLink where id =: cdl.Id];
        Attachment at2 = [select Id from Attachment where id =: at.Id];
        Apttus__DocumentVersion__c docTemp = new Apttus__DocumentVersion__c();
        docTemp.Apttus__Title__c = at.Name;
        docTemp.Apttus__AgreementId__c = agmt.Id;
        docTemp.Apttus__DocumentType__c = 'Executed Document';
        docTemp.Apttus__LatestVersion__c = '1.0.0';
        insert docTemp;
        
        Apttus__DocumentVersionDetail__c docVersion = new Apttus__DocumentVersionDetail__c();
        docVersion.Apttus__DocumentVersionId__c = docTemp.Id;
        docVersion.Apttus__ContentId__c = cdl2.ContentDocumentId;
        docVersion.Apttus__FileType__c = 'ContentDocument';
        docVersion.Apttus__Title__c = agmt.Name + 'signed.pdf';
        docVersion.Apttus__VersionMajor__c = 1;
        docVersion.Apttus__VersionMinor__c = 0;
        docVersion.Apttus__VersionRevision__c = 0;
        insert docVersion;
        
        docTemp.Apttus__LatestVersionId__c = docVersion.Id;
        update docTemp;
        APTS_AutoActivationViaFlow.activateAgreement(Ids);
        APTS_AutoActivationViaFlow.changingAgreementStatus(True,agmt);
    }
}