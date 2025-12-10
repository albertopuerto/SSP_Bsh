/**
* @author       APC
* @date         08/04/2025
* @description  Centralized constants for TestFactory
                  Public methods that Returns:
                    - MAP_OBJ_RECORD_TYPE_IDS
                    - MAP_PROFILE_IDS
*/
public with sharing class TestFactoryConstants {
    /**
        Return a map of profile developerNames and their corresponding names.
     */
    private static final Map<String, String> MAP_PROFILES_NAMES = new Map<String, String> {
        'SalesRead' => 'Sales Read',
        'ProductManager' => 'Product Manager',
        'SalesforceAPIOnlySystemIntegrations' => 'Salesforce API Only System Integrations'
    };

    /**
    Return a map of user ids for the users invoqued in MAP_OBJ_RECORD_TYPE_IDS.
     */
    private static Map<String, Map<String, Id>> buildRecordTypeIds() {
        Map<String, Schema.RecordTypeInfo> mapAccountRTypes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        Map<String, Schema.RecordTypeInfo> mapOpportunitiesRTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();

        return new Map<String, Map<String, Id>> {
            'Account' => new Map<String, Id> {
                'Competitor' => mapAccountRTypes.get('Competitor').getRecordTypeId(),
                'Customer_B2B' => mapAccountRTypes.get('Customer_B2B').getRecordTypeId(),
                'Reseller' => mapAccountRTypes.get('Reseller').getRecordTypeId(),
                'Partner' => mapAccountRTypes.get('Partner').getRecordTypeId(),
                'Supplier' => mapAccountRTypes.get('Supplier').getRecordTypeId()
            },
            'Opportunity' => new Map<String, Id> {
                'StandardSolutionOrder' => mapOpportunitiesRTypes.get('StandardSolutionOrder').getRecordTypeId(),
                'FrameContract' => mapOpportunitiesRTypes.get('FrameContract').getRecordTypeId()
            }
        };
    }

    /**
        Return a map of profile ids for the profiles invoqued in MAP_PROFILE_IDS.
     */
    private static Map<String, Id> buildProfileIds() {
        List<Profile> lstProfiles = [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN :MAP_PROFILES_NAMES.values()
            WITH SYSTEM_MODE
        ];

        Map<String, Id> mapProfileIds = new Map<String, Id>();
        for (Profile profile : lstProfiles) {
            for (String key : MAP_PROFILES_NAMES.keySet()) {
                if (MAP_PROFILES_NAMES.get(key) == profile.Name) {
                    mapProfileIds.put(key, profile.Id);
                }
            }
        }

        return mapProfileIds;
    }

    /**
    Return a map of record type ids for the objects used in the TestFactory framework.
     */
    public static final Map<String, Map<String, Id>> MAP_OBJ_RECORD_TYPE_IDS = buildRecordTypeIds();

    /**
    Return a map of profile ids for the profiles used in the TestFactory framework.
     */
    public static final Map<String, Id> MAP_PROFILE_IDS = buildProfileIds();
}