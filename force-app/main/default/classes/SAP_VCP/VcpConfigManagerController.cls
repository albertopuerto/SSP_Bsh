public with sharing class VcpConfigManagerController {
    @AuraEnabled
    public static String resolveProductCodeFromContext(String quoteLineId, String productId) {
        return CPQExternalConfiguratorController.resolveProductCodeFromContext(quoteLineId, productId);
    }

    @AuraEnabled
    public static String createConfigurationV2(String configData) {
        return CPQExternalConfiguratorController.createConfigurationV2(configData);
    }

    @AuraEnabled
    public static String determineKnowledgebase(String productId, String validityDate, String type, String plant) {
        return CPQExternalConfiguratorController.determineKnowledgebase(productId, validityDate, type, plant);
    }

    @AuraEnabled
    public static String getConfigurationV2(String configId) {
        return CPQExternalConfiguratorController.getConfigurationV2(configId);
    }

    /**
     * @description AuraEnabled facade to retrieve KB translations used by the LWC label switcher.
     * Delegates to CPQExternalConfiguratorController.getKnowledgebaseTranslations.
     *
     * @param kbId     Knowledge base id (or name fallback when SAP accepts it)
     * @param language BCP-47 language code, e.g. en, es, de
     * @return Raw SAP JSON with translation entries
     */
    @AuraEnabled
    public static String getKnowledgebaseTranslations(String kbId, String language) {
        return CPQExternalConfiguratorController.getKnowledgebaseTranslations(kbId, language);
    }

    /**
     * @description AuraEnabled facade to retrieve KB characteristic value (enum) translations.
     * Uses $select=characteristics&$filter to include possibleValues translations.
     * @param kbId     Knowledge base id
     * @param language BCP-47 language code, e.g. en, es, de
     * @return Raw SAP JSON with characteristics and possibleValues translations
     */
    @AuraEnabled
    public static String getKnowledgebaseCharacteristicTranslations(String kbId, String language) {
        return CPQExternalConfiguratorController.getKnowledgebaseCharacteristicTranslations(kbId, language);
    }

    @AuraEnabled
    public static String patchConfigurationCharacteristics(String configId, String etag, String patchOperations) {
        return CPQExternalConfiguratorController.patchConfigurationCharacteristics(configId, etag, patchOperations);
    }

    /**
     * @description AuraEnabled facade for resetting a SAP VC configuration session.
     * Delegates to CPQExternalConfiguratorController.resetConfigurationV2.
     *
     * @param configId Unique configuration session ID
     * @param etag     ETag captured from the last GET or PATCH response, used as the
     *                 If-Match header value for optimistic concurrency. Pass null to omit.
     * @return JSON response with the reset configuration state
     */
    @AuraEnabled
    public static String resetConfigurationV2(String configId, String etag) {
        return CPQExternalConfiguratorController.resetConfigurationV2(configId, etag);
    }

    @AuraEnabled
    public static String saveConfigIdToQuote(String quoteId, String configId) {
        return CPQExternalConfiguratorController.saveConfigIdToQuote(quoteId, configId);
    }

    @AuraEnabled
    public static String getConfigIdFromQuote(String quoteId) {
        return CPQExternalConfiguratorController.getConfigIdFromQuote(quoteId);
    }

    @AuraEnabled
    public static String clearConfigIdFromQuote(String quoteId) {
        return CPQExternalConfiguratorController.clearConfigIdFromQuote(quoteId);
    }
}
