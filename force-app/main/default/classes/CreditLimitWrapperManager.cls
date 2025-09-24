public with sharing class CreditLimitWrapperManager {
    
    public static final String CREDITSEGMENTID = '5370'; // Now it is a constant but in the future it will be mapped properly (salesforce/cpi)
    
    public static CreditLimitWrappers.AccountRequest createAccountRequest(String agencyId,String objectCurrency,String boschPartnerId){
        CreditLimitWrappers creditLimitWrapper = new CreditLimitWrappers();

        CreditLimitWrappers.AccountRequest accRequest= new CreditLimitWrappers.AccountRequest();
        accRequest.debtorPartyInternalID=boschPartnerId;
        accRequest.creditsegmentInternalID= CREDITSEGMENTID;
        accRequest.schemeAgencyID = agencyId;
        accRequest.languageCode = objectCurrency;

        return accRequest;
    }

    public static CreditLimitWrappers.CreditWorthinessQueryRequest createCreditWorthinessRequest(Decimal objectAmount,String objectCurrency,String boschPartnerId){

        String agencyId = [SELECT Id FROM Organization WITH SECURITY_ENFORCED LIMIT 1].Id;
        //			TO CHECK 
        CreditLimitWrappers.CheckingSchedule schedule= new CreditLimitWrappers.CheckingSchedule();

        
        schedule.valuationDate= Date.newInstance(2025,02,10); // check if needs to be today or a static date
        schedule.checkedAmount= objectAmount;
        schedule.creditSegmentInternalID= CREDITSEGMENTID;
        schedule.currencyCode= objectCurrency;

        CreditLimitWrappers.DebtorParty debtor = new CreditLimitWrappers.DebtorParty();
        debtor.internalID= boschPartnerId;
        debtor.schemeAgencyID = agencyId;


        CreditLimitWrappers.CreditWorthinessQueryRequest request= new CreditLimitWrappers.CreditWorthinessQueryRequest();
        request.creditSegmentInternalID= CREDITSEGMENTID;
        request.debtorParty=debtor;
        request.checkingSchedule=schedule;

        return request;

    }
        
   
}