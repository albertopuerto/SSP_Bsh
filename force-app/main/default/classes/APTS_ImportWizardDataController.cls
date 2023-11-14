/**************************************************************************************************************************
@Name: APTS_ImportWizardDataController
@Author: Shashank Mehra
@CreateDate: 03/03/2020
@Modified On: 05/26/2020 (Added Fix)
@Description: This is controller class for APTS_ImportWizardData page and export the JSON data.
@Shashank - 26/11/2020 Added Fix for record type in rule set
***************************************************************************************************************************/ 

public with sharing class APTS_ImportWizardDataController{
    
    public String wizardDesignJSON {get;set;}
    public String wizardStepJSON {get;set;}
    public String wizardInputControlsJSON {get;set;}
    public String wizardRulesetsJSON {get;set;}
    public String wizardRuleJSON {get;set;}
    public String statusString {get;set;}
    Map<Id,Id> wizardDesignIds = new Map<Id,Id>();
    Map<Id,Id> wizardStepIds = new Map<Id,Id>();
    Map<Id,Id> wizardInputControlIds = new Map<Id,Id>();
    Map<Id,Id> wizardRuleSetsIds = new Map<Id,Id>();
    Map<Id,Id> wizardRuleIds = new Map<Id,Id>();
	
	public void importData(){
	    statusString = '';
	    if (String.isNotBlank(wizardDesignJSON)){
	        importSelectedWizardDesign();
	    }
	    if (String.isNotBlank(wizardStepJSON)){
	        importSelectedWizardSteps();
	    }
	    if (String.isNotBlank(wizardInputControlsJSON)){
	        importWizardInputControl();
	    }
	    if (String.isNotBlank(wizardRulesetsJSON)){
	        importWizardRuleSets();
	    }
	    if (String.isNotBlank(wizardRuleJSON)){
	        importWizardRule();
	    }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, statusString));
	}    

	public void importSelectedWizardDesign(){
	    
        List<Apttus__WizardDesign__c> listWizardDesign = (List<Apttus__WizardDesign__c>)JSON.deserialize(wizardDesignJSON, List<Apttus__WizardDesign__c>.class);

        Schema.SObjectField fkey1 = Apttus__WizardDesign__c.Fields.APTS_External_Id__c;
        Database.UpsertResult[] srList = Database.upsert(listWizardDesign,fkey1,false);
        updateMessage(srList, 'Wizard Design : ');
    	List<Apttus__WizardDesign__c> exisitingWizardDesignList = [Select Id, APTS_External_Id__c from Apttus__WizardDesign__c];
        for (Apttus__WizardDesign__c wdesign: exisitingWizardDesignList){
            wizardDesignIds.put(wdesign.APTS_External_Id__c, wdesign.Id);
        }

	}
	
	public void importSelectedWizardSteps(){
	    List<Apttus__WizardStep2__c> listWizardSteps = (List<Apttus__WizardStep2__c>)JSON.deserialize(wizardStepJSON, List<Apttus__WizardStep2__c>.class);
    	Schema.SObjectField fkey2 = Apttus__WizardStep2__c.Fields.APTS_External_Id__c;
    	
    	for (Apttus__WizardStep2__c wizardStep :listWizardSteps){
            wizardStep.Apttus__WizardDesignId__c = wizardDesignIds.get(wizardStep.Apttus__WizardDesignId__c);
    	}
    	
        Database.UpsertResult[] srList = Database.upsert(listWizardSteps,fkey2,false);
        updateMessage(srList, 'Wizard Steps : ');
    	
    	List<Apttus__WizardStep2__c> exisitingWizardSteps = [Select Id, APTS_External_Id__c from Apttus__WizardStep2__c];
        for (Apttus__WizardStep2__c wizardStep :exisitingWizardSteps){
            wizardStepIds.put(wizardStep.APTS_External_Id__c, wizardStep.Id);
    	}
	}
	
	public void importWizardInputControl(){
	    List<Apttus__WizardInputControl2__c> listWizardInputControl = (List<Apttus__WizardInputControl2__c>)JSON.deserialize(wizardInputControlsJSON, List<Apttus__WizardInputControl2__c>.class);
    	Schema.SObjectField fkey3 = Apttus__WizardInputControl2__c.Fields.APTS_External_Id__c;
    	
    	for (Apttus__WizardInputControl2__c wizardIPC :listWizardInputControl){
            wizardIPC.Apttus__WizardStepId__c = wizardStepIds.get(wizardIPC.Apttus__WizardStepId__c);
    	}
    	
        Database.UpsertResult[] srList = Database.upsert(listWizardInputControl,fkey3,false);
        updateMessage(srList, 'Wizard Input Control : ');
    	
    	List<Apttus__WizardInputControl2__c> exisitingWizardInputControl = [Select Id, APTS_External_Id__c from Apttus__WizardInputControl2__c];
        for (Apttus__WizardInputControl2__c wizardInputControl :exisitingWizardInputControl){
            wizardInputControlIds.put(wizardInputControl.APTS_External_Id__c, wizardInputControl.Id);
    	}
	}
	
    public void importWizardRuleSets(){
        List<Apttus__WizardRuleset2__c> listWizardRuleSet = (List<Apttus__WizardRuleset2__c>)JSON.deserialize(wizardRulesetsJSON, List<Apttus__WizardRuleset2__c>.class);
        Schema.SObjectField fkey4 = Apttus__WizardRuleset2__c.Fields.APTS_External_Id__c;
        Set<String> setObjectNames = new Set<String>();
        Map<String,Id> mapRecordTypeNameToId = new Map<String,Id>();
        for (Apttus__WizardRuleset2__c wizardRS :listWizardRuleSet){
            if (wizardRS.Apttus__WizardStepId__c != null){
                wizardRS.Apttus__WizardStepId__c = wizardStepIds.get(wizardRS.Apttus__WizardStepId__c);
            }
            if (wizardRS.Apttus__ToWizardStepId__c != null){
                wizardRS.Apttus__ToWizardStepId__c = wizardStepIds.get(wizardRS.Apttus__ToWizardStepId__c);
            }
            if(wizardRS.Apttus__WizardInputControlId__c != null){
                wizardRS.Apttus__WizardInputControlId__c = wizardInputControlIds.get(wizardRS.Apttus__WizardInputControlId__c);
            }
            setObjectNames.add(wizardRS.Apttus__ContextObject__c);
        }
        
        for (RecordType rType :[select Id, DeveloperName, SobjectType from RecordType where SobjectType IN :setObjectNames]){
            mapRecordTypeNameToId.put(rType.SobjectType+'_'+rType.DeveloperName, rType.Id);
        }

        for (Apttus__WizardRuleset2__c wizardRS :listWizardRuleSet){
            if (wizardRS.Apttus__RecordTypeId__c != null && mapRecordTypeNameToId.containsKey(wizardRS.Apttus__ContextObject__c+'_'+wizardRS.APTS_Record_Type_Name__c)){
                wizardRS.Apttus__RecordTypeId__c = mapRecordTypeNameToId.get(wizardRS.Apttus__ContextObject__c+'_'+wizardRS.APTS_Record_Type_Name__c);
            }
        }
        
        Database.UpsertResult[] srList = Database.upsert(listWizardRuleSet,fkey4,false);
        updateMessage(srList, 'Wizard Ruleset : ');
        
        List<Apttus__WizardRuleset2__c> exisitingWizardRuleSets = [Select Id, APTS_External_Id__c from Apttus__WizardRuleset2__c];
        for (Apttus__WizardRuleset2__c wizardRuleSets :exisitingWizardRuleSets){
            wizardRuleSetsIds.put(wizardRuleSets.APTS_External_Id__c, wizardRuleSets.Id);
        }
    }
	
	public void importWizardRule(){
	    List<Apttus__WizardRule2__c> listWizardRuleSet = (List<Apttus__WizardRule2__c>)JSON.deserialize(wizardRuleJSON, List<Apttus__WizardRule2__c>.class);
    	Schema.SObjectField fkey5 = Apttus__WizardRule2__c.Fields.APTS_External_Id__c;
    	
    	for (Apttus__WizardRule2__c wizardR :listWizardRuleSet){
    	    if (wizardR.Apttus__WizardRulesetId__c != null){
                wizardR.Apttus__WizardRulesetId__c = wizardRuleSetsIds.get(wizardR.Apttus__WizardRulesetId__c);
    	    }
    	    if(wizardR.Apttus__FromInputControlId__c != null){
                wizardR.Apttus__FromInputControlId__c = wizardInputControlIds.get(wizardR.Apttus__FromInputControlId__c);
    	    }
    	}
    	
        Database.UpsertResult[] srList = Database.upsert(listWizardRuleSet,fkey5,false);
        updateMessage(srList, 'Wizard Rule : ');

    	List<Apttus__WizardRule2__c> exisitingWizardRuleSets = [Select Id, APTS_External_Id__c from Apttus__WizardRule2__c];
        for (Apttus__WizardRule2__c wizardRule :exisitingWizardRuleSets){
            wizardRuleIds.put(wizardRule.APTS_External_Id__c, wizardRule.Id);
    	}
	}
	
	public void updateMessage(Database.UpsertResult[] srList, String strMessage){
	    String errorMessage = null;
        for (Database.UpsertResult sr : srList) {
            if (sr.isSuccess()) {
            // Operation was successful
            }
            else {
            // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    errorMessage = 'Error has occurred.' + err.getStatusCode() + ': ' + err.getMessage();                    
                    errorMessage = errorMessage +' fields that affected this error: ' + err.getFields() + '<br/>';
            
                }
            }
    	}
    	if (errorMessage == null){
    	    statusString =  statusString + strMessage + 'Success' + '<br/>';
    	}
    	else{
    	    statusString = statusString + strMessage + errorMessage;
    	}
	}
}