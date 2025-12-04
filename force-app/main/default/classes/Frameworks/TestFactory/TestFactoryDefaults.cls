/**
* @author       APC
* @date         08/04/2025
* @description  TestFactory framework: TestFactoryDefaults implements TestFactory
					To specify defaults for objects, use the naming convention [ObjectName]Defaults.
					For custom objects, omit the __c from the Object Name
*/
@IsTest
public with sharing class TestFactoryDefaults{

	/**
	* @author       APC
	* @description  AccountDefaults constructor
	*/
	public class AccountDefaults implements TestFactory.FieldDefaults {
		/**
		* @author       APC
		* @description  define account getFieldDefaults()
		* @return		Map<Schema.SObjectField, Object>
		*/
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
					Account.Name => 'Customer Account',
					Account.RecordTypeID => TestFactoryConstants.MAP_OBJ_RECORD_TYPE_IDS.get('Account').get('Customer'),
					Account.Phone => '0123456',
					Account.BillingCountry => 'bTest',
					Account.ShippingCountry => 'sTest',
					Account.txt_AthenaUUID__c => '1111',
					Account.Role__c => 'ETDE Domestic Customer',
					Account.pkl_Language__c => 'English',
					Account.pkm_BoschPartnerRole__c => 'BBCUSH'
			};
		}
	}

	/**
	* @author       APC
	* @description  SupplierAccountDefault specific default set to be used in the future, be careful,
						once this class will be changed, the test should be properly changed as well
	*/
	public class SupplierAccountDefault implements TestFactory.FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
					Account.Name => 'Supplier Account',
					Account.RecordTypeID => TestFactoryConstants.MAP_OBJ_RECORD_TYPE_IDS.get('Account').get('Supplier'),
					Account.Phone => '0123456',
					Account.txt_AthenaUUID__c => '2222',
					Account.Role__c => 'ETDE Domestic Customer',
					Account.pkl_Language__c => 'English',
					Account.pkm_BoschPartnerRole__c => 'BBCUEX'
			};
		}
	}
    /**
	* @author       APC
	* @description  OrderDefaults constructor
	*/
	public class OrderDefaults implements TestFactory.FieldDefaults {
		/**
		* @author       APC
		* @description  define contact getFieldDefaults()
		* @return		Map<Schema.SObjectField, Object>
		*/
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
					Order.Status => 'Draft',
					Order.EffectiveDate => Date.today(),
                    Order.pkl_INCOTerms1__c => 'CPT - Carriage Paid To',
                    Order.pkl_PaymentTerms__c=> 'Due on receipt',
                    Order.CurrencyIsoCode=> 'EUR',
					Order.Pricebook2Id => Test.getStandardPricebookId()
			};
		}
	}

	/**
	* @author       APC
	* @description  OrderItemDefaults constructor
	*/
	public class OrderItemDefaults implements TestFactory.FieldDefaults {
		/**
		* @author       APC
		* @description  define orderItems getFieldDefaults()
		* @return		Map<Schema.SObjectField, Object>
		*/
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
					OrderItem.txt_SAPExternalLineItemId__c => '123124124',
					OrderItem.UnitPrice => 20,
                    OrderItem.pkl_INCOTerms1__c => 'CPT - Carriage Paid To',
                    OrderItem.pkl_PaymentTerms__c=> 'Due on receipt',
					OrderItem.pkl_QuantityUnit__c=> 'Each',
					OrderItem.txt_INCOTerms2__c=> 'Due on receipt test',
                    OrderItem.Quantity=> 2
			};
		}
	}

	/**
	* @author       APC
	* @description  PricebookEntryDefaults constructor
	*/
	public class PricebookEntryDefaults implements TestFactory.FieldDefaults {
		/**
		* @author       APC
		* @description  define orderItems getFieldDefaults()
		* @return		Map<Schema.SObjectField, Object>
		*/
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
					PricebookEntry.GearsetExternalId__c => '123124124',
					PricebookEntry.Pricebook2Id => Test.getStandardPricebookId(),
					PricebookEntry.UnitPrice => 10
			};
		}
	}


	/**
	* @author       APC
	* @description  ContactDefaults constructor
	*/
	public class ContactDefaults implements TestFactory.FieldDefaults {
		/**
		* @author       APC
		* @description  define contact getFieldDefaults()
		* @return		Map<Schema.SObjectField, Object>
		*/
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
					Contact.FirstName => 'First',
					Contact.LastName => 'Last',
					Contact.mpkl_RoleMainAccount__c => '0001',
					Contact.pkl_Language__c => 'English',
					Contact.Email => 'testEmail@invalid.com',
					Contact.pkl_AccountGroup__c=> 'ETDE Contact ETCN Contact',
					Contact.pkl_Status__c => 'Active'
			};
		}
	}

	/**
	* @author       APC
	* @description  OpportunityDefaults constructor
	*/
	public class OpportunityDefaults implements TestFactory.FieldDefaults {
		/**
		* @author       APC
		* @description  define Opportunity getFieldDefaults()
		* @return		Map<Schema.SObjectField, Object>
		*/
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
            Opportunity.Name => 'Test Opportunity',
            Opportunity.StageName => 'Sales Chance (New)',
            Opportunity.CloseDate => Date.today().addDays(30),
            Opportunity.AccountId => null,  //set this in test class while generation
            Opportunity.CurrencyIsoCode => 'EUR',
            Opportunity.pklLeadingSolutionField__c => 'DAP',
            Opportunity.pklTypeOfOffering__c => 'SW',
            Opportunity.pklTypeOfOpportunity__c => 'LTA',
            Opportunity.lkp_SalesOrganization__c => null
			};
		}
	}

	/**
	 * @author       APC
	 * @description  SalesReadUserDefaults constructor
	 */
	public class SalesReadUserDefaults implements TestFactory.FieldDefaults {
		/**
		 * @author       APC
		 * @description  define user getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object>{
				User.Alias => 'userSR',
				User.Email => 'testusuario1@example.com',
				User.Emailencodingkey => 'UTF-8',
				User.Languagelocalekey => 'en_US',
				User.Localesidkey => 'en_US',
				User.Profileid => TestFactoryConstants.MAP_PROFILE_IDS.get('SalesRead'),
				User.LastName => 'Sales Read',
				User.Country => 'United States',
				User.Timezonesidkey => 'America/Los_Angeles',
				User.FederationIdentifier => 'userSalesRead@etasbosch.com' + system.currentTimeMillis(),
				User.Username => 'userSalesRead@etasbosch.com' + system.currentTimeMillis()
			};
		}
	}

	/**
	 * @author       APC
	 * @description  ProductManagerUserDefaults constructor
	 */
	public class ProductManagerUserDefaults implements TestFactory.FieldDefaults {
		/**
		 * @author       APC
		 * @description  define user getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object>{
				User.Alias => 'userPM',
				User.Email => 'testusuario1@example.com',
				User.Emailencodingkey => 'UTF-8',
				User.Languagelocalekey => 'en_US',
				User.Localesidkey => 'en_US',
				User.Profileid => TestFactoryConstants.MAP_PROFILE_IDS.get('ProductManager'),
				User.LastName => 'Test Back Office User',
				User.Country => 'United States',
				User.Timezonesidkey => 'America/Los_Angeles',
				User.FederationIdentifier => 'userPM@etasbosch.com' + system.currentTimeMillis(),
				User.Username => 'userPM@etasbosch.com' + system.currentTimeMillis(),
				User.IsActive  => true
			};
		}
	}

	/**
	 * @author       APB
	 * @description  AdminUserDefaults constructor
	 */
	public class AdminUserDefaults implements TestFactory.FieldDefaults {
		/**
		 * @author       APB
		 * @description  define user getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object>{
				User.Alias => 'Admin',
				User.Email => 'testusuario1@example.com',
				User.Emailencodingkey => 'UTF-8',
				User.Languagelocalekey => 'en_US',
				User.Localesidkey => 'en_US',
				User.Profileid => TestFactoryConstants.MAP_PROFILE_IDS.get('SystemAdministrator'),
				User.LastName => 'Test Back Office User',
				User.Country => 'United States',
				User.Timezonesidkey => 'America/Los_Angeles',
				User.FederationIdentifier => 'userPM@etasbosch.com' + system.currentTimeMillis(),
				User.Username => 'userPM@etasbosch.com' + system.currentTimeMillis(),
				User.IsActive  => true
			};
		}
	}

    public class QuoteDefaults implements TestFactory.FieldDefaults{
        /**
		 * @author       TLQ1KOR
		 * @description  define SBQQ__Quote__c getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                SBQQ__Quote__c.SBQQ__Type__c	 => 'Quote'



            };

        }
    }
    public class ContentVersionDefaults implements TestFactory.FieldDefaults{
        /**
		 * @author       TLQ1KOR
		 * @description  define Quote getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
              ContentVersion.Title => 'Test Document',
              ContentVersion.PathOnClient => 'TestDocument.pdf',
              ContentVersion.VersionData => Blob.valueOf('Test Content Data')
            };

        }
    }
    public class ContentDocumentLinkDefaults implements TestFactory.FieldDefaults{
        /**
		 * @author       TLQ1KOR
		 * @description  define Quote getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
            ContentDocumentLink.ShareType => 'V'
            };

        }
    }


    public class QuoteLineDefaults implements TestFactory.FieldDefaults{
        /**
		 * @author       TLQ1KOR
		 * @description  define Quote getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                            SBQQ__QuoteLine__c.SBQQ__Quantity__c => 1,
            SBQQ__QuoteLine__c.SBQQ__ListPrice__c => 100.00

            };

        }
    }
    public class Product2Defaults implements TestFactory.FieldDefaults{
        /**
		 * @author       TLQ1KOR
		 * @description  define Quote getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Product2.Name => 'Test Product'

            };

        }

    }

    public class SalesAreaDefaults implements TestFactory.FieldDefaults{
		/**
		 * @author       FSJ
		 * @description  define SalesArea__c getFieldDefaults()
		 * @return		Map<Schema.SObjectField, Object>
		 */
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object>{
				SalesArea__c.pkl_SalesOrg__c => 'DEM5',
				SalesArea__c.pkl_DistributionChannel__c => 'A1',
				SalesArea__c.pkl_Division__c => '01'
			};

		}
	}

}