public class CreditLimitUtilMethods {

    public static String formatRequest(String bodyWrapper){
        String finalBody = bodyWrapper.replace('"auxId"', '"id"').replace ('"dollar"','"$"').replace ('"languageCode"','"languageCode"').replace('"actualDate"', '"date"').replace ('"@schemeID"','"schemeID"').replace ('"@schemeAgencyID"','"schemeAgencyID"').replace('"taxNumber"', '"number"');
        
        return finalBody;
    }
}