/**
* @author       APB
* @description  CreditLimitUtilMethods: Util class used to reutilize methods
*/
public class CreditLimitUtilMethods {

    private static final Map<String, String> replacementResponseMap = new Map<String, String>{
        '"$"' => '"dollar"',
        '"@languageCode"' => '"languageCode"',
        '"@schemeID"' => '"schemeID"',
        '"@schemeAgencyID"' => '"schemeAgencyID"',
        '"@currencyCode"' => '"currencyCode"',
        '"CreditsegmentInternalID"' => '"creditsegmentInternalID"',
        '"DebtorPartyInternalID"' => '"debtorPartyInternalID"',
        '"id"' => '"auxId"',
        '"date"' => '"actualDate"',
        '"number"' => '"taxNumber"'
    };

    private static final Map<String, String> replacementRequestMap = new Map<String, String>{
        '"auxId"' => '"id"',
        '"actualDate"' => '"date"',
        '"dollar"' => '"$"',
        '"creditsegmentInternalID"' => '"CreditsegmentInternalID"',
        '"debtorPartyInternalID"' => '"DebtorPartyInternalID"',
        '"taxNumber"' => '"number"'
    };

    public static String formatRequest(String bodyWrapper) {
        for (String key : replacementRequestMap.keySet()) {
            bodyWrapper = bodyWrapper.replace(key, replacementRequestMap.get(key));
        }
        return bodyWrapper;
    }

    public static String formatResponse(String bodyWrapper) {
        for (String key : replacementResponseMap.keySet()) {
            bodyWrapper = bodyWrapper.replace(key, replacementResponseMap.get(key));
        }
        return bodyWrapper;
    }
}