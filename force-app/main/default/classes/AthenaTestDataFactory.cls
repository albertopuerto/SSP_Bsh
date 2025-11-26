@IsTest
public with sharing class AthenaTestDataFactory {

    /**
     * @description valid Athena payload
     * @return valid json
     */
    public static String getValidPayload(){
        return '{'+
                '"boschPartnerNumber": "1000904207",' +
                '"boschPartnerCategory": "Organization",'+
                '"centralBlock": true,' +
                '"searchTerm1": "Tech",' +
                '"searchTerm2": "Laptop Supplier",' +
                '"organizationName": "Test Name",' +
                '"organizationName2": "Branch office xxx",' +
                '"organizationName3": "the_last_characters_of_a_very_long_org_name",' +
                '"organizationName4": "Branch office xxx",' +
                '"liableForVAT": true,' +
                '"exportControlUsage": "1",' +
                '"phone": "+34915551234",' +
                '"billingAddress": {' +
                    '"street": "Calle del Ejemplo 45",' +
                    '"postalCode": "28080",' +
                    '"city": "Madrid",' +
                    '"region": "MAD",' +
                    '"countryCode": "ES",' +
                    '"latitude": 40.416775,' +
                    '"longitude": -3.70379' +
                '},' +
                '"salesData": [' +
                    '{' +
                    '"salesArea": "DEM5_A1_01",' +
                    '"division": "01",' +
                    '"distributionChannel": "A1",' +
                    '"salesOrganization": "DEM5",' +
                    '"partnerFunctions": [' +
                        '{' +
                        '"partnerFunction": "SP",' +
                        '"referencedCustomerNumber": "1000904207",' +
                        '"defaultPartner": true' +
                        '}' +
                    '],' +
                    '"order": {' +
                        '"customerGroup": "01",' +
                        '"customerPricingProcedure": "1",' +
                        '"accountAtCustomer": "22969R",' +
                        '"currency": "EUR",' +
                        '"priceGroup": "01",' +
                        '"deletionFlagForCustomer": false,' +
                        '"customerOrderBlock": "Y1",' +
                        '"salesBlockForCustomer": "01"' +
                    '},' +
                    '"shipping": {' +
                        '"customerDeliveryBlock": "01",' +
                        '"shippingConditions": "0A",' +
                        '"incoterms": "CIF",' +
                        '"incotermsPart2": "FOB",' +
                        '"completeDelivery": true' +
                    '},' +
                    '"billing": {' +
                        '"rebateRelevant": true,' +
                        '"termsOfPayment": {' +
                        '"key": "K972",' +
                        '"dayLimit": "72"' +
                        '}' +
                    '}' +
                    '}' +
                ']' +
                '}';
    }

    /**
     * @description invalid Athena payload - wrong entries for centralBlock, shippingConditions
     * @return invalid json
     */
    public static String getInvalidPayload(){
        return '{'+
                '"boschPartnerNumber": "1000904207",' +
                '"boschPartnerCategory": "Organization",'+
                '"centralBlock": "test",' +
                '"searchTerm1": "Tech",' +
                '"searchTerm2": "Laptop Supplier",' +
                '"organizationName": "Test Name",' +
                '"organizationName2": "Branch office xxx",' +
                '"organizationName3": "the_last_characters_of_a_very_long_org_name",' +
                '"organizationName4": "Branch office xxx",' +
                '"liableForVAT": true,' +
                '"exportControlUsage": "1",' +
                '"phone": "+34915551234",' +
                '"billingAddress": {' +
                    '"street": "Calle del Ejemplo 45",' +
                    '"postalCode": "28080",' +
                    '"city": "Madrid",' +
                    '"region": "MAD",' +
                    '"countryCode": "ES",' +
                    '"latitude": 40.416775,' +
                    '"longitude": -3.70379' +
                '},' +
                '"salesData": [' +
                    '{' +
                    '"salesArea": "DEM5_A1_01",' +
                    '"division": "01",' +
                    '"distributionChannel": "A1",' +
                    '"salesOrganization": "DEM5",' +
                    '"partnerFunctions": [' +
                        '{' +
                        '"partnerFunction": "SP",' +
                        '"referencedCustomerNumber": "1000904207",' +
                        '"defaultPartner": true' +
                        '}' +
                    '],' +
                    '"order": {' +
                        '"customerGroup": "01",' +
                        '"customerPricingProcedure": "1",' +
                        '"accountAtCustomer": "22969R",' +
                        '"currency": "EUR",' +
                        '"priceGroup": "01",' +
                        '"deletionFlagForCustomer": false,' +
                        '"customerOrderBlock": "YA",' +
                        '"salesBlockForCustomer": "01"' +
                    '},' +
                    '"shipping": {' +
                        '"customerDeliveryBlock": "01",' +
                        '"shippingConditions": "wds",' +
                        '"incoterms": "CIF",' +
                        '"incotermsPart2": "FOB",' +
                        '"completeDelivery": true' +
                    '},' +
                    '"billing": {' +
                        '"rebateRelevant": true,' +
                        '"termsOfPayment": {' +
                        '"key": "K972",' +
                        '"dayLimit": "72"' +
                        '}' +
                    '}' +
                    '}' +
                ']' +
                '}';
    }
}