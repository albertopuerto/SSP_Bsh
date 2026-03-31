/**
 * @description Controller for CPQ External Configurator with SAP VC Integration
 * Uses External Credentials for OAuth2 authentication with SAP BTP
 * @author APC
 * @date 2026-01-28
 */
global with sharing class CPQExternalConfiguratorController {

    /**
     * @description Get SAP VC Variants UI URL
     * @return URL to load in iframe
     */
    webservice static String getVariantsUIUrl() {
        return SAPVcProductConfigurationService.getVariantsUIUrl();
    }


    /**
     * @description Call SAP VC Variant Configuration Service
     * @param configData JSON string with configuration data
     * @return Response from SAP VC Variants service
     */
    webservice static String callVariantConfigurationService(String configData) {
        return SAPVcProductConfigurationService.callVariantConfigurationService(configData);
    }

    /**
     * @description Call SAP VC Pricing Service
     * @param pricingData JSON string with pricing data
     * @return Response from SAP VC Pricing service
     */
    webservice static String callPricingService(String pricingData) {
        try {
            System.debug('=== WEBSERVICE: callPricingService called ===');
            System.debug('=== Pricing Data: ' + pricingData);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SAP_VC_Pricing/api/v1/pricing');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(pricingData);
            req.setTimeout(30000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('=== Status Code: ' + res.getStatusCode());
            System.debug('=== Response: ' + res.getBody());

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                System.debug('=== callPricingService SUCCESS ===');
                return res.getBody();
            } else {
                System.debug('=== callPricingService ERROR: ' + res.getStatusCode());
                throw new CalloutException('Pricing service call failed: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('=== EXCEPTION: ' + e.getTypeName() + ' - ' + e.getMessage());
            System.debug('=== STACK: ' + e.getStackTraceString());
            throw e;
        }
    }

    /**
     * @description Create pricing document (v1)
     */
    webservice static String pricingCreateDocument(String documentBody) {
        return callPricingApi('POST', '/api/v1/pricing/documents', documentBody);
    }

    /**
     * @description Create pricing items for a document (v1)
     */
    webservice static String pricingCreateItems(String documentId, String itemsBody, String ifMatch) {
        System.debug('=== pricingCreateItems called ===');
        System.debug('=== Raw documentId: ' + documentId);
        
        // UUID doesn't need URL encoding - use as-is
        Map<String, String> headers = new Map<String, String>();
        if (!String.isBlank(ifMatch)) {
            headers.put('If-Match', ifMatch);
        }
        return callPricingApi('POST', '/api/v1/pricing/documents/' + documentId + '/items', itemsBody, headers);
    }

    /**
     * @description Get pricing document by id (v1)
     */
    webservice static String pricingGetDocument(String documentId) {
        // UUID doesn't need URL encoding - use as-is
        return callPricingApi('GET', '/api/v1/pricing/documents/' + documentId, null);
    }

    /**
     * @description Get pricing procedures list (v1)
     */
    webservice static String pricingGetProcedures(String salesOrganization, String replicated) {
        List<String> params = new List<String>();
        if (!String.isBlank(salesOrganization)) {
            params.add('salesOrganization=' + EncodingUtil.urlEncode(salesOrganization, 'UTF-8'));
        }
        if (!String.isBlank(replicated)) {
            params.add('replicated=' + EncodingUtil.urlEncode(replicated, 'UTF-8'));
        }

        String path = '/api/v1/customizing/procedures';
        if (!params.isEmpty()) {
            path += '?' + String.join(params, '&');
        }

        return callPricingApi('GET', path, null);
    }

    /**
     * @description Get pricing procedure details (v1)
     */
    webservice static String pricingGetProcedure(String pricingProcedureId) {
        String safeId = EncodingUtil.urlEncode(pricingProcedureId, 'UTF-8');
        return callPricingApi('GET', '/api/v1/customizing/procedures/' + safeId, null);
    }

    /**
     * @description Add header conditions to a pricing document (v1)
     */
    webservice static String pricingAddHeaderCondition(String documentId, String conditionsBody) {
        // UUID doesn't need URL encoding - use as-is
        return callPricingApi('POST', '/api/v1/pricing/documents/' + documentId + '/conditions', conditionsBody);
    }

    /**
     * @description Determine knowledge base based on search criteria
     * @param productId Product ID (optional)
     * @param validityDate Validity date (optional)
     * @param type Product type (optional)
     * @param plant Plant (optional)
     * @return Response from SAP VC knowledge base determination
     */
    webservice static String determineKnowledgebase(String productId, String validityDate, String type, String plant) {
        return SAPVcProductConfigurationService.determineKnowledgebase(productId, validityDate, type, plant);
    }

    /**
     * @description Get knowledge base by Id (v2)
     * @param kbId Knowledge base id
     * @return Response from SAP VC knowledge base
     */
    webservice static String getKnowledgebaseById(String kbId) {
        return SAPVcProductConfigurationService.getKnowledgebaseById(kbId);
    }

    /**
     * @description Get knowledge base translations (v2)
     * @param kbId Knowledge base id
     * @param language Language code (optional, e.g., en, de, es)
     * @return Response from SAP VC knowledge base translations
     */
    webservice static String getKnowledgebaseTranslations(String kbId, String language) {
        return SAPVcProductConfigurationService.getKnowledgebaseTranslations(kbId, language);
    }

    /**
     * @description Create configuration (v2)
     * @param configData JSON string with configuration data
     * @return Response from SAP VC create configuration
     */
    webservice static String createConfigurationV2(String configData) {
        return SAPVcProductConfigurationService.createConfigurationV2(configData);
    }

    /**
     * @description Get configuration by Id (v2)
     * @param configId Configuration id
     * @return JSON response with configuration data and ETag header
     */
    webservice static String getConfigurationV2(String configId) {
        return SAPVcProductConfigurationService.getConfigurationV2(configId);
    }

    /**
     * @description Patch configuration by Id (v2)
     * @param configId Configuration id
     * @param patchData JSON Patch payload
     * @return Response from SAP VC configuration patch
     */
    webservice static String patchConfigurationV2(String configId, String patchData) {
        return SAPVcProductConfigurationService.patchConfigurationV2(configId, patchData);
    }

    /**
     * @description Patch configuration characteristics by updating individual characteristics
     */
    webservice static String patchConfigurationCharacteristics(String configId, String etag, String patchOperations) {
        return SAPVcProductConfigurationService.patchConfigurationCharacteristics(configId, etag, patchOperations);
    }

    /**
     * @description Complete configuration (v2)
     * @param configId Configuration id
     * @return Response from SAP VC configuration complete
     */
    webservice static String completeConfigurationV2(String configId) {
        return SAPVcProductConfigurationService.completeConfigurationV2(configId);
    }

    /**
     * @description Delete configuration (v2)
     */
    webservice static String deleteConfigurationV2(String configId) {
        return SAPVcProductConfigurationService.deleteConfigurationV2(configId);
    }

    /**
     * @description Lock or unlock configuration (v2)
     */
    webservice static String lockConfigurationV2(String configId, String lockBody) {
        return SAPVcProductConfigurationService.lockConfigurationV2(configId, lockBody);
    }

    /**
     * @description Reset configuration (v2)
     */
    webservice static String resetConfigurationV2(String configId) {
        return SAPVcProductConfigurationService.resetConfigurationV2(configId);
    }

    /**
     * @description Update multiple characteristics by item (v2)
     */
    webservice static String patchConfigurationItemV2(String configId, String itemId, String itemPatchData) {
        return SAPVcProductConfigurationService.patchConfigurationItemV2(configId, itemId, itemPatchData);
    }

    /**
     * @description Get item characteristics (v2)
     */
    webservice static String getItemCharacteristicsV2(String configId, String itemId, String filter) {
        return SAPVcProductConfigurationService.getItemCharacteristicsV2(configId, itemId, filter);
    }

    /**
     * @description Get external configurations header list (v2)
     */
    webservice static String getExternalConfigurationsV2() {
        return SAPVcProductConfigurationService.getExternalConfigurationsV2();
    }

    /**
     * @description Load or copy an external configuration (v2)
     */
    webservice static String loadExternalConfigurationV2(String body, String sourceConfigurationId, String selectValue) {
        return SAPVcProductConfigurationService.loadExternalConfigurationV2(body, sourceConfigurationId, selectValue);
    }

    /**
     * @description Get external configuration by id (v2)
     */
    webservice static String getExternalConfigurationByIdV2(String configId) {
        return SAPVcProductConfigurationService.getExternalConfigurationByIdV2(configId);
    }

    /**
     * @description Get external configuration for display by id (v2)
     */
    webservice static String getExternalConfigurationDisplayByIdV2(String configId) {
        return SAPVcProductConfigurationService.getExternalConfigurationDisplayByIdV2(configId);
    }

    /**
     * @description Get knowledge base metrics (v2)
     */
    webservice static String getKnowledgebaseMetrics(String kbId) {
        return SAPVcProductConfigurationService.getKnowledgebaseMetrics(kbId);
    }

    /**
     * @description Get knowledge base dependency by id (v2)
     */
    webservice static String getKnowledgebaseDependencyById(String kbId, String dependencyId) {
        return SAPVcProductConfigurationService.getKnowledgebaseDependencyById(kbId, dependencyId);
    }

    /**
     * @description Get variant table by id (v2)
     */
    webservice static String getKnowledgebaseVariantTableById(
        String kbId,
        String variantTableId,
        String language,
        String top,
        String skip
    ) {
        return SAPVcProductConfigurationService.getKnowledgebaseVariantTableById(kbId, variantTableId, language, top, skip);
    }

    /**
     * @description Shared callout helper for SAP VC Pricing APIs (v1)
     */
    private static String callPricingApi(String method, String path, String body) {
        return callPricingApi(method, path, body, new Map<String, String>());
    }

    private static String callPricingApi(String method, String path, String body, Map<String, String> customHeaders) {
        try {
            String endpoint = 'callout:SAP_VC_Pricing' + path;

            System.debug('=== SAP VC Pricing API CALL ===');
            System.debug('=== Method: ' + method);
            System.debug('=== Path: ' + path);
            System.debug('=== Full Endpoint: ' + endpoint);

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            
            // Add custom headers (e.g., If-Match)
            if (customHeaders != null && !customHeaders.isEmpty()) {
                for (String headerName : customHeaders.keySet()) {
                    req.setHeader(headerName, customHeaders.get(headerName));
                    System.debug('=== Custom header: ' + headerName + ' = ' + customHeaders.get(headerName));
                }
            }
            
            if (body != null) {
                req.setBody(body);
                System.debug('=== Request body: ' + body);
            }
            req.setTimeout(30000);

            System.debug('=== About to send HTTP request...');
            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('=== Status Code: ' + res.getStatusCode());
            System.debug('=== Response Header Keys: ' + String.join(new List<String>(res.getHeaderKeys()), ', '));
            System.debug('=== Response Body (first 1000 chars): ' + res.getBody().substring(0, Math.min(1000, res.getBody().length())));

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                System.debug('=== Pricing API call SUCCESS');
                return res.getBody();
            }

            String errorBody = res.getBody() != null ? res.getBody() : 'No response body';
            String errorJson = '{"error":true,"status":' + res.getStatusCode() +
                              ',"message":"SAP VC Pricing API Error ' + res.getStatusCode() + ': ' +
                              errorBody.escapeJava() + '"}';
            System.debug('=== Pricing API call FAILED: ' + errorJson);
            throw new CalloutException(errorJson);
        } catch (CalloutException ce) {
            System.debug('=== CALLOUT EXCEPTION in callPricingApi: ' + ce.getTypeName());
            System.debug('=== Message: ' + ce.getMessage());
            System.debug('=== Stack: ' + ce.getStackTraceString());
            throw ce;
        } catch (Exception e) {
            System.debug('=== EXCEPTION in callPricingApi: ' + e.getTypeName());
            System.debug('=== Message: ' + e.getMessage());
            System.debug('=== Stack: ' + e.getStackTraceString());
            throw e;
        }
    }

    /**
     * @description Validate JSON configuration data
     * @param jsonData JSON string to validate
     * @return true if valid JSON, false otherwise
     */
    webservice static Boolean validateJSON(String jsonData) {
        try {
            JSON.deserializeUntyped(jsonData);
            return true;
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'JSON validation failed: ' + e.getMessage());
            return false;
        }
    }
}
