/**************************************************************************************************************************
@Name: APTS_ExportWizardDataController
@Author: Shashank Mehra
@CreateDate: 03/03/2020
@Description: This is controller class for APTS_ExportWizardData page and export the JSON data.
@Shashank - 26/11/2020 Added Fix for record type in rule set
***************************************************************************************************************************/ 

public with sharing class APTS_ExportWizardDataController{
    
    public String[] wizardDesignSelectedNames = new String[]{};
    public String jsonWizardDesign {get;set;}
    public String jsonWizardStep {get;set;}
    public String jsonWizardInputControl {get;set;}
    public String jsonRuleSet {get;set;}
    public String jsonRules {get;set;}
    
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        for (Apttus__WizardDesign__c wizardDesign : [Select Id, Name from Apttus__WizardDesign__c where Apttus__Status__c = 'Activated']){
            options.add(new SelectOption(wizardDesign.Id,wizardDesign.Name));
        }
        return options;
    }
    
    public String[] getwizardDesignSelectedNames () {
        return wizardDesignSelectedNames;
    }
    
    public void setwizardDesignSelectedNames (String[] wizardDesignSelectedNames) {
        this.wizardDesignSelectedNames = wizardDesignSelectedNames;
    }
    
    public PageReference createJson(){
        reteriveSelectedWizardDesign(wizardDesignSelectedNames);
        return null;
    }
    
	public void reteriveSelectedWizardDesign(String[] setWizardDesignIds){
		List<Apttus__WizardDesign__c> listWizardDesigns = [select Id, Name,  Apttus__Active__c, Apttus__AllowReviewEdit__c, Apttus__BannerStatement__c, Apttus__CSSFilename__c, Apttus__Category__c, Apttus__ContextObject__c, Apttus__ContextType__c, Apttus__DataSourceCallback__c, Apttus__Description__c, Apttus__Keywords__c, Apttus__MetaPropertyFieldSetName__c, Apttus__RuntimeHelpText__c, Apttus__StaticResource__c, Apttus__Status__c, Apttus__Subcategory__c, APTS_External_Id__c 
								from Apttus__WizardDesign__c where Id IN :setWizardDesignIds];
		for (Apttus__WizardDesign__c wDesign :listWizardDesigns){
		    wDesign.APTS_External_Id__c = wDesign.Id;
		    wDesign.Id = null;
		}

		if (listWizardDesigns.size()>0){

			Set<Id> setWizardStepIds = new Set<Id>();
			Set<Id> setInputControlIds = new Set<Id>();
			Set<Id> setRulesSetsIds = new Set<Id>();
			Set<Id> setRecordTypeIds = new Set<Id>();


			List<Apttus__WizardStep2__c> listWizardSteps = [select Id, Name, Apttus__BannerStatement__c, Apttus__Category__c, Apttus__ContextObject__c, Apttus__ContextType__c, Apttus__Description__c, Apttus__ImageFilename__c, Apttus__InputGroupOption__c, Apttus__Keywords__c, Apttus__RuntimeHelpText__c, Apttus__Sequence__c, Apttus__Subcategory__c, Apttus__WizardDesignId__c, APTS_External_Id__c
								from Apttus__WizardStep2__c where Apttus__WizardDesignId__c IN :setWizardDesignIds];

			for (Apttus__WizardStep2__c step : listWizardSteps){
			    step.APTS_External_Id__c = step.Id;
				setWizardStepIds.add(step.Id);
				step.Id = null;
			}

			List<Apttus__WizardInputControl2__c> listInputControls = [select Id, Name, Apttus__Category__c, Apttus__ContextObject__c, Apttus__ContextType__c, Apttus__Description__c, Apttus__EnableAttachments__c, Apttus__FieldClass__c, Apttus__FieldName__c, Apttus__FieldType__c, Apttus__Keywords__c, Apttus__ObjectName__c, Apttus__PicklistValues__c, Apttus__Question__c, Apttus__ReadOnly__c, Apttus__Required__c, Apttus__RuntimeHelpText__c, Apttus__Sequence__c, Apttus__Subcategory__c, Apttus__WizardStepId__c, Apttus__LongQuestion__c, APTS_External_Id__c 
								from Apttus__WizardInputControl2__c where Apttus__WizardStepId__c IN :setWizardStepIds];
			
			for (Apttus__WizardInputControl2__c inputControl : listInputControls){
			    inputControl.APTS_External_Id__c = inputControl.Id;
				setInputControlIds.add(inputControl.Id);
				inputControl.Id = null;
			}

			List<Apttus__WizardRuleset2__c> listWizardRuleSets = [select Id, Name, Apttus__AdvancedExpression__c, Apttus__ContextObject__c, Apttus__MetaPropertyFieldName__c, Apttus__RecordTypeId__c, Apttus__ResultantValue__c, Apttus__RuleType__c, Apttus__Sequence__c, Apttus__ToWizardStepId__c, Apttus__WizardInputControlId__c, Apttus__WizardStepId__c, APTS_External_Id__c 
								from Apttus__WizardRuleset2__c where Apttus__WizardStepId__c IN :setWizardStepIds OR Apttus__WizardInputControlId__c IN :setInputControlIds];

            for (Apttus__WizardRuleset2__c ruleSet : listWizardRuleSets){
                ruleSet.APTS_External_Id__c = ruleSet.Id;
                setRulesSetsIds.add(ruleSet.Id);
                ruleSet.Id = null;
                if (ruleSet.Apttus__RecordTypeId__c != null){
                    setRecordTypeIds.add(ruleSet.Apttus__RecordTypeId__c);
                }                
            }
            Map<Id, RecordType> mapIdRecordType = new Map<Id, RecordType>([Select Id, DeveloperName from RecordType where Id IN :setRecordTypeIds]);
            for (Apttus__WizardRuleset2__c ruleSet : listWizardRuleSets){
                if (ruleSet.Apttus__RecordTypeId__c != null && mapIdRecordType.containsKey(ruleSet.Apttus__RecordTypeId__c)){
                    ruleSet.APTS_Record_Type_Name__c = mapIdRecordType.get(ruleSet.Apttus__RecordTypeId__c).DeveloperName;
                }               
            }

			List<Apttus__WizardRule2__c> listWizardRules = [select Id, Name, Apttus__WizardRulesetId__c, Apttus__ComparisonOperator__c, Apttus__FromInputControlId__c, Apttus__Sequence__c, Apttus__Value__c, Apttus__LongValue__c, APTS_External_Id__c 
								from Apttus__WizardRule2__c where Apttus__WizardRulesetId__c IN :setRulesSetsIds AND Apttus__FromInputControlId__c IN :setInputControlIds];
            
        	for (Apttus__WizardRule2__c rule : listWizardRules){
			    rule.APTS_External_Id__c = rule.Id;
			    rule.Id = null;
			}
            
			jsonWizardDesign = JSON.serialize(listWizardDesigns);
			jsonWizardStep = JSON.serialize(listWizardSteps);
			jsonWizardInputControl = JSON.serialize(listInputControls);
			jsonRuleSet = JSON.serialize(listWizardRuleSets);
			jsonRules = JSON.serialize(listWizardRules);
		}

	}
}