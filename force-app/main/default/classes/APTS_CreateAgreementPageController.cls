public class APTS_CreateAgreementPageController {

    public APTS_CreateAgreementPageController(ApexPages.StandardController controller) {

    }
    
    public PageReference doRedirect()
    {
                Apttus__WizardDesign__c objWizard = [select Id, name, Apttus__Status__c from Apttus__WizardDesign__c where Name = :Label.APTS_Agreement_Wizard_Name and Apttus__Status__c = 'Activated'];
                PageReference pageRef = new PageReference('/apex/apttus__wizard?wizardid='+objWizard.Id);
                pageRef.setRedirect(true);
                return pageRef;
 
    }

}