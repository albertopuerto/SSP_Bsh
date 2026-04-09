public with sharing class VcpProductSelectorController {
    public class ProductRow {
        @AuraEnabled public Id id;
        @AuraEnabled public String productCode;
        @AuraEnabled public String name;
        @AuraEnabled public String family;
        @AuraEnabled public String description;
        @AuraEnabled public Decimal listPrice;
        @AuraEnabled public Boolean externallyConfigurable;
        @AuraEnabled public String configurationType;
        @AuraEnabled public String configurationEvent;
        @AuraEnabled public String division;
        @AuraEnabled public String materialType;
        @AuraEnabled public String crossPlant;
    }

    public class PicklistOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductRow> getProducts(String family, Boolean externallyConfigurableOnly) {
        List<String> conditions = new List<String>{ 'IsActive = true', 'ProductCode != null', 'ProductCode != \'\'' };

        if (String.isNotBlank(family)) {
            conditions.add('Family = \'' + String.escapeSingleQuotes(family) + '\'');
        }
        if (externallyConfigurableOnly == true) {
            conditions.add('SBQQ__ExternallyConfigurable__c = true');
        }

        String query =
            'SELECT Id, ProductCode, Name, Family, Description,' +
            ' SBQQ__ExternallyConfigurable__c, SBQQ__ConfigurationType__c, SBQQ__ConfigurationEvent__c,' +
            ' pkl_Division__c, pkl_MaterialType__c, txt_CrossPlant__c' +
            ' FROM Product2' +
            ' WHERE ' + String.join(conditions, ' AND ') +
            ' ORDER BY Family NULLS LAST, Name NULLS LAST LIMIT 200';

        List<Product2> products = Database.query(query);

        Set<Id> productIds = new Map<Id, Product2>(products).keySet();
        Map<Id, Decimal> priceMap = new Map<Id, Decimal>();
        for (PricebookEntry pbe : [
            SELECT Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2.IsStandard = true
              AND IsActive = true
              AND Product2Id IN :productIds
        ]) {
            priceMap.put(pbe.Product2Id, pbe.UnitPrice);
        }

        List<ProductRow> rows = new List<ProductRow>();
        for (Product2 p : products) {
            ProductRow row = new ProductRow();
            row.id = p.Id;
            row.productCode = p.ProductCode;
            row.name = p.Name;
            row.family = p.Family;
            row.description = p.Description;
            row.listPrice = priceMap.get(p.Id);
            row.externallyConfigurable = p.SBQQ__ExternallyConfigurable__c;
            row.configurationType = p.SBQQ__ConfigurationType__c;
            row.configurationEvent = p.SBQQ__ConfigurationEvent__c;
            row.division = p.pkl_Division__c;
            row.materialType = p.pkl_MaterialType__c;
            row.crossPlant = p.txt_CrossPlant__c;
            rows.add(row);
        }
        return rows;
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getProductFamilyOptions() {
        List<PicklistOption> options = new List<PicklistOption>();
        PicklistOption allOption = new PicklistOption();
        allOption.label = '— All Families —';
        allOption.value = '';
        options.add(allOption);

        for (AggregateResult ar : [
            SELECT Family fam
            FROM Product2
            WHERE Family != null AND IsActive = true
            GROUP BY Family
            ORDER BY Family
        ]) {
            String val = (String) ar.get('fam');
            PicklistOption opt = new PicklistOption();
            opt.label = val;
            opt.value = val;
            options.add(opt);
        }
        return options;
    }
}
