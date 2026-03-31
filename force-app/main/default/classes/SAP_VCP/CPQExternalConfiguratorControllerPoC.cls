/**
 * @description Controller for CPQ External Configurator with SAP VC Integration
 * Uses External Credentials for OAuth2 authentication with SAP BTP
 * @author APC
 * @date 2026-01-28
 */
global with sharing class CPQExternalConfiguratorControllerPoC {

    /**
     * @description Get SAP VC Variants UI URL
     * @return URL to load in iframe
     */
    webservice static String getVariantsUIUrl() {
        try {
            String vcUrl = 'https://cpservices-product-configuration.cfapps.eu10.hana.ondemand.com/ui';
            System.debug(LoggingLevel.INFO, 'SAP VC Variants UI URL: ' + vcUrl);
            return vcUrl;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error en getVariantsUIUrl: ' + e.getMessage());
            throw new AuraHandledException('Error getting SAP VC URL: ' + e.getMessage());
        }
    }


    /**
     * @description Call SAP VC Variant Configuration Service
     * @param configData JSON string with configuration data
     * @return Response from SAP VC Variants service
     */
    webservice static String callVariantConfigurationService(String configData) {
        try {
            System.debug('=== WEBSERVICE: callVariantConfigurationService called ===');
            System.debug('=== Config Data: ' + configData);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SAP_VC_Product_Configuration/api/v1/configuration');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(configData);
            req.setTimeout(30000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('=== Status Code: ' + res.getStatusCode());
            System.debug('=== Response: ' + res.getBody());

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                System.debug('=== callVariantConfigurationService SUCCESS ===');
                return res.getBody();
            } else {
                System.debug('=== callVariantConfigurationService ERROR: ' + res.getStatusCode());
                throw new CalloutException('SAP VC Variants call failed: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('=== EXCEPTION: ' + e.getTypeName() + ' - ' + e.getMessage());
            System.debug('=== STACK: ' + e.getStackTraceString());
            throw e;
        }
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
        try {
            String endpoint = buildKbDeterminationEndpoint(productId, validityDate, type, plant);
            return callVariantsApi('GET', endpoint, null);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'SAP VC API Error in determineKnowledgebase: ' + e.getMessage());
            return e.getMessage();
        }
    }

    private static String buildKbDeterminationEndpoint(String productId, String validityDate, String type, String plant) {
        List<String> params = new List<String>();

        if (!String.isBlank(productId)) {
            params.add('productid=' + EncodingUtil.urlEncode(productId, 'UTF-8'));
        }
        if (!String.isBlank(validityDate)) {
            params.add('date=' + EncodingUtil.urlEncode(validityDate, 'UTF-8'));
        }

        List<String> filterParts = new List<String>();
        if (!String.isBlank(type)) {
            filterParts.add('type EQ \'' + type + '\'');
        }
        if (!String.isBlank(plant)) {
            filterParts.add('plant EQ \'' + plant + '\'');
        }
        if (!filterParts.isEmpty()) {
            String filter = String.join(filterParts, ' AND ');
            params.add('$filter=' + EncodingUtil.urlEncode(filter, 'UTF-8'));
        }

        String endpoint = '/api/v2/kbdetermination';
        if (!params.isEmpty()) {
            endpoint += '?' + String.join(params, '&');
        }

        return endpoint;
    }

    /**
     * @description Get knowledge base by Id (v2)
     * @param kbId Knowledge base id
     * @return Response from SAP VC knowledge base
     */
    webservice static String getKnowledgebaseById(String kbId) {
        try {
            String safeId = EncodingUtil.urlEncode(kbId, 'UTF-8');
            return callVariantsApi('GET', '/api/v2/knowledgebases/' + safeId, null);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'SAP VC API Error in getKnowledgebaseById: ' + e.getMessage());
            return e.getMessage();
        }
    }

    /**
     * @description Get knowledge base translations (v2)
     * @param kbId Knowledge base id
     * @param language Language code (optional, e.g., en, de, es)
     * @return Response from SAP VC knowledge base translations
     */
    webservice static String getKnowledgebaseTranslations(String kbId, String language) {
        try {
            String safeId = EncodingUtil.urlEncode(kbId, 'UTF-8');
            String endpoint = '/api/v2/knowledgebases/' + safeId + '/translations';
            
            if (!String.isBlank(language)) {
                endpoint += '?language=' + EncodingUtil.urlEncode(language, 'UTF-8');
            }
            
            return callVariantsApi('GET', endpoint, null);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'SAP VC API Error in getKnowledgebaseTranslations: ' + e.getMessage());
            return e.getMessage();
        }
    }

    /**
     * @description Create configuration (v2)
     * @param configData JSON string with configuration data
     * @return Response from SAP VC create configuration
     */
    webservice static String createConfigurationV2(String configData) {
        try {
            return callVariantsApi('POST', '/api/v2/configurations', configData);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'SAP VC API Error in createConfigurationV2: ' + e.getMessage());
            return e.getMessage();
        }
    }

    /**
     * @description Get configuration by Id (v2)
     * @param configId Configuration id
     * @return JSON response with configuration data and ETag header
     */
    webservice static String getConfigurationV2(String configId) {
        System.debug('=== getConfigurationV2 called ===');
        System.debug('=== Config ID received: ' + configId);
        System.debug('=== Config ID is blank: ' + String.isBlank(configId));
        
        if (String.isBlank(configId)) {
            throw new IllegalArgumentException('Configuration ID cannot be blank');
        }
        
        String safeId = EncodingUtil.urlEncode(configId, 'UTF-8');
        System.debug('=== Safe ID (URL encoded): ' + safeId);
        String path = '/api/v2/configurations/' + safeId;
        System.debug('=== Path: ' + path);
        
        return callVariantsApiWithETag('GET', path, null);
    }

    /**
     * @description Patch configuration by Id (v2)
     * @param configId Configuration id
     * @param patchData JSON Patch payload
     * @return Response from SAP VC configuration patch
     */
    webservice static String patchConfigurationV2(String configId, String patchData) {
        System.debug('=== PATCH Configuration V2 ===');
        System.debug('=== Config ID: ' + configId);
        System.debug('=== Patch Data: ' + patchData);
        
        String safeId = EncodingUtil.urlEncode(configId, 'UTF-8');
        return callVariantsApi('PATCH', '/api/v2/configurations/' + safeId, patchData);
    }

    /**
     * @description Patch configuration characteristics by updating individual characteristics
     */
    webservice static String patchConfigurationCharacteristics(String configId, String etag, String patchOperations) {
        System.debug('=== PATCH Configuration Characteristics ===');
        System.debug('=== Config ID: ' + configId);
        System.debug('=== ETag: ' + etag);
        System.debug('=== Patch Operations JSON: ' + patchOperations);
        
        try {
            List<Object> ops = (List<Object>) JSON.deserializeUntyped(patchOperations);
            Map<String, Object> results = new Map<String, Object>();
            Integer successCnt = 0;
            Integer totalCnt = ops.size();
            String latestETag = null;
            
            for (Object op : ops) {
                Map<String, Object> opMap = (Map<String, Object>) op;
                String charId = String.valueOf(opMap.get('characteristicId'));
                Integer itemId = Integer.valueOf(String.valueOf(opMap.get('itemId')));
                String inputJson = JSON.serialize(opMap.get('input'));
                
                try {
                    String path = '/api/v2/configurations/' + EncodingUtil.urlEncode(configId, 'UTF-8') + 
                                  '/items/' + itemId + 
                                  '/characteristics/' + EncodingUtil.urlEncode(charId, 'UTF-8');
                    
                    String endpoint = 'callout:SAP_VC_Product_Configuration' + path;
                    
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(endpoint);
                    req.setMethod('PATCH');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('If-Match', etag);
                    req.setBody(inputJson);
                    req.setTimeout(30000);
                    
                    Http http = new Http();
                    HttpResponse res = http.send(req);
                    
                    if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                        successCnt++;
                        // Try to capture ETag from response header
                        String responseETag = res.getHeader('ETag');
                        if (String.isNotBlank(responseETag)) {
                            latestETag = responseETag;
                            System.debug('=== Captured ETag from PATCH response: ' + latestETag);
                        }
                        results.put(charId, new Map<String, Object>{
                            'status' => 'success',
                            'statusCode' => res.getStatusCode(),
                            'eTag' => responseETag
                        });
                    } else {
                        results.put(charId, new Map<String, Object>{
                            'status' => 'error',
                            'statusCode' => res.getStatusCode(),
                            'error' => res.getBody()
                        });
                    }
                } catch (Exception e) {
                    results.put(charId, new Map<String, Object>{
                        'status' => 'error',
                        'error' => e.getMessage()
                    });
                }
            }
            
            Map<String, Object> summary = new Map<String, Object>();
            summary.put('success', successCnt == totalCnt);
            summary.put('successCount', successCnt);
            summary.put('totalCount', totalCnt);
            summary.put('results', results);
            
            // If all updates succeeded but we didn't capture ETag from PATCH response, do a GET to get fresh ETag
            if (successCnt == totalCnt && latestETag == null) {
                System.debug('=== All PATCHes succeeded but no ETag captured. Doing GET to fetch new ETag...');
                try {
                    String getResponse = callVariantsApiWithETag('GET', '/api/v2/configurations/' + EncodingUtil.urlEncode(configId, 'UTF-8'), null);
                    Map<String, Object> getResMap = (Map<String, Object>) JSON.deserializeUntyped(getResponse);
                    if (getResMap.containsKey('_eTag')) {
                        latestETag = String.valueOf(getResMap.get('_eTag'));
                        System.debug('=== Captured new ETag from GET response: ' + latestETag);
                        summary.put('latestETag', latestETag);
                    }
                } catch (Exception e) {
                    System.debug('=== Failed to get updated ETag via GET: ' + e.getMessage());
                }
            } else if (latestETag != null) {
                summary.put('latestETag', latestETag);
            }
            
            return JSON.serialize(summary);
            
        } catch (Exception e) {
            System.debug('=== EXCEPTION: ' + e.getMessage());
            Map<String, Object> errMap = new Map<String, Object>();
            errMap.put('error', true);
            errMap.put('message', e.getMessage());
            throw e;
        }
    }

    /**
     * @description Complete configuration (v2)
     * @param configId Configuration id
     * @return Response from SAP VC configuration complete
     */
    webservice static String completeConfigurationV2(String configId) {
        String safeId = EncodingUtil.urlEncode(configId, 'UTF-8');
        return callVariantsApi('POST', '/api/v2/configurations/' + safeId + '/complete', null);
    }

    /**
     * @description Helper for API calls that need to return ETag header
     */
    private static String callVariantsApiWithETag(String method, String path, String body) {
        try {
            String endpoint = 'callout:SAP_VC_Product_Configuration' + path;
            
            System.debug('=== SAP VC API CALL (with ETag) ===');
            System.debug('=== Method: ' + method);
            System.debug('=== Path: ' + path);
            System.debug('=== Full Endpoint: ' + endpoint);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            if (body != null) {
                req.setBody(body);
                System.debug('=== Request body: ' + body);
            }
            req.setTimeout(30000);

            System.debug('=== Sending HTTP request...');
            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('=== Status Code: ' + res.getStatusCode());
            System.debug('=== Response Body: ' + res.getBody());
            String etag = res.getHeader('ETag');
            System.debug('=== ETag Header: ' + etag);

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                System.debug('=== API call successful');
                System.debug('=== ETag value from header: ' + etag);
                
                // Try to parse body as JSON and add ETag to it
                try {
                    Map<String, Object> bodyObj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    
                    // If ETag is null from header, try to find it in the response body
                    if (String.isBlank(etag)) {
                        // Look for eTag, ETag, etag field in response
                        if (bodyObj.containsKey('eTag')) {
                            etag = String.valueOf(bodyObj.get('eTag'));
                            System.debug('=== Found eTag in body: ' + etag);
                        } else if (bodyObj.containsKey('ETag')) {
                            etag = String.valueOf(bodyObj.get('ETag'));
                            System.debug('=== Found ETag in body: ' + etag);
                        } else if (bodyObj.containsKey('etag')) {
                            etag = String.valueOf(bodyObj.get('etag'));
                            System.debug('=== Found etag in body: ' + etag);
                        } else {
                            // If still no ETag, use a default or try another approach
                            System.debug('=== No ETag found in body. Available keys: ' + String.join(new List<String>(bodyObj.keySet()), ', '));
                            // Use null - let frontend handle it or use a generated value
                            etag = null;
                        }
                    }
                    
                    bodyObj.put('_eTag', etag);
                    String result = JSON.serialize(bodyObj);
                    System.debug('=== Response with ETag added: ' + result.substring(0, Math.min(500, result.length())));
                    return result;
                } catch (Exception parseEx) {
                    System.debug('=== Exception parsing JSON: ' + parseEx.getMessage());
                    // If not JSON, return wrapper
                    Map<String, Object> wrapper = new Map<String, Object>();
                    wrapper.put('_eTag', etag);
                    wrapper.put('_body', res.getBody());
                    return JSON.serialize(wrapper);
                }
            }

            System.debug('=== API call failed with status: ' + res.getStatusCode());
            String errorBody = res.getBody() != null ? res.getBody() : 'No response body';
            String errorJson = '{"error":true,"status":' + res.getStatusCode() + 
                              ',"message":"SAP VC API Error ' + res.getStatusCode() + ': ' + 
                              errorBody.escapeJava() + '"}';
            System.debug('=== Error JSON: ' + errorJson);
            throw new CalloutException(errorJson);
            
        } catch (Exception e) {
            System.debug('=== EXCEPTION in callVariantsApiWithETag: ' + e.getTypeName());
            System.debug('=== Message: ' + e.getMessage());
            System.debug('=== Stack: ' + e.getStackTraceString());
            throw e;
        }
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
     * @description Shared callout helper for SAP VC Variants APIs (v2)
     */
    private static String callVariantsApi(String method, String path, String body) {
        try {
            String endpoint = 'callout:SAP_VC_Product_Configuration' + path;
            
            System.debug('=== SAP VC API CALL ===');
            System.debug('=== Method: ' + method);
            System.debug('=== Path: ' + path);
            System.debug('=== Full Endpoint: ' + endpoint);
            System.debug('=== Named Credential: SAP_VC_Product_Configuration');
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            if (body != null) {
                req.setBody(body);
                System.debug('=== Request body: ' + body);
            }
            req.setTimeout(30000);

            System.debug('=== Sending HTTP request...');
            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('=== Status Code: ' + res.getStatusCode());
            System.debug('=== Response Body: ' + res.getBody());

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                System.debug('=== API call successful');
                return res.getBody();
            }

            // Build structured error with status code
            System.debug('=== API call failed with status: ' + res.getStatusCode());
            String errorBody = res.getBody() != null ? res.getBody() : 'No response body';
            String errorJson = '{"error":true,"status":' + res.getStatusCode() + 
                              ',"message":"SAP VC API Error ' + res.getStatusCode() + ': ' + 
                              errorBody.escapeJava() + '"}';
            System.debug('=== Error JSON: ' + errorJson);
            throw new CalloutException(errorJson);
            
        } catch (Exception e) {
            System.debug('=== EXCEPTION in callVariantsApi: ' + e.getTypeName());
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
