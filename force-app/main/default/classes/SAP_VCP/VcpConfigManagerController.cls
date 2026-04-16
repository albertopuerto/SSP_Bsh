public with sharing class VcpConfigManagerController {
    @AuraEnabled
    public static String resolveProductCodeFromContext(String quoteLineId, String productId) {
        return CPQExternalConfiguratorController.resolveProductCodeFromContext(quoteLineId, productId);
    }

    @AuraEnabled
    public static String createConfigurationV2(String configData) {
        String operation = 'POST /api/v2/configurations';
        String endpoint = 'callout:SAP_VC_Product_Configuration/api/v2/configurations';
        
        try {
            // Validate input
            if (String.isBlank(configData)) {
                VcpErrorHandler.VcpError validationErr = VcpErrorHandler.handleValidationError(
                    operation,
                    'Configuration data is required',
                    new Map<String, Object> {
                        'userId' => UserInfo.getUserId(),
                        'userName' => UserInfo.getUserName()
                    }
                );
                throw new AuraHandledException(
                    validationErr.userMessage + '\n[Error ID: ' + validationErr.correlationId + ']'
                );
            }
            
            // Parse to validate JSON structure
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(configData);
            if (!payload.containsKey('productKey') || String.isBlank((String)payload.get('productKey'))) {
                VcpErrorHandler.VcpError validationErr = VcpErrorHandler.handleValidationError(
                    operation,
                    'Product key is required in configuration request',
                    payload
                );
                throw new AuraHandledException(
                    validationErr.userMessage + '\n[Error ID: ' + validationErr.correlationId + ']'
                );
            }
            
            // Call business logic
            String result = CPQExternalConfiguratorController.createConfigurationV2(configData);
            return result;
            
        } catch (AuraHandledException ex) {
            // Already handled — re-throw with correlation ID
            throw ex;
            
        } catch (Exception ex) {
            // Catch unexpected errors (API timeouts, parse errors, system limits, etc)
            VcpErrorHandler.VcpError err = VcpErrorHandler.handleException(
                ex,
                operation,
                endpoint,
                new Map<String, Object> {
                    'configData' => configData,
                    'userId' => UserInfo.getUserId(),
                    'orgId' => UserInfo.getOrganizationId(),
                    'userName' => UserInfo.getUserName()
                }
            );
            
            // Return to user with user-friendly message + correlation ID
            throw new AuraHandledException(
                err.userMessage + '\n[Error ID: ' + err.correlationId + ']'
            );
        }
    }

    @AuraEnabled
    public static String determineKnowledgebase(String productId, String validityDate, String type, String plant) {
        return CPQExternalConfiguratorController.determineKnowledgebase(productId, validityDate, type, plant);
    }

    @AuraEnabled
    public static String getConfigurationV2(String configId) {
        String operation = 'GET /api/v2/configurations/{configId}';
        String endpoint = 'callout:SAP_VC_Product_Configuration/api/v2/configurations/' + configId;
        
        try {
            // Validate input
            if (String.isBlank(configId)) {
                VcpErrorHandler.VcpError validationErr = VcpErrorHandler.handleValidationError(
                    operation,
                    'Configuration ID is required',
                    null
                );
                throw new AuraHandledException(
                    validationErr.userMessage + '\n[Error ID: ' + validationErr.correlationId + ']'
                );
            }
            
            // Call business logic
            return CPQExternalConfiguratorController.getConfigurationV2(configId);
            
        } catch (AuraHandledException ex) {
            throw ex;
            
        } catch (Exception ex) {
            VcpErrorHandler.VcpError err = VcpErrorHandler.handleException(
                ex,
                operation,
                endpoint,
                new Map<String, Object> {
                    'configId' => configId,
                    'userId' => UserInfo.getUserId()
                }
            );
            
            throw new AuraHandledException(
                err.userMessage + '\n[Error ID: ' + err.correlationId + ']'
            );
        }
    }

    /**
     * @description AuraEnabled facade for GET /api/v2/knowledgebases/{kbId}.
     * Returns KB header + products with characteristicGroups, used for tab grouping.
     * @param kbId Knowledge base id
     * @return Raw SAP JSON with KB data including products[].characteristicGroups[]
     */
    @AuraEnabled
    public static String getKnowledgebaseById(String kbId) {
        return CPQExternalConfiguratorController.getKnowledgebaseById(kbId);
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
