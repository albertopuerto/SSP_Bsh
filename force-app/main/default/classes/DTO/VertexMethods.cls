/**
* @author       APB
* @description  CreditLimitWrappers: Class that contains the vertex wrappers
*/
public class VertexMethods {

    /**
	* @author       APB
	* @description  Vertex Request auxId
	*/
    public String auxId { get; set; }
    /**
	* @author       APB
	* @description  Vertex Request transactionTypeCode
	*/
    public String transactionTypeCode { get; set; }
    /**
	* @author       APB
	* @description  Vertex Request actualDate
	*/
    public String actualDate { get; set; }
    /**
	* @author       APB
	* @description  Vertex Request currencyCode
	*/
    public String currencyCode = 'EUR';
    /**
	* @author       APB
	* @description  Vertex Request amountTypeCode
	*/
    public String amountTypeCode = 'NET';
    /**
	* @author       APB
	* @description  Vertex Request companyInformation
	*/
    public CompanyInformation companyInformation { get; set; }
    /**
	* @author       APB
	* @description  Vertex Request items
	*/
    public List<Item> items { get; set; }
    /**
	* @author       APB
	* @description  Vertex Request products
	*/
    public List<Product> products { get; set; }
    /**
	* @author       APB
	* @description  Vertex Request parties
	*/
    public List<Party> parties { get; set; }

