@isTest
global class CreditLimitMockClass implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse(); 
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"Envelope":{"Header":"","Body":{"CreditManagementAccountByIDResponse":{"MessageHeader":{"ID":"D6B2D2D3CE021FD0A399EAD2F9065196","CreationDateTime":"2025-09-08T16:17:38.739Z"},"CreditManagementAccount":{"DebtorPartyInternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"},"CreditsegmentInternalID":"5370","CreditSegmentDescription":{"@languageCode":"de"},"CreditWorthinessCheckingRuleCode":"ZR","CreditWorthinessCheckingSchemeCode":"ZB","SpecialAttentionRequiredIndicator":"false","BlockedIndicator":"false","BlockingReasonCodeDescription":{"@languageCode":"de"},"CreditLimitAmount":{"@currencyCode":"EUR","$":"500000.0"},"CreditLimitValidityPeriod":{"StartDate":"2025-09-08","EndDate":"2026-09-30"},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"},"DynamicCheckCreditHorizonEndDate":"2025-10-08"},"CreditRating":{"Code":"       93","ValidityPeriod":{"StartDate":"2025-06-13","EndDate":"2026-03-07"}},"CreditRiskClass":{"Code":"B","ValidityPeriod":{"StartDate":"2025-06-13","EndDate":"2026-03-07"},"Description":{"@languageCode":"de","$":"Geringes Ausfallrisiko"}},"PaymentBehaviourSummary":{"DaysOfSalesOutstandingAverageDuration":"0 "}}}}}}');
        response.setStatusCode(200);
        return response; 
    }
}