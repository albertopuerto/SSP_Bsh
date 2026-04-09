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
     * @description Creates a new pricing document in the SAP VC Pricing service (v1).
     * Calls POST /api/v1/pricing/documents.
     * @param documentBody JSON string with the pricing document creation request
     * @return JSON response with the created document ID and metadata
     */
    webservice static String pricingCreateDocument(String documentBody) {
        return callPricingApi('POST', '/api/v1/pricing/documents', documentBody);
    }

    /**
     * @description Creates pricing items inside an existing pricing document (v1).
     * Calls POST /api/v1/pricing/documents/{documentId}/items.
     * Passes the If-Match header when an ETag is provided for optimistic concurrency.
     * @param documentId UUID of the pricing document (no URL encoding needed)
     * @param itemsBody  JSON string with the items to add to the document
     * @param ifMatch    ETag value for the If-Match header (optional)
     * @return JSON response with the created items
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
     * @description Retrieves a pricing document by its UUID (v1).
     * Calls GET /api/v1/pricing/documents/{documentId}.
     * @param documentId UUID of the pricing document
     * @return JSON response with the full pricing document
     */
    webservice static String pricingGetDocument(String documentId) {
        // UUID doesn't need URL encoding - use as-is
        return callPricingApi('GET', '/api/v1/pricing/documents/' + documentId, null);
    }

    /**
     * @description Lists pricing procedures, optionally filtered by sales organisation and replication flag (v1).
     * Calls GET /api/v1/customizing/procedures.
     * @param salesOrganization Sales organisation code to filter (optional)
     * @param replicated        'true' or 'false' to filter by replication status (optional)
     * @return JSON array of pricing procedure objects
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
     * @description Retrieves details for a single pricing procedure by ID (v1).
     * Calls GET /api/v1/customizing/procedures/{pricingProcedureId}.
     * @param pricingProcedureId Unique identifier of the pricing procedure
     * @return JSON object with the pricing procedure details
     */
    webservice static String pricingGetProcedure(String pricingProcedureId) {
        String safeId = EncodingUtil.urlEncode(pricingProcedureId, 'UTF-8');
        return callPricingApi('GET', '/api/v1/customizing/procedures/' + safeId, null);
    }

    /**
     * @description Adds header-level conditions to an existing pricing document (v1).
     * Calls POST /api/v1/pricing/documents/{documentId}/conditions.
     * @param documentId     UUID of the pricing document
     * @param conditionsBody JSON string with the conditions to add
     * @return JSON response with the updated header conditions
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
     * @description Get knowledge base characteristic (enum value) translations (v2)
     * Calls GET /api/v2/knowledgebases/{kbId}/translations?$select=characteristics&$filter=language EQ '{language}'
     * @param kbId Knowledge base id
     * @param language Language code, e.g. en, de, es
     * @return Response with characteristics and possibleValues translations
     */
    webservice static String getKnowledgebaseCharacteristicTranslations(String kbId, String language) {
        return SAPVcProductConfigurationService.getKnowledgebaseCharacteristicTranslations(kbId, language);
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
     * @description Patches multiple characteristics individually within a configuration session.
     * Delegates to {@link SAPVcProductConfigurationService#patchConfigurationCharacteristics}.
     * Each operation targets one characteristic; the method iterates all and returns an aggregated summary.
     * @param configId        Unique configuration session ID
     * @param etag            Current ETag for the If-Match header (optimistic concurrency)
     * @param patchOperations JSON array of operations, each with 'characteristicId', 'itemId', and 'input'
     * @return JSON summary with 'success', 'successCount', 'totalCount', 'results' map, and 'latestETag'
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
     * @description Deletes a configuration session from SAP VC (v2).
     * Calls DELETE /api/v2/configurations/{configId}.
     * @param configId Unique configuration session ID
     * @return Empty body on success (HTTP 204)
     */
    webservice static String deleteConfigurationV2(String configId) {
        return SAPVcProductConfigurationService.deleteConfigurationV2(configId);
    }

    /**
     * @description Locks or unlocks a configuration session to prevent concurrent modifications (v2).
     * Calls PATCH /api/v2/configurations/{configId}/lock.
     * @param configId Unique configuration session ID
     * @param lockBody JSON object with 'locked' boolean, e.g. {"locked":true}
     * @return JSON response with updated lock state
     */
    webservice static String lockConfigurationV2(String configId, String lockBody) {
        return SAPVcProductConfigurationService.lockConfigurationV2(configId, lockBody);
    }

    /**
     * @description Resets a configuration session to its initial default values (v2).
     * Calls POST /api/v2/configurations/{configId}/reset.
     *
     * The etag parameter was added to support optimistic concurrency (If-Match header)
     * required by SAP on this endpoint. Passing null is safe and omits the header,
     * preserving backwards compatibility for existing callers (e.g. Visualforce page).
     *
     * @param configId Unique configuration session ID
     * @param etag     Current ETag value for If-Match header. Pass null to omit.
     * @return JSON response with the reset configuration state
     */
    webservice static String resetConfigurationV2(String configId, String etag) {
        return SAPVcProductConfigurationService.resetConfigurationV2(configId, etag);
    }

    /**
     * @description Applies a JSON Patch update to a specific item within a configuration session (v2).
     * Calls PATCH /api/v2/configurations/{configId}/items/{itemId}.
     * @param configId      Unique configuration session ID
     * @param itemId        Item identifier within the configuration
     * @param itemPatchData JSON Patch array (RFC 6902) with operations for the item
     * @return JSON response with the updated item state
     */
    webservice static String patchConfigurationItemV2(String configId, String itemId, String itemPatchData) {
        return SAPVcProductConfigurationService.patchConfigurationItemV2(configId, itemId, itemPatchData);
    }

    /**
     * @description Retrieves the characteristics of a specific item in a configuration session (v2).
     * Calls GET /api/v2/configurations/{configId}/items/{itemId}/characteristics
     * with an optional OData $filter expression.
     * @param configId Unique configuration session ID
     * @param itemId   Item identifier within the configuration
     * @param filter   OData $filter expression to narrow results (optional)
     * @return JSON array of characteristic objects for the item
     */
    webservice static String getItemCharacteristicsV2(String configId, String itemId, String filter) {
        return SAPVcProductConfigurationService.getItemCharacteristicsV2(configId, itemId, filter);
    }

    /**
     * @description Lists all available external configuration headers stored in SAP VC (v2).
     * Calls GET /api/v2/externalConfigurations.
     * @return JSON array of external configuration header objects
     */
    webservice static String getExternalConfigurationsV2() {
        return SAPVcProductConfigurationService.getExternalConfigurationsV2();
    }

    /**
     * @description Creates or copies an external configuration in SAP VC (v2).
     * Calls POST /api/v2/externalConfigurations with optional query parameters.
     * @param body                  JSON request body for the external configuration
     * @param sourceConfigurationId ID of an existing configuration to copy from (optional)
     * @param selectValue           OData $select expression to limit response fields (optional)
     * @return JSON response with the created external configuration
     */
    webservice static String loadExternalConfigurationV2(String body, String sourceConfigurationId, String selectValue) {
        return SAPVcProductConfigurationService.loadExternalConfigurationV2(body, sourceConfigurationId, selectValue);
    }

    /**
     * @description Retrieves a single external configuration by its unique identifier (v2).
     * Calls GET /api/v2/externalConfigurations/{configId}.
     * @param configId Unique external configuration ID
     * @return JSON object with external configuration details
     */
    webservice static String getExternalConfigurationByIdV2(String configId) {
        return SAPVcProductConfigurationService.getExternalConfigurationByIdV2(configId);
    }

    /**
     * @description Retrieves the display representation of an external configuration (v2).
     * Calls GET /api/v2/externalConfigurations/{configId}/display.
     * Useful for rendering a read-only summary of a saved configuration.
     * @param configId Unique external configuration ID
     * @return JSON object with display-ready configuration data
     */
    webservice static String getExternalConfigurationDisplayByIdV2(String configId) {
        return SAPVcProductConfigurationService.getExternalConfigurationDisplayByIdV2(configId);
    }

    /**
     * @description Retrieves runtime metrics for a knowledge base (v2).
     * Calls GET /api/v2/knowledgebases/{kbId}/metrics.
     * @param kbId Unique knowledge base ID
     * @return JSON object with knowledge base metrics (class counts, object sizes, etc.)
     */
    webservice static String getKnowledgebaseMetrics(String kbId) {
        return SAPVcProductConfigurationService.getKnowledgebaseMetrics(kbId);
    }

    /**
     * @description Retrieves a specific dependency net from a knowledge base (v2).
     * Calls GET /api/v2/knowledgebases/{kbId}/dependencies/{dependencyId}.
     * @param kbId         Unique knowledge base ID
     * @param dependencyId Unique dependency net ID within the knowledge base
     * @return JSON object with the dependency net details
     */
    webservice static String getKnowledgebaseDependencyById(String kbId, String dependencyId) {
        return SAPVcProductConfigurationService.getKnowledgebaseDependencyById(kbId, dependencyId);
    }

    /**
     * @description Retrieves the rows of a variant table stored in a knowledge base (v2).
     * Calls GET /api/v2/knowledgebases/{kbId}/variantTables/{variantTableId}
     * with optional language, pagination, and skip query parameters.
     * @param kbId           Unique knowledge base ID
     * @param variantTableId Unique variant table ID within the knowledge base
     * @param language       BCP-47 language code for translated values (optional)
     * @param top            Maximum number of rows to return, OData $top (optional)
     * @param skip           Number of rows to skip for pagination, OData $skip (optional)
     * @return JSON object with variant table rows
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
     * @description Shared callout helper for all SAP VC Pricing API requests.
     * Builds the endpoint from the named credential 'callout:SAP_VC_Pricing' plus the given path,
     * sets Content-Type: application/json, appends any custom headers, sends the request,
     * and returns the response body on 2xx. Throws a structured CalloutException on non-2xx.
     * @param method  HTTP method (GET, POST, PATCH, DELETE)
     * @param path    Relative path appended to the named credential base URL, e.g. /api/v1/pricing/documents
     * @param body    Request body JSON string (null for bodyless requests)
     * @return Response body string from SAP VC Pricing
     */
    private static String callPricingApi(String method, String path, String body) {
        return callPricingApi(method, path, body, new Map<String, String>());
    }

    /**
     * @description Overload of callPricingApi(String,String,String) that allows
     * additional request headers to be passed (e.g. If-Match for optimistic concurrency).
     * @param method        HTTP method
     * @param path          Relative path appended to the named credential base URL
     * @param body          Request body JSON string (null for bodyless requests)
     * @param customHeaders Map of extra headers to add to the request, e.g. If-Match
     * @return Response body string from SAP VC Pricing
     */
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
     * @description Resolve the SAP product code from CPQ context.
     * Pass the quoteLineId (SBQQ__QuoteLine__c Id) and/or productId (Product2 Id)
     * received as URL parameters when CPQ opens the external configurator page.
     * QuoteLineId takes precedence over productId.
     * @param quoteLineId Id of the SBQQ__QuoteLine__c record (may be null)
     * @param productId   Id of the Product2 record (may be null)
     * @return ProductCode string, or null if neither argument resolves a record
     */
    webservice static String resolveProductCodeFromContext(String quoteLineId, String productId) {
        if (!String.isBlank(quoteLineId)) {
            List<SBQQ__QuoteLine__c> lines = [
                SELECT SBQQ__Product__r.ProductCode
                FROM SBQQ__QuoteLine__c
                WHERE Id = :quoteLineId
                LIMIT 1
            ];
            if (!lines.isEmpty() && lines[0].SBQQ__Product__r != null) {
                return lines[0].SBQQ__Product__r.ProductCode;
            }
        }
        if (!String.isBlank(productId)) {
            List<Product2> products = [
                SELECT ProductCode
                FROM Product2
                WHERE Id = :productId
                LIMIT 1
            ];
            if (!products.isEmpty()) {
                return products[0].ProductCode;
            }
        }
        return null;
    }

    /**
     * @description Persists the SAP VC configuration ID into the Quote record field
     *              SBQQ__Quote__c.SAP_VCP_Config_ID__c so it can be used later for
     *              GET / PATCH / DELETE operations without reopening the configurator.
     * @param quoteId  Id of the SBQQ__Quote__c record to update
     * @param configId SAP VC configuration ID (UUID) returned by createConfigurationV2
     * @return JSON string with { success: true } or { success: false, error: "..." }
     */
    webservice static String saveConfigIdToQuote(String quoteId, String configId) {
        try {
            if (String.isBlank(quoteId) || String.isBlank(configId)) {
                return '{"success":false,"error":"quoteId and configId are required"}';
            }
            SBQQ__Quote__c quote = new SBQQ__Quote__c(
                Id = quoteId,
                SAP_VCP_Config_ID__c = configId
            );
            update quote;
            return '{"success":true,"quoteId":"' + quoteId + '","configId":"' + configId + '"}';
        } catch (Exception e) {
            return '{"success":false,"error":"' + e.getMessage().replace('"', '\\"') + '"}';
        }
    }

    /**
     * @description Reads the SAP VC configuration ID stored on the Quote record.
     * @param quoteId Id of the SBQQ__Quote__c record to inspect
     * @return JSON string with { success: true, quoteId: "...", configId: "..." }
     */
    webservice static String getConfigIdFromQuote(String quoteId) {
        try {
            if (String.isBlank(quoteId)) {
                return '{"success":false,"error":"quoteId is required"}';
            }

            SBQQ__Quote__c quote = [
                SELECT Id, SAP_VCP_Config_ID__c
                FROM SBQQ__Quote__c
                WHERE Id = :quoteId
                LIMIT 1
            ];

            Map<String, Object> result = new Map<String, Object>{
                'success' => true,
                'quoteId' => quote.Id,
                'configId' => quote.SAP_VCP_Config_ID__c
            };
            return JSON.serialize(result);
        } catch (Exception e) {
            return '{"success":false,"error":"' + e.getMessage().replace('"', '\\"') + '"}';
        }
    }

    /**
     * @description Clears the SAP VC configuration ID stored on the Quote record.
     * @param quoteId Id of the SBQQ__Quote__c record to update
     * @return JSON string with { success: true, quoteId: "...", configId: null }
     */
    webservice static String clearConfigIdFromQuote(String quoteId) {
        try {
            if (String.isBlank(quoteId)) {
                return '{"success":false,"error":"quoteId is required"}';
            }

            SBQQ__Quote__c quote = new SBQQ__Quote__c(
                Id = quoteId,
                SAP_VCP_Config_ID__c = null
            );
            update quote;

            Map<String, Object> result = new Map<String, Object>{
                'success' => true,
                'quoteId' => quoteId,
                'configId' => null
            };
            return JSON.serialize(result);
        } catch (Exception e) {
            return '{"success":false,"error":"' + e.getMessage().replace('"', '\\"') + '"}';
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
