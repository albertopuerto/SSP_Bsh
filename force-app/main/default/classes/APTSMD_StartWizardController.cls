/*

    Date : 20/12/2018
    This Class used to execute wizard base on Wizard Name.

*/

public class APTSMD_StartWizardController {
   
    String WizardType = ApexPages.currentPage().getParameters().get('type');
    
    public pageReference startWizard(){
        List<Apttus__WizardDesign__c> wizardDesign = [SELECT id FROM Apttus__WizardDesign__c WHERE Name =:WizardType LIMIT 1];
        
        if(!wizardDesign.isEmpty()){
            Apttus__Wizard2__c wizard = new Apttus__Wizard2__c(Name = WizardType, Apttus__WizardDesignId__c = wizardDesign[0].Id, Apttus__Status__c = 'In Progress');
            insert wizard;
            return new pageReference('/' + wizard.id);             
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Wizard not found with Name: '+WizardType));
            return null;
        }
    }
}