    /**
	* @author       APB
	* @description  Vertex Request wrapper CompanyInformation
	*/
    public class CompanyInformation {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper CompanyInformation assignedPartyId
	    */
        public String assignedPartyId { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper CompanyInformation additionalInformation
	    */
        public AdditionalInformation additionalInformation { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper CompanyInformation constructor
        * @param		pass String
        * @param		code String
        * @param		type String
	    */
        public CompanyInformation(String pass, String code, String type) {
            this.assignedPartyId = '5000';
            this.additionalInformation = new AdditionalInformation(pass, code, type);
        }
    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper AdditionalInformation
	*/
    public class AdditionalInformation {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AdditionalInformation passTaxAssistedParams
	    */
        public String passTaxAssistedParams { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AdditionalInformation outfcode
	    */
        public String outfcode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AdditionalInformation orderType
	    */
        public String orderType { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AdditionalInformation isPartnerReg
	    */
        public String isPartnerReg { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AdditionalInformation constructor large
        * @param		pass String
        * @param		code String
        * @param		type String
	    */
        public AdditionalInformation(String pass, String code, String type) {
            this.passTaxAssistedParams = pass;
            this.outfcode = code;
            this.orderType = type;
        }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AdditionalInformation constructor small
        * @param		isPartner String
	    */
        public AdditionalInformation(String isPartner) {
            this.isPartnerReg = isPartner;
        }
    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper Item
	*/
    public class Item {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Item id
	    */
        public String id { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Item assignedProductId
	    */
        public String assignedProductId { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Item quantity
	    */
        public String quantity { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Item unitPrice
	    */
        public String unitPrice { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Item assignedParties
	    */
        public List<AssignedParty> assignedParties { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Item additionalInformation
	    */
        public ItemAdditionalInfo additionalInformation { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Item constructor
        * @param		price String
        * @param		parties List<AssignedParty>
        * @param		info ItemAdditionalInfo
	    */
        public Item(String price, List<AssignedParty> parties, ItemAdditionalInfo info) {
            this.id = '000001';
            this.assignedProductId = 'NO_PRODUCT';
            this.quantity = '1.000';
            this.unitPrice = price;
            this.assignedParties = parties;
            this.additionalInformation = info;
        }
    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper Item
	*/
    public class AssignedParty {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AssignedParty id
	    */
        public String id { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AssignedParty role
	    */
        public String role { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper AssignedParty constructor
        * @param		id String
        * @param		role String
	    */
        public AssignedParty(String id, String role) {
            this.id = id;
            this.role = role;
        }
    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper ItemAdditionalInfo
	*/
    public class ItemAdditionalInfo {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper ItemAdditionalInfo appserver
	    */
        public String appserver { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper ItemAdditionalInfo constructor
        * @param		server String
	    */
        public ItemAdditionalInfo(String server) {
            this.appserver = server;
        }
    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper Product
	*/
    public class Product {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Product id
	    */
        public String id { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Product id masterDataProductId
	    */
        public String masterDataProductId { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper Product constructor
        * @param		id String
        * @param		masterId String
	    */
        public Product(String id, String masterId) {
            this.id = id;
            this.masterDataProductId = masterId;
        }
    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper PartySimple
	*/
    public class PartySimple extends Party {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper PartySimple id
	    */
        public String id { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper PartySimple countryRegionCode
	    */
        public String countryRegionCode { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper PartySimple constructor
        * @param		id String
        * @param		country String
	    */
        public PartySimple(String id, String country) {
            this.id = id;
            this.countryRegionCode = country;
        }
    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper PartyComplete
	*/
    public class PartyComplete extends Party {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper PartyComplete id
	    */
        public String id { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper PartyComplete countryRegionCode
	    */
        public String countryRegionCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper PartyComplete taxRegistrations
	    */
        public List<TaxRegistration> taxRegistrations { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper PartyComplete additionalInformation
	    */
        public AdditionalInformation additionalInformation { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper PartyComplete constructor
        * @param		country String
        * @param		regs List<TaxRegistration>
        * @param		info AdditionalInformation
	    */
        public PartyComplete(String country, List<TaxRegistration> regs, AdditionalInformation info) {
            this.id = 'DUMMY123';
            this.countryRegionCode = country;
            this.taxRegistrations = regs;
            this.additionalInformation = info;
        }
    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper Party
	*/
    public abstract class Party {

    }

    /**
	* @author       APB
	* @description  Vertex Request wrapper TaxRegistration
	*/
    public class TaxRegistration {
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper TaxRegistration type
	    */
        public String type { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper TaxRegistration taxNumber
	    */
        public String taxNumber { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Request wrapper TaxRegistration countryRegionCode
	    */
        public String countryRegionCode { get; set; }

        /**
	    * @author       APB
	    * @description  Vertex Request wrapper TaxRegistration constructor
        * @param		type String
        * @param		enterNumber String
        * @param		country String
	    */
        public TaxRegistration(String type, String enterNumber, String country) {
            this.type = type;
            this.taxNumber = enterNumber;
            this.countryRegionCode = country;
        }
    }

    /**
	* @author       APB
	* @description  Vertex Response wrapper TaxAdditionalInformation
	*/
    public class TaxAdditionalInformation{
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation taxAssist0
	    */
        public String taxAssist0 { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation jurisdictionLevel
	    */
        public String jurisdictionLevel { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation sellerRegistrationId
	    */
        public String sellerRegistrationId { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation imposition
	    */
        public String imposition { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation jurisdictionName
	    */
        public String jurisdictionName { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation situsCtry
	    */
        public String situsCtry { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation rateClassification
	    */
        public String rateClassification { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation impositionType
	    */
        public String impositionType { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation deductibleRate
	    */
        public String deductibleRate { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation level
	    */
        public String level { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation invoiceTextCode
	    */
        public String invoiceTextCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation buyerRegistrationId
	    */
        public String buyerRegistrationId { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper TaxAdditionalInformation situs
	    */
        public String situs { get; set; }
    }

    /**
	* @author       APB
	* @description  Vertex Response wrapper ItemAdditionalInformation
	*/
    public class ItemAdditionalInformation{
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation totalTax
	    */
        public String totalTax { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation totalRate
	    */
        public String totalRate { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation taxAssist2
	    */
        public String taxAssist2 { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation taxAssist3
	    */
        public String taxAssist3 { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation taxAssist0
	    */
        public String taxAssist0 { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation taxAssist1
	    */
        public String taxAssist1 { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation taxAssist4
	    */
        public String taxAssist4 { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation taxCode
	    */
        public String taxCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalInformation outFcode25
	    */
        public String outFcode25 { get; set; }
    }

    /**
	* @author       APB
	* @description  Vertex Response wrapper ItemAdditionalPartnerInfo
	*/
    public class ItemAdditionalPartnerInfo{
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ItemAdditionalPartnerInfo partnerName
	    */
        public String partnerName { get; set; }
    }
    /**
	* @author       APB
	* @description  Vertex Response wrapper ResponseTaxes
	*/
    public class ResponseTaxes {
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes id
	    */
        public String id { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes taxTypeCode
	    */
        public String taxTypeCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes taxRate
	    */
        public Decimal taxRate { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes taxableBaseAmount
	    */
        public Decimal taxableBaseAmount { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes taxAmount
	    */
        public Decimal taxAmount { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes dueCategoryCode
	    */
        public String dueCategoryCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes isTaxDeferred
	    */
        public Boolean isTaxDeferred { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes deductibleTaxRate
	    */
        public Decimal deductibleTaxRate { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes nonDeductibleTaxRate
	    */
        public Decimal nonDeductibleTaxRate { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes deductibleTaxAmount
	    */
        public Decimal deductibleTaxAmount { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes nonDeductibleTaxAmount
	    */
        public Decimal nonDeductibleTaxAmount { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseTaxes additionalInformation
	    */
        public TaxAdditionalInformation additionalInformation { get; set; }
    }

    /**
	* @author       APB
	* @description  Vertex Response wrapper ResponseItem
	*/
    public class ResponseItem{
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseItem id
	    */
        public String id { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseItem countryRegionCode
	    */
        public String countryRegionCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseItem taxEventCode
	    */
        public String taxEventCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseItem taxes
	    */
        public List<ResponseTaxes> taxes{ get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper ResponseItem additionalInformation
	    */
        public ItemAdditionalInformation additionalInformation { get; set; }
    }

    /**
	* @author       APB
	* @description  Vertex Response wrapper ResponseItem
	*/
    public class WrapperResponse {
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper WrapperResponse auxId
	    */
        public String auxId { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper WrapperResponse actualDate
	    */
        public String actualDate { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper WrapperResponse currencyCode
	    */
        public String currencyCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper WrapperResponse amountTypeCode
	    */
        public String amountTypeCode { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper WrapperResponse items
	    */
        public List<ResponseItem> items { get; set; }
        /**
	    * @author       APB
	    * @description  Vertex Response wrapper WrapperResponse additionalInformation
	    */
        public ItemAdditionalPartnerInfo additionalInformation { get; set; }
    }

}