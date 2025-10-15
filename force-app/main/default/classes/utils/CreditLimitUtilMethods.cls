/**
* @author       APB
* @description  CreditLimitUtilMethods: Util class used to reutilize methods
*/
public class CreditLimitUtilMethods {

    /**
	* @author       APB
	* @description  formatRequest method
	* @param		bodyWrapper String
	* @return		String
	*/
    public static String formatRequest(String bodyWrapper){
        String finalBody = bodyWrapper.replace('"auxId"', '"id"').replace ('"dollar"','"$"').replace ('"languageCode"','"languageCode"').replace('"actualDate"', '"date"').replace ('"@schemeID"','"schemeID"').replace ('"@schemeAgencyID"','"schemeAgencyID"').replace('"taxNumber"', '"number"')
        .replace('"creditsegmentInternalID"', '"CreditsegmentInternalID"').replace('"debtorPartyInternalID"', '"DebtorPartyInternalID"');
        return finalBody;
    }
}