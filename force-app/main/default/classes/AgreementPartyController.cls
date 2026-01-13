public with sharing class AgreementPartyController {

    public static final String INSERT_PARTY_ERROR = 'Unable to save Agreement Parties. Please check required fields.';
    public static final String EXCEPTION_ERROR = 'An unexpected error occurred while saving Agreement Parties.';    
    
    @AuraEnabled
    public static Boolean createAgreementParties(List<Apttus_AgreementParty__c> parties) {
        Boolean resp = true;        
            for (Apttus_AgreementParty__c party : parties) {            
                if (String.isBlank(party.pkl_PartyRole__c) || String.isBlank((String)party.lkp_AgreementParty__c)) {
                    return false;
                }
            }
			Database.SaveResult[] results = Database.insert(parties, true);			        	
				for (Database.SaveResult res : results) {
					if (!res.isSuccess()) {
						resp = false;        			
                        for (Database.Error err : res.getErrors()) {
                            //Logger.error(INSERT_PARTY_ERROR + err.getMessage());
                        }                                                            
                    }
                    //Logger.saveLog();
                }        
        return resp;
    }

    @AuraEnabled
    public static List<String> getRolePicklistValues() {
        List<String> roles = new List<String>();
        Schema.DescribeFieldResult fieldResult = Apttus_AgreementParty__c.pkl_PartyRole__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            roles.add(entry.getValue());
        }
        return roles;
    }
    
    @AuraEnabled
    public static List<String> getSignatureTypeValues() {
        List<String> types = new List<String>();
        Schema.DescribeFieldResult fieldResult = Apttus_AgreementParty__c.pkl_MultyPartySignatureType__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            types.add(entry.getValue());
        }
        return types;
    }
}