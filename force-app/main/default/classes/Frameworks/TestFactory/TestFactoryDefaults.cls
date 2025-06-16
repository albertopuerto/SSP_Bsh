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
					Account.pkl_INCOTerms1__c => 'CPT - Carriage Paid To',
					Account.pkl_PaymentTerms__c => 'Due on receipt',
					Account.txt_INCOTerms2__c => 'Inco terms 2 text area',
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
					Account.pkl_INCOTerms1__c => 'CPT - Carriage Paid To',
					Account.pkl_PaymentTerms__c => 'Due on receipt',
					Account.txt_INCOTerms2__c => 'Inco terms 2 text area',
					Account.pkl_Language__c => 'English',
					Account.pkm_BoschPartnerRole__c => 'BBCUEX'
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
					Contact.LastName => 'Last'
			};
		}
	}

	/**
	* @author       APC
	* @description  OpportunityDefault constructor
	*/
	public class OpportunityDefault implements TestFactory.FieldDefaults {
		/**
		* @author       APC
		* @description  define Opportunity getFieldDefaults()
		* @return		Map<Schema.SObjectField, Object>
		*/
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
					Opportunity.Name => 'Test Opportunity'
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
				User.Alias => 'userSalesRead',
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
				User.Username => 'userPM@etasbosch.com' + system.currentTimeMillis()
			};
		}
	}

}	
