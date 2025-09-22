public with sharing class CreditLimitWrapperManager {
    
    public static final String CREDITSEGMENTID = '5370'; // Now it is a constant but in the future it will be mapped properly (salesforce/cpi)
    
    public static CreditLimitWrappers.AccountRequest createAccountRequest(String agencyId,String objectCurrency,String boschPartnerId){
            CreditLimitWrappers creditLimitWrapper = new CreditLimitWrappers();

            CreditLimitWrappers.AccountRequest accRequest= new CreditLimitWrappers.AccountRequest();
            accRequest.debtorPartyInternalID=boschPartnerId;
            accRequest.CreditsegmentInternalID= CREDITSEGMENTID;
            accRequest.schemeAgencyID = agencyId;
            accRequest.languageCode = objectCurrency;

            return accRequest;
        }

    public static CreditLimitWrappers.CreditWorthinessQueryRequest createCreditWorthinessRequest(String agencyId,Decimal objectAmount,String objectCurrency,String boschPartnerId){

        
        //			TO CHECK 
        CreditLimitWrappers.CheckingSchedule schedule= new CreditLimitWrappers.CheckingSchedule();

        
        schedule.ValuationDate= Date.newInstance(2025,02,10); // check if needs to be today or a static date
        schedule.CheckedAmount= objectAmount;
        schedule.CreditSegmentInternalID= CREDITSEGMENTID;
        schedule.currencyCode= objectCurrency;

        CreditLimitWrappers.DebtorParty debtor = new CreditLimitWrappers.DebtorParty();
        debtor.InternalID= boschPartnerId;
        debtor.schemeAgencyID = agencyId;


        CreditLimitWrappers.CreditWorthinessQueryRequest request= new CreditLimitWrappers.CreditWorthinessQueryRequest();
        request.CreditSegmentInternalID= CREDITSEGMENTID;
        request.DebtorParty=debtor;
        request.CheckingSchedule=schedule;

        return request;

    }
        
   
}