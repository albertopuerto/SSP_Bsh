/**
 * @description Service layer for Athena Business Partner Integration (BSSP-13685)
 * BSSP-13685
 * Wave 1 supports Organization only.
 *
 * @author Iliana Dimitrova
 * @date 2025-11-05
 */
public with sharing class AthenaBusinessPartnerService {

    private static final String EXT_ID_FIELD = 'txt_AthenaUUID__c';

    /**
     * @description Result object returned to WebService.
     */
    public class SvcResult {
        public Boolean isCreated;
        public Id accountId;
        public Id salesAreaLinkId;
        public Id partnerFunctionId;
    }

    /**
     * @description Main orchestration for processing Athena payload.
     * @param dto Parsed AthenaBusinessPartnerDTO payload
     * @return SvcResult containing record IDs
     */
    public static SvcResult process(AthenaBusinessPartnerDTO dto) {

        // Check Category before processing
        String category = getCategory(dto);

        // only supporting Organization category - Nebula Logger handling in AthenaBusinessPartnerWebService class
        if(category != 'Organization'){
            throw new ValidationException('Invalid or missing boschPartnerCategory value.');
        }

        Account findAccount = findAccountByExternal(dto.boschPartnerNumber);
        Boolean isNew = findAccount == null ? true : false;

            // Upsert Account by txt_AthenaUUID__c
            Account acc = upsertAccount(dto);

            // Upsert SalesAreaLink__c
            Id salesAreaId = getSalesAreaId(dto);
            SalesAreaLink__c link = upsertSalesAreaLink(acc.Id, salesAreaId, dto);

            //  Upsert BoschPartner_PartnerFunction__c
            Id partnerFuncId = getPartnerFunctionId(dto);
            Id refAccountId = getReferencedAccountId(dto);
            BoschPartner_PartnerFunction__c pf = upsertPartnerFunction(refAccountId, partnerFuncId, dto);

            SvcResult res = new SvcResult();
            res.isCreated = isNew;
            res.accountId = acc.Id;
            res.salesAreaLinkId = link != null ? link.Id : null;
            res.partnerFunctionId = pf != null ? pf.Id : null;
            return res;

    }

    /**
     * @description Reads the Bosch Partner category (Organization or Person).
     * @param dto Parsed AthenaBusinessPartnerDTO payload
     * @return Bosch Partner Category passed from the payload
     */
    private static String getCategory(AthenaBusinessPartnerDTO dto) {

        String ctg = dto?.boschPartnerCategory;

        if (String.isBlank(ctg)) {
            return null;
        }
        return dto.boschPartnerCategory.trim();
    }

    private static Id getSalesAreaId(AthenaBusinessPartnerDTO dto) {

        List<SalesArea__c> sa = [SELECT Id
                                 FROM SalesArea__c
                                 WHERE pkl_SalesOrg__c = :dto.salesData[0].salesOrganization
                                 AND pkl_DistributionChannel__c = :dto.salesData[0].distributionChannel
                                 AND pkl_Division__c = :dto.salesData[0].division
                                 WITH SYSTEM_MODE LIMIT 1
                                 ];

        // Nebula Logger handling in AthenaBusinessPartnerWebService class
        if(sa.isEmpty()){
            throw new ValidationException('No Sales Area found meeting the criteria.');
        }else{
            return sa[0].Id;
        }
    }

    private static Id getPartnerFunctionId(AthenaBusinessPartnerDTO dto) {

        List<BoschPartnerFunction__c> pf = [SELECT Id
                                            FROM BoschPartnerFunction__c
                                            WHERE txt_PartnerFunction__c = :dto.salesData[0].partnerFunctions[0].partnerFunction
                                            WITH SYSTEM_MODE LIMIT 1
                                            ];

        // Nebula Logger handling in AthenaBusinessPartnerWebService class
        if(pf.isEmpty()){
            throw new ValidationException('No Partner Function found meeting the criteria.');
        }else{
            return pf[0].Id;
        }

    }

    private static id getReferencedAccountId(AthenaBusinessPartnerDTO dto){

        List<Account> refAccount = [SELECT Id
                                    FROM Account
                                    WHERE txt_AthenaUUID__c = :dto.salesData[0].partnerFunctions[0].referencedCustomerNumber
                                    WITH SYSTEM_MODE LIMIT 1
                                    ];

        // Nebula Logger handling in AthenaBusinessPartnerWebService class
        if(refAccount.isEmpty()){
            throw new ValidationException('Refferenced Account does not exist in the database.');
        }else{
            return refAccount[0].Id;
        }

    }

    /**
     * @description Upsert account
     * @param dto Parsed AthenaBusinessPartnerDTO payload
     * @return upserted Account
     */
    private static Account upsertAccount(AthenaBusinessPartnerDTO dto) {

        Account acc = findAccountByExternal(dto.boschPartnerNumber);

        if (acc == null) {
            acc = new Account();
            acc.put(EXT_ID_FIELD, dto.boschPartnerNumber);
        }

            acc.Name = dto.organizationName;
            acc.txt_AdditionalName__c = dto.organizationName2;
            acc.Type = 'Customer';
            acc.pkl_Language__c = 'English';// temporary defaulted
            acc.CurrencyIsoCode = dto.salesData[0].order.currencyCode;
            acc.txt_SearchTerm1__c = dto.searchTerm1;
            acc.txt_SearchTerm2__c = dto.searchTerm2;
            acc.BillingStreet = dto.billingAddress.street;
            acc.BillingCity = dto.billingAddress.city;
            acc.BillingState = dto.billingAddress.region;
            acc.BillingPostalCode = dto.billingAddress.postalCode;
            acc.BillingCountry = dto.billingAddress.countryCode;
            acc.BillingLatitude = dto.billingAddress.latitude;
            acc.BillingLongitude = dto.billingAddress.longitude;
            acc.Phone = dto.phone;
            acc.chk_CustomerBlock__c = dto.centralBlock;

        if(acc.id == null){
           insert as system acc;
        }else{
            update as system acc;
        }
        return acc;
    }

    /**
     * @description Find Account record by Bosch Partner Number
     * @param externalNumber boschPartnerNumber sent by the payload
     * @return queried record or null in case so such found
     */
    private static Account findAccountByExternal(String externalNumber) {
        List<Account> acc = [
            SELECT Id, Name, CreatedDate, LastModifiedDate
            FROM Account
            WHERE txt_AthenaUUID__c = :externalNumber
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return acc.isEmpty() ? null : acc[0];
    }

    /**
     * @description Upsert SalesAreaLink__c
     * @param accountId Id of the upserted Account
     * @param salesAreaId Id of the queried SalesArea__c record
     * @param dto Parsed AthenaBusinessPartnerDTO payload
     * @return upserted SalesAreaLink__c record
     */
    private static SalesAreaLink__c upsertSalesAreaLink(Id accountId, Id salesAreaId, AthenaBusinessPartnerDTO dto) {

        SalesAreaLink__c link = findSalesAreaLink(accountId, salesAreaId);

        if (link == null) {

            link = new SalesAreaLink__c();
            link.mdr_Account__c = accountId;
            link.mdr_SalesArea__c = salesAreaId;
        }

            link.pkl_INCOTerms1__c = dto.salesData[0].shipping.incoterms;
            link.pkl_ShippingConditions__c = dto.salesData[0].shipping.shippingConditions;
            link.txt_INCOTerms2__c = dto.salesData[0].shipping.incotermsPart2;
            link.pkl_PaymentTerms__c = 'Other'; //temporary defaulted
            link.chk_CompleteDelivery__c = dto.salesData[0].shipping.completeDelivery;
            link.chk_Deletionflagforcustomer__c = dto.salesData[0].order.deletionFlagForCustomer;
            link.chk_Rebate__c = dto.salesData[0].billing.rebateRelevant;
            link.pkl_Currency__c = dto.salesData[0].order.currencyCode;
            link.pkl_CustPricProcedure__c = dto.salesData[0].order.customerPricingProcedure;
            link.pkl_CustomerDeliveryBlock__c = dto.salesData[0].shipping.customerDeliveryBlock;
            link.pkl_CustomerGroup__c = dto.salesData[0].order.customerGroup;
            link.pkl_CustomerOrderBlock__c = dto.salesData[0].order.customerOrderBlock;
            link.pkl_CustomerPriceGroup__c = dto.salesData[0].order.priceGroup;
            link.pkl_ShippingConditions__c = dto.salesData[0].shipping.shippingConditions;
            link.txt_Accountatcustomer__c = dto.salesdata[0].order.accountAtCustomer;

        if (link.Id == null) {
            insert as system link;
        } else {
            update as system link;
        }

        return link;
    }

    /**
     * @description Find SalesAreaLink__c record by Account Id and SalesAreaId
     * @param accountId uoserted Account
     * @param salesAreaId quired Sales Area
     * @return queried record or null in case so such found
     */
    private static SalesAreaLink__c findSalesAreaLink(Id accountId, Id salesAreaId) {

        List<SalesAreaLink__c> sal = [
            SELECT Id, mdr_Account__c, mdr_SalesArea__c
            FROM SalesAreaLink__c
            WHERE mdr_Account__c = :accountId
            AND mdr_SalesArea__c = :salesAreaId
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return sal.isEmpty() ? null : sal[0];
    }

    /**
     * @description Upsert BoschPartner_PartnerFunction__c
     * @param accountId Id of the upserted Account
     * @param partnerFunctionDefId Id of Parent Bosch Partner Function
     * @param dto Athena payload
     * @return upserted BoschPartner_PartnerFunction__c record
     */
    private static BoschPartner_PartnerFunction__c upsertPartnerFunction(
        Id accountId,
        Id partnerFunctionDefId,
        AthenaBusinessPartnerDTO dto
    ){
        BoschPartner_PartnerFunction__c pf = findPartnerFunction(accountId, partnerFunctionDefId);

        if (pf == null) {
            pf = new BoschPartner_PartnerFunction__c();
            pf.ReferencedAccount__c = accountId;
            pf.mdr_BoschPartnerFunction__c = partnerFunctionDefId;
        }

        pf.chk_DefaultPartner__c = dto.salesData[0].partnerFunctions[0].defaultPartner;

        if (pf.Id == null) {
            insert as system pf;
        } else {
            update as system pf;
        }

        return pf;
    }

    /**
     * @description Find BoschPartner_PartnerFunction__c record by Account Id and PartnerFunction
     * @param accountId refferenced Account
     * @param partnerFunctionDefId quired PartnerFunction
     * @return queried record or null in case so such found
     */
    private static BoschPartner_PartnerFunction__c findPartnerFunction(Id accountId, Id partnerFunctionDefId) {

        List<BoschPartner_PartnerFunction__c> pf = [
            SELECT Id, mdr_BoschPartnerFunction__c, ReferencedAccount__c
            FROM BoschPartner_PartnerFunction__c
            WHERE ReferencedAccount__c = :accountId
            AND mdr_BoschPartnerFunction__c = :partnerFunctionDefId
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return pf.isEmpty() ? null : pf[0];
    }

    /**
     * @description Custom exception type used for controlled validation errors
     */
    public class ValidationException extends Exception{}
}