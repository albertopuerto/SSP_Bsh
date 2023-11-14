/**************************************************************************************************************************
@Name: APTS_ExportImportWizardControllerTest
@Author: Shashank Mehra
@CreateDate: 03/03/2020
***************************************************************************************************************************/ 


@isTest
public class APTS_ExportImportWizardControllerTest {
    
    @TestSetup
    public static void testDataSetup(){
        Apttus__WizardDesign__c wizardDesign = new Apttus__WizardDesign__c(Name='TestWizard',Apttus__Active__c=true, Apttus__Status__c = 'Activated');
        insert wizardDesign;
        
        Apttus__WizardStep2__c wizardStep = new Apttus__WizardStep2__c(Name='wizardStep',Apttus__WizardDesignId__c=wizardDesign.Id,Apttus__ContextObject__c='Apttus__APTS_Agreement__c', Apttus__ContextType__c='Object');
        insert wizardStep;
        
        Apttus__WizardInputControl2__c wizardInputControl = new Apttus__WizardInputControl2__c(Name='Agreement Name', Apttus__FieldClass__c='Object Field',Apttus__FieldName__c='Name',Apttus__FieldType__c='STRING',Apttus__ObjectName__c='Apttus__APTS_Agreement__c',Apttus__Question__c='Name', Apttus__WizardStepId__c=wizardStep.Id);
        insert wizardInputControl;
        
        Apttus__WizardRuleset2__c  wizardRuleSet = new Apttus__WizardRuleset2__c (Apttus__Sequence__c=0,Apttus__RuleType__c='Determine Focus Object',Apttus__WizardInputControlId__c=wizardInputControl.Id);
        insert wizardRuleSet;
        
        Apttus__WizardRule2__c wizardRule = new Apttus__WizardRule2__c (Apttus__Sequence__c=0,Apttus__WizardRulesetId__c=wizardRuleSet.Id, Apttus__ComparisonOperator__c='starts with',Apttus__FromInputControlId__c=wizardInputControl.Id,Apttus__Value__c='a');
        insert wizardRule;
    }
    
    static testMethod void testExportImportData(){
        Apttus__WizardDesign__c wd = [Select Id from Apttus__WizardDesign__c where Name='TestWizard'];
        List<Id> listWd = new List<Id>{wd.Id};
        Test.startTest();
        PageReference exportPage = new PageReference('/apex/APTS_ExportWizardData');
        Test.setCurrentPage(exportPage);
        APTS_ExportWizardDataController controller = new APTS_ExportWizardDataController();
        controller.getItems();
        controller.wizardDesignSelectedNames = listWd;
        PageReference newPage = controller.createJson();
        
        APTS_ImportWizardDataController importController = new APTS_ImportWizardDataController();
        importController.wizardDesignJSON = controller.jsonWizardDesign;
        importController.wizardStepJSON = controller.jsonWizardStep;
        importController.wizardInputControlsJSON = controller.jsonWizardInputControl;
        importController.wizardRulesetsJSON = controller.jsonRuleSet;
        importController.wizardRuleJSON = controller.jsonRules;
        
        importController.importData();
        
        Test.stopTest();

    }
}