/**
* @author       APB
* @description  CreditLimitWorthinessMock: Class that contains the credit limit worthiness mock
*/
@isTest
public class CreditLimitWorthinessMock implements HttpCalloutMock {

    /**
	* @author       APB
	* @description  respond method
	* @param		request HTTPRequest
	* @return		HTTPResponse
	*/
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"Envelope":{"Header":"","Body":{"CreditWorthinessResponse":{"CreditWorthiness":{"CreditSegmentInternalID":"5370","Indicator":"true","CheckingDescription":[{"@languageCode":"en","$":"Credit segment 5370 of partner 4001831001"},{"@languageCode":"EN","$":"ID: 510936342"}],"DebtorPartyBlockedIndicator":"false","DebtorPartySpecialAttentionRequiredIndicator":"false","DynamicCheckHorizonEndDate":"2025-10-04","DebtorParty":{"InternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"}},"Rating":{"Code":"       93","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"RiskClass":{"Code":"B","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"CreditLimit":{"Amount":{"@currencyCode":"EUR","$":"500000.0"},"ValidityPeriod":{"EndDateTime":"2026-09-30T00:00:00Z"}},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"}}}}}}}');
        response.setStatusCode(200);
        return response;
    }
}