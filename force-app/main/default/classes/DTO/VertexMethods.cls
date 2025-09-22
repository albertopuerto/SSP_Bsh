global class VertexMethods {
    public String auxId { get; set; }
    public String transactionTypeCode { get; set; }
    public String actualDate { get; set; }
    public String currencyCode = 'EUR'; 
    public String amountTypeCode = 'NET'; 
    public CompanyInformation companyInformation { get; set; }
    public List<Item> items { get; set; }
    public List<Product> products { get; set; }
    public List<Party> parties { get; set; }

    global class CompanyInformation {
        global String assignedPartyId { get; set; }
        global AdditionalInformation additionalInformation { get; set; }

        global CompanyInformation(String id, String pass, String code, String type) {
            this.assignedPartyId = id;
            this.additionalInformation = new AdditionalInformation(pass, code, type);
        }
    }

    public class AdditionalInformation {
        public String passTaxAssistedParams { get; set; }
        public String outfcode { get; set; }
        public String orderType { get; set; }
        public String isPartnerReg { get; set; }

        public AdditionalInformation(String pass, String code, String type) {
            this.passTaxAssistedParams = pass;
            this.outfcode = code;
            this.orderType = type;
        }

        public AdditionalInformation(String isPartner) {
            this.isPartnerReg = isPartner;
        }
    }

    public class Item {
        public String id { get; set; }
        public String assignedProductId { get; set; }
        public String quantity { get; set; }
        public String unitPrice { get; set; }
        public List<AssignedParty> assignedParties { get; set; }
        public ItemAdditionalInfo additionalInformation { get; set; }

        public Item(String id, String productId, String quantity, String price, List<AssignedParty> parties, ItemAdditionalInfo info) {
            this.id = id;
            this.assignedProductId = productId;
            this.quantity = quantity;
            this.unitPrice = price;
            this.assignedParties = parties;
            this.additionalInformation = info;
        }
    }

    public class AssignedParty {
        public String id { get; set; }
        public String role { get; set; }

        public AssignedParty(String id, String role) {
            this.id = id;
            this.role = role;
        }
    }

    public class ItemAdditionalInfo {
        public String appserver { get; set; }

        public ItemAdditionalInfo(String server) {
            this.appserver = server;
        }
    }

    public class Product {
        public String id { get; set; }
        public String masterDataProductId { get; set; }

        public Product(String id, String masterId) {
            this.id = id;
            this.masterDataProductId = masterId;
        }
    }

    public class PartySimple extends Party {
        public String id { get; set; }
        public String countryRegionCode { get; set; }

        public PartySimple(String id, String country) {
            this.id = id;
            this.countryRegionCode = country;
        }

    
    }

    public class PartyComplete extends Party {
        public String id { get; set; }
        public String countryRegionCode { get; set; }
        public List<TaxRegistration> taxRegistrations { get; set; }
        public AdditionalInformation additionalInformation { get; set; }


        public PartyComplete(String id, String country, List<TaxRegistration> regs, AdditionalInformation info) {
            this.id = id;
            this.countryRegionCode = country;
            this.taxRegistrations = regs;
            this.additionalInformation = info;
        }
    }

    public abstract class Party {

    }

    public class TaxRegistration {
        public String type { get; set; }
        public String taxNumber { get; set; }
        public String countryRegionCode { get; set; }

        public TaxRegistration(String type, String enterNumber, String country) {
            this.type = type;
            this.taxNumber = enterNumber;
            this.countryRegionCode = country;
        }
    }


    public class taxAdditionalInformation{
        public String taxAssist0 { get; set; }
        public String JurisdictionLevel { get; set; }
        public String SellerRegistrationId { get; set; }
        public String Imposition { get; set; }
        public String JurisdictionName { get; set; }
        public String SitusCtry { get; set; }
        public String RateClassification { get; set; }
        public String ImpositionType { get; set; }
        public String DeductibleRate { get; set; }
        public String Level { get; set; }
        public String InvoiceTextCode { get; set; }
        public String BuyerRegistrationId { get; set; }
        public String Situs { get; set; }
    }
    public class itemAdditionalInformation{
        public String totalTax { get; set; }
        public String totalRate { get; set; }
        public String taxAssist2 { get; set; }
        public String taxAssist3 { get; set; }
        public String taxAssist0 { get; set; }
        public String taxAssist1 { get; set; }
        public String taxAssist4 { get; set; }
        public String taxCode { get; set; }
        public String outFcode25 { get; set; }

    }
    public class itemAdditionalPartnerInfo{
        public String partnerName { get; set; }
    }
    public class responseTaxes {
        public String id { get; set; }
        public String taxTypeCode { get; set; }
        public Decimal taxRate { get; set; }
        public Decimal taxableBaseAmount { get; set; }
        public Decimal taxAmount { get; set; }
        public String dueCategoryCode { get; set; }
        public Boolean isTaxDeferred { get; set; }
        public Decimal deductibleTaxRate { get; set; }
        public Decimal nonDeductibleTaxRate { get; set; }
        public Decimal deductibleTaxAmount { get; set; }
        public Decimal nonDeductibleTaxAmount { get; set; }
        public taxAdditionalInformation additionalInformation { get; set; }
    }

    public class responseItem{
        public String id { get; set; }
        public String countryRegionCode { get; set; }
        public String taxEventCode { get; set; }
        public List<responseTaxes> taxes{ get; set; }
       
        public itemAdditionalInformation additionalInformation { get; set; }
    }

    public class wrapperResponse {
         public String auxId { get; set; }
         public String actualDate { get; set; }
         public String currencyCode { get; set; }
         public String amountTypeCode { get; set; }
         public List<responseItem> items { get; set; }
         public itemAdditionalPartnerInfo additionalInformation { get; set; }
    }

}