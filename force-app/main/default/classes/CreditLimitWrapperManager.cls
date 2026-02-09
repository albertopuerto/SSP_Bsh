/**
* @author       APB
* @description  CreditLimitWrapperManager: Class used to create the credit limit wrappers
*/
public with sharing class CreditLimitWrapperManager {

    public static final String CREDITSEGMENTID = '5370';
    /**
	* @author       APB
	* @description  createAccountRequest method
	* @param		agencyId String
    * @param		objectCurrency String
    * @param		boschPartnerId String
	* @return		CreditLimitWrappers.AccountRequest
	*/
    public static CreditLimitWrappers.AccountRequest createAccountRequest(String agencyId,String objectCurrency,String boschPartnerId){

            CreditLimitWrappers.AccountRequest accRequest= new CreditLimitWrappers.AccountRequest();
            accRequest.debtorPartyInternalID=boschPartnerId;
            accRequest.creditsegmentInternalID= CREDITSEGMENTID;
            accRequest.schemeAgencyID = agencyId;
            accRequest.languageCode = objectCurrency;

            return accRequest;
        }

    /**
	* @author       APB
	* @description  createRequest method
	* @param		objectAmount Decimal
    * @param		objectCurrency String
    * @param		boschPartnerId String
	* @return		CreditLimitWrappers.CreditWorthinessQueryRequest
	*/
    public static CreditLimitWrappers.CreditWorthinessQueryRequest createCreditWorthinessRequest(Decimal objectAmount,String objectCurrency,String boschPartnerId){

        String agencyId = [SELECT Id FROM Organization WITH SECURITY_ENFORCED LIMIT 1].Id;
        CreditLimitWrappers.CheckingSchedule schedule= new CreditLimitWrappers.CheckingSchedule();

        schedule.ValuationDate= Date.newInstance(2025,02,10);
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