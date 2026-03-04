/**
* @description DTO class for Athena Integration
* Maps JSON payload 1:1 to this Apex class, except for "currency" → "currencyCode"
* BSSP-13685
*
* @author Iliana Dimitrova
* @date 2025-10-28
*/
public class AthenaBusinessPartnerDTO {
    
    public String  boschPartnerNumber;
    public String  boschPartnerCategory; // Organization | Person
    public Boolean centralBlock;
    public String  searchTerm1;
    public String  searchTerm2;
    public String  organizationName;
    public String  organizationName2;
    public String  organizationName3;
    public String  organizationName4;
    public Boolean liableForVAT;
    public String  exportControlUsage;
    public String  phone;
    
    public BillingAddressDTO billingAddress;
    public List<TaxNumberDTO> taxNumbers;
    public List<SalesDataDTO> salesData;
    
    
    public String  firstName;
    public String  lastName;
    public String  gender;
    public String  academicTitle;
    public String  title;
    public List<BoschPartnerRoleDTO> boschPartnerRoles;
    public PersonAddressDTO address;
    public List<BPRelationshipDTO> bPRelationships;
    
    
    public class BoschPartnerRoleDTO {
        public String boschPartnerRole;
        public String boschPartnerRoleValidFrom;
        public String boschPartnerRoleValidTo;
    }
    
    
    public class BPRelationshipDTO {
        public String boschPartnerNumberSource;
        public String boschPartnerNumberTarget;
        public String relationshipType;
        public String function;
    }
    /**
* @description nested DTO - Person Address
*/
    public class PersonAddressDTO {
        public List<String> addressUsages;
        public String country;
        public String city;
        public String postalCode;
        public String streetName;
        public String houseNumber;
        public ElectronicAddressDTO electronicAddress;
    }
    
    /**
* @description nested DTO - Electronic Address (email + phone)
*/
    public class ElectronicAddressDTO {
        public List<EmailAddressDTO> emailAddresses;
        public List<PhoneNumberDTO> phoneNumbers;
    }
    
    /**
* @description nested DTO - Email Address
*/
    public class EmailAddressDTO {
        public String  email;
        public Boolean isDefault;
    }
    /**
* @description nested DTO - Phone Number
*/
    public class PhoneNumberDTO {
        public String  phoneNumber;
        public String  countryCode;
        public Boolean isDefault;
    }
    /**
* @description nested DTO - Billing Address
*/
    public class BillingAddressDTO {
        public String street;
        public String postalCode;
        public String city;
        public String region;
        public String countryCode;
        public Double latitude;
        public Double longitude;
    }
    
    /**
* @description nested DTO - Tax Number
*/
    public class TaxNumberDTO {
        public String taxNumberCategory;
        public String taxNumber;
    }
    
    /**
* @description nested DTO - Sales Data
*/
    public class SalesDataDTO {
        public String salesArea;
        public String division;
        public String distributionChannel;
        public String salesOrganization;
        public List<PartnerFunctionEntryDTO> partnerFunctions;
        public OrderDTO order;
        public ShippingDTO shipping;
        public BillingDTO billing;
    }
    
    /**
* @description nested DTO - Partner Function
*/
    public class PartnerFunctionEntryDTO {
        public String  partnerFunction;
        public String  referencedCustomerNumber;
        public Boolean defaultPartner;
    }
    
    /**
* @description nested DTO - Order
*/
    public class OrderDTO {
        public String  customerGroup;
        public String  customerPricingProcedure;
        public String  accountAtCustomer;
        public String  currencyCode;  // will be filled by helper
        public String  priceGroup;
        public Boolean deletionFlagForCustomer;
        public String  customerOrderBlock;
        public String  salesBlockForCustomer;
    }
    
    /**
* @description nested DTO - Shipping
*/
    public class ShippingDTO {
        public String  customerDeliveryBlock;
        public String  shippingConditions;
        public String  incoterms;
        public String  incotermsPart2;
        public Boolean completeDelivery;
    }
    
    /**
* @description nested DTO - Billing
*/
    public class BillingDTO {
        public Boolean rebateRelevant;
        public TermsOfPaymentDTO termsOfPayment;
    }
    
    /**
* @description nested DTO - Terms of payment
*/
    public class TermsOfPaymentDTO {
        public String key;
        public String dayLimit;
    }
    
    // ========== Factory and Helper Methods ==========
    
    /**
* @description Deserialize JSON string into DTO.
*              Additionally maps JSON key "currency" to currencyCode.
* @param jsonString JSON payload
* @return AthenaBusinessPartnerDTO object
*/
    public static AthenaBusinessPartnerDTO fromJson(String jsonString) {
        if (String.isBlank(jsonString)) {
            return null;
        }
        // First, deserialize into a generic map
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        // Then handle "currency" remapping before deserializing into the DTO
        handleCurrencyKey(root);
        
        // Finally, convert into DTO
        return (AthenaBusinessPartnerDTO) JSON.deserialize(JSON.serialize(root), AthenaBusinessPartnerDTO.class);
    }
    
    /**
* @description Recursively traverses the map to rename all "currency" keys to "currencyCode".
* @param node Object (Map<String,Object> or List<Object>) node to inspect
*/
    private static void handleCurrencyKey(Object node) {
        if (node == null) {
            return;
        }
        
        if (node instanceof Map<String, Object>) {
            Map<String, Object> mapNode = (Map<String, Object>) node;
            renameCurrencyKey(mapNode);
            
            // Traverse deeper into child values
            for (Object val : mapNode.values()) {
                handleCurrencyKey(val);
            }
            return;
        }
        
        processListNode(node);
    }
    
    /**
* @description Processes a list node recursively.
* @param node Object expected to be a List<Object>
*/
    private static void processListNode(Object node) {
        if (!(node instanceof List<Object>)) {
            return;
        }
        
        List<Object> listNode = (List<Object>) node;
        for (Object item : listNode) {
            handleCurrencyKey(item);
        }
    }
    
    /**
* @description Checks one map node and renames "currency" key if found.
* @param mapNode Map node from JSON tree
*/
    private static void renameCurrencyKey(Map<String, Object> mapNode) {
        if (mapNode == null) {
            return;
        }
        if (mapNode.containsKey('currency')) {
            Object val = mapNode.remove('currency');
            mapNode.put('currencyCode', val);
        }
    }
}
