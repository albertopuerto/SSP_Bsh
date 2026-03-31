/**
 * @description Service layer for SAP VC Product Configuration callouts.
 * Keeps the page controller thin and centralizes endpoint construction, callouts and error handling.
 */
public with sharing class SAPVcProductConfigurationService {

    private static final String NAMED_CREDENTIAL = 'callout:SAP_VC_Product_Configuration';
    private static final String CONTENT_TYPE_JSON = 'application/json';
    private static final Integer TIMEOUT_MS = 30000;
    private static final String VARIANTS_UI_URL = 'https://cpservices-product-configuration.cfapps.eu10.hana.ondemand.com/ui';

    /**
     * @description Returns the static URL for opening the SAP VC Variants UI in an iframe.
     * @return SAP VC Variants UI base URL
     */
    public static String getVariantsUIUrl() {
        return VARIANTS_UI_URL;
    }

    /**
     * @description Forwards a configuration request to the SAP VC v1 configuration endpoint (legacy).
     * @param configData JSON string with the variant configuration request body
     * @return JSON response body from SAP VC
     */
    public static String callVariantConfigurationService(String configData) {
        return callApi('POST', '/api/v1/configuration', configData, null, false);
    }

    /**
     * @description Determines the knowledge base that matches the given product and filter criteria.
     * Calls GET /api/v2/kbdetermination with optional query parameters.
     * @param productId     SAP product ID to restrict the search (optional)
     * @param validityDate  Validity date filter in ISO format, e.g. 2026-01-01 (optional)
     * @param type          Knowledge base type filter, e.g. MARA (optional)
     * @param plant         Plant filter (optional)
     * @return JSON array of matching knowledge base headers
     */
    public static String determineKnowledgebase(String productId, String validityDate, String type, String plant) {
        String path = buildKbDeterminationPath(productId, validityDate, type, plant);
        return callApi('GET', path, null, null, false);
    }

    /**
     * @description Retrieves full knowledge base details by its unique identifier.
     * Calls GET /api/v2/knowledgebases/{kbId}.
     * @param kbId Unique knowledge base ID
     * @return JSON object with knowledge base details
     */
    public static String getKnowledgebaseById(String kbId) {
        return callApi('GET', '/api/v2/knowledgebases/' + encode(kbId), null, null, false);
    }

    /**
     * @description Retrieves translations for a knowledge base.
     * Calls GET /api/v2/knowledgebases/{kbId}/translations with an optional language filter.
     * @param kbId     Unique knowledge base ID
     * @param language BCP-47 language code to filter results, e.g. 'en', 'de' (optional)
     * @return JSON object with translation entries for the knowledge base
     */
    public static String getKnowledgebaseTranslations(String kbId, String language) {
        String path = '/api/v2/knowledgebases/' + encode(kbId) + '/translations';
        if (!String.isBlank(language)) {
            path += '?language=' + encode(language);
        }
        return callApi('GET', path, null, null, false);
    }

    /**
     * @description Creates a new variant configuration session in SAP VC.
     * Calls POST /api/v2/configurations.
     * @param configData JSON string with the configuration creation request body
     * @return JSON response with the newly created configuration ID and initial state
     */
    public static String createConfigurationV2(String configData) {
        return callApi('POST', '/api/v2/configurations', configData, null, false);
    }

    /**
     * @description Retrieves the current state of a configuration session.
     * Calls GET /api/v2/configurations/{configId}.
     * The ETag returned by the response header is injected into the JSON body as '_eTag'
     * so callers can pass it back for subsequent PATCH operations.
     * @param configId Unique configuration session ID
     * @return JSON object with configuration state and '_eTag' field
     */
    public static String getConfigurationV2(String configId) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        return callApi('GET', '/api/v2/configurations/' + encode(configId), null, null, true);
    }

    /**
     * @description Applies a JSON Patch update to a configuration session header.
     * Calls PATCH /api/v2/configurations/{configId}.
     * @param configId  Unique configuration session ID
     * @param patchData JSON Patch array (RFC 6902) with operations to apply
     * @return JSON response with updated configuration state
     */
    public static String patchConfigurationV2(String configId, String patchData) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        return callApi('PATCH', '/api/v2/configurations/' + encode(configId), patchData, null, false);
    }

    /**
     * @description Patches multiple characteristics individually within a configuration session.
     * Iterates over the provided operations and calls
     * PATCH /api/v2/configurations/{configId}/items/{itemId}/characteristics/{characteristicId}
     * for each one. Captures the latest ETag from successful responses.
     * @param configId       Unique configuration session ID
     * @param etag           Current ETag value for optimistic concurrency (If-Match header)
     * @param patchOperations JSON array of operation objects, each with
     *                        'characteristicId', 'itemId', and 'input' fields
     * @return JSON summary object with 'success', 'successCount', 'totalCount',
     *         per-characteristic 'results' map, and 'latestETag'
     */
    public static String patchConfigurationCharacteristics(String configId, String etag, String patchOperations) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        validateRequired(patchOperations, 'Patch operations cannot be blank');

        List<Object> operations = (List<Object>) JSON.deserializeUntyped(patchOperations);
        Map<String, Object> results = new Map<String, Object>();
        Integer successCount = 0;
        Integer totalCount = operations.size();
        String latestETag = null;
        String currentETag = etag;

        for (Object operation : operations) {
            Map<String, Object> operationMap = (Map<String, Object>) operation;
            String characteristicId = String.valueOf(operationMap.get('characteristicId'));
            Integer itemId = Integer.valueOf(String.valueOf(operationMap.get('itemId')));
            String inputBody = JSON.serialize(operationMap.get('input'));

            String operationPath = buildCharacteristicPath(configId, itemId, characteristicId);
            HttpResponse response = sendRequest('PATCH', operationPath, inputBody, buildIfMatchHeader(currentETag));

            // If ETag was stale, refresh from GET and retry this operation once.
            if (response.getStatusCode() == 412) {
                String refreshedETag = extractExpectedWeakETagFromError(response.getBody());
                if (String.isBlank(refreshedETag)) {
                    refreshedETag = extractETagFromConfig(getConfigurationV2(configId));
                }
                if (!String.isBlank(refreshedETag) && refreshedETag != currentETag) {
                    currentETag = refreshedETag;
                    response = sendRequest('PATCH', operationPath, inputBody, buildIfMatchHeader(currentETag));
                }
            }

            if (isSuccess(response.getStatusCode())) {
                successCount++;
                String operationETag = response.getHeader('ETag');
                if (String.isBlank(operationETag)) {
                    // Many SAP characteristic PATCH responses omit ETag header; refresh via GET.
                    operationETag = extractETagFromConfig(getConfigurationV2(configId));
                }
                if (String.isBlank(operationETag)) {
                    // Last-resort heuristic: SAP appears to increment weak ETags monotonically per successful PATCH.
                    operationETag = incrementWeakETag(currentETag);
                }
                if (!String.isBlank(operationETag)) {
                    latestETag = operationETag;
                    currentETag = operationETag;
                }
                results.put(characteristicId, buildSuccessResult(response.getStatusCode(), operationETag));
            } else {
                results.put(characteristicId, buildErrorResult(response.getStatusCode(), response.getBody()));
            }
        }

        if (successCount > 0 && String.isBlank(latestETag)) {
            latestETag = extractETagFromConfig(getConfigurationV2(configId));
        }

        Map<String, Object> summary = new Map<String, Object>{
            'success' => successCount == totalCount,
            'successCount' => successCount,
            'totalCount' => totalCount,
            'results' => results
        };

        if (!String.isBlank(latestETag)) {
            summary.put('latestETag', latestETag);
        }

        return JSON.serialize(summary);
    }

    /**
     * @description Marks a configuration session as complete, triggering SAP VC validation.
     * Calls POST /api/v2/configurations/{configId}/complete.
     * @param configId Unique configuration session ID
     * @return JSON response with completion status and any validation messages
     */
    public static String completeConfigurationV2(String configId) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        return callApi('POST', '/api/v2/configurations/' + encode(configId) + '/complete', null, null, false);
    }

    /**
     * @description Deletes a configuration session from SAP VC.
     * Calls DELETE /api/v2/configurations/{configId}.
     * @param configId Unique configuration session ID
     * @return Empty body on success (HTTP 204)
     */
    public static String deleteConfigurationV2(String configId) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        return callApi('DELETE', '/api/v2/configurations/' + encode(configId), null, null, false);
    }

    /**
     * @description Locks or unlocks a configuration session to prevent concurrent modifications.
     * Calls PATCH /api/v2/configurations/{configId}/lock.
     * @param configId Unique configuration session ID
     * @param lockBody JSON object with 'locked' boolean, e.g. {"locked":true}
     * @return JSON response with updated lock state
     */
    public static String lockConfigurationV2(String configId, String lockBody) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        return callApi('PATCH', '/api/v2/configurations/' + encode(configId) + '/lock', lockBody, null, false);
    }

    /**
     * @description Resets a configuration session to its initial default values.
     * Calls POST /api/v2/configurations/{configId}/reset.
     * @param configId Unique configuration session ID
     * @return JSON response with reset configuration state
     */
    public static String resetConfigurationV2(String configId) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        return callApi('POST', '/api/v2/configurations/' + encode(configId) + '/reset', null, null, false);
    }

    /**
     * @description Applies a JSON Patch update to a specific item within a configuration session.
     * Calls PATCH /api/v2/configurations/{configId}/items/{itemId}.
     * @param configId      Unique configuration session ID
     * @param itemId        Item identifier within the configuration
     * @param itemPatchData JSON Patch array (RFC 6902) with operations for the item
     * @return JSON response with updated item state
     */
    public static String patchConfigurationItemV2(String configId, String itemId, String itemPatchData) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        validateRequired(itemId, 'Item ID cannot be blank');
        return callApi(
            'PATCH',
            '/api/v2/configurations/' + encode(configId) + '/items/' + encode(itemId),
            itemPatchData,
            null,
            false
        );
    }

    /**
     * @description Retrieves the characteristics for a specific item in a configuration session.
     * Calls GET /api/v2/configurations/{configId}/items/{itemId}/characteristics
     * with an optional OData $filter expression.
     * @param configId Unique configuration session ID
     * @param itemId   Item identifier within the configuration
     * @param filter   OData $filter expression to narrow results (optional)
     * @return JSON array of characteristic objects for the item
     */
    public static String getItemCharacteristicsV2(String configId, String itemId, String filter) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        validateRequired(itemId, 'Item ID cannot be blank');

        String path = '/api/v2/configurations/' + encode(configId) + '/items/' + encode(itemId) + '/characteristics';
        if (!String.isBlank(filter)) {
            path += '?$filter=' + encode(filter);
        }

        return callApi('GET', path, null, null, false);
    }

    /**
     * @description Lists all available external configuration headers stored in SAP VC.
     * Calls GET /api/v2/externalConfigurations.
     * @return JSON array of external configuration header objects
     */
    public static String getExternalConfigurationsV2() {
        return callApi('GET', '/api/v2/externalConfigurations', null, null, false);
    }

    /**
     * @description Creates or copies an external configuration in SAP VC.
     * Calls POST /api/v2/externalConfigurations with optional query parameters.
     * @param body                  JSON request body for the external configuration
     * @param sourceConfigurationId ID of an existing configuration to copy from (optional)
     * @param selectValue           OData $select expression to limit response fields (optional)
     * @return JSON response with the created external configuration
     */
    public static String loadExternalConfigurationV2(String body, String sourceConfigurationId, String selectValue) {
        List<String> params = new List<String>();
        if (!String.isBlank(sourceConfigurationId)) {
            params.add('sourceConfigurationID=' + encode(sourceConfigurationId));
        }
        if (!String.isBlank(selectValue)) {
            params.add('$select=' + encode(selectValue));
        }

        String path = '/api/v2/externalConfigurations';
        if (!params.isEmpty()) {
            path += '?' + String.join(params, '&');
        }

        return callApi('POST', path, body, null, false);
    }

    /**
     * @description Retrieves a single external configuration by its unique identifier.
     * Calls GET /api/v2/externalConfigurations/{configId}.
     * @param configId Unique external configuration ID
     * @return JSON object with external configuration details
     */
    public static String getExternalConfigurationByIdV2(String configId) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        return callApi('GET', '/api/v2/externalConfigurations/' + encode(configId), null, null, false);
    }

    /**
     * @description Retrieves the display representation of an external configuration.
     * Calls GET /api/v2/externalConfigurations/{configId}/display.
     * Useful for rendering a read-only summary of the saved configuration.
     * @param configId Unique external configuration ID
     * @return JSON object with display-ready configuration data
     */
    public static String getExternalConfigurationDisplayByIdV2(String configId) {
        validateRequired(configId, 'Configuration ID cannot be blank');
        return callApi('GET', '/api/v2/externalConfigurations/' + encode(configId) + '/display', null, null, false);
    }

    /**
     * @description Retrieves runtime metrics for a knowledge base (size, class counts, etc.).
     * Calls GET /api/v2/knowledgebases/{kbId}/metrics.
     * @param kbId Unique knowledge base ID
     * @return JSON object with knowledge base metrics
     */
    public static String getKnowledgebaseMetrics(String kbId) {
        validateRequired(kbId, 'Knowledge base ID cannot be blank');
        return callApi('GET', '/api/v2/knowledgebases/' + encode(kbId) + '/metrics', null, null, false);
    }

    /**
     * @description Retrieves a specific dependency net from a knowledge base.
     * Calls GET /api/v2/knowledgebases/{kbId}/dependencies/{dependencyId}.
     * @param kbId         Unique knowledge base ID
     * @param dependencyId Unique dependency net ID within the knowledge base
     * @return JSON object with the dependency net details
     */
    public static String getKnowledgebaseDependencyById(String kbId, String dependencyId) {
        validateRequired(kbId, 'Knowledge base ID cannot be blank');
        validateRequired(dependencyId, 'Dependency ID cannot be blank');
        return callApi(
            'GET',
            '/api/v2/knowledgebases/' + encode(kbId) + '/dependencies/' + encode(dependencyId),
            null,
            null,
            false
        );
    }

    /**
     * @description Retrieves the rows of a variant table stored in a knowledge base.
     * Calls GET /api/v2/knowledgebases/{kbId}/variantTables/{variantTableId}
     * with optional language, pagination, and skip parameters.
     * @param kbId           Unique knowledge base ID
     * @param variantTableId Unique variant table ID within the knowledge base
     * @param language       BCP-47 language code for translated values (optional)
     * @param top            Maximum number of rows to return, OData $top (optional)
     * @param skip           Number of rows to skip for pagination, OData $skip (optional)
     * @return JSON object with variant table rows
     */
    public static String getKnowledgebaseVariantTableById(
        String kbId,
        String variantTableId,
        String language,
        String top,
        String skip
    ) {
        validateRequired(kbId, 'Knowledge base ID cannot be blank');
        validateRequired(variantTableId, 'Variant table ID cannot be blank');

        List<String> params = new List<String>();
        if (!String.isBlank(language)) {
            params.add('language=' + encode(language));
        }
        if (!String.isBlank(top)) {
            params.add('$top=' + encode(top));
        }
        if (!String.isBlank(skip)) {
            params.add('$skip=' + encode(skip));
        }

        String path = '/api/v2/knowledgebases/' + encode(kbId) + '/variantTables/' + encode(variantTableId);
        if (!params.isEmpty()) {
            path += '?' + String.join(params, '&');
        }

        return callApi('GET', path, null, null, false);
    }

    // ─── Private helpers ─────────────────────────────────────────────────────

    /**
     * @description Executes an HTTP callout to the SAP VC Product Configuration API and returns
     * the response body. Optionally injects the ETag from the response header into
     * the JSON body under the key '_eTag' so callers can use it for optimistic concurrency.
     * Throws a CalloutException if the HTTP status code is not 2xx.
     * @param method            HTTP method (GET, POST, PATCH, DELETE)
     * @param path              Relative path appended to the named credential base URL
     * @param body              Request body JSON string (null for GET / DELETE)
     * @param headers           Additional request headers, e.g. If-Match (null if none)
     * @param includeETagInBody When true the ETag is merged into the returned JSON body as '_eTag'
     * @return Response body string, optionally enriched with '_eTag'
     */
    private static String callApi(
        String method,
        String path,
        String body,
        Map<String, String> headers,
        Boolean includeETagInBody
    ) {
        HttpResponse response = sendRequest(method, path, body, headers);

        if (!isSuccess(response.getStatusCode())) {
            throw buildCalloutException(response, 'SAP VC Product Configuration API Error');
        }

        if (includeETagInBody == true) {
            return withETagInBody(response.getBody(), response.getHeader('ETag'));
        }

        return response.getBody();
    }

    /**
     * @description Builds and sends an HttpRequest to the SAP VC Product Configuration named credential.
     * Does not evaluate the response status — callers are responsible for status handling.
     * @param method  HTTP method
     * @param path    Relative path appended to the named credential base URL
     * @param body    Request body JSON string (null for bodyless requests)
     * @param headers Additional headers to set on the request (null if none)
     * @return Raw HttpResponse from SAP VC
     */
    private static HttpResponse sendRequest(String method, String path, String body, Map<String, String> headers) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(NAMED_CREDENTIAL + path);
        request.setMethod(method);
        request.setHeader('Content-Type', CONTENT_TYPE_JSON);
        request.setTimeout(TIMEOUT_MS);

        if (headers != null && !headers.isEmpty()) {
            for (String headerName : headers.keySet()) {
                request.setHeader(headerName, headers.get(headerName));
            }
        }

        if (body != null) {
            request.setBody(body);
        }

        return new Http().send(request);
    }

    /**
     * @description Merges the ETag into the top-level JSON body under the key '_eTag'.
     * If the ETag is not in the response header, tries to discover it inside the body
     * (fields 'eTag', 'ETag', or 'etag'). Falls back to a wrapper object if the body
     * is not a valid JSON object.
     * @param body JSON string returned by SAP VC
     * @param etag ETag value from the HTTP response header (may be null)
     * @return JSON string with '_eTag' key added at the root level
     */
    private static String withETagInBody(String body, String etag) {
        try {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
            String resolvedETag = String.isBlank(etag) ? findETagInBody(payload) : etag;
            payload.put('_eTag', resolvedETag);
            return JSON.serialize(payload);
        } catch (Exception ex) {
            Map<String, Object> wrapper = new Map<String, Object>{
                '_eTag' => etag,
                '_body' => body
            };
            return JSON.serialize(wrapper);
        }
    }

    /**
     * @description Searches a deserialized JSON map for common ETag field names
     * ('eTag', 'ETag', 'etag') and returns the first match.
     * @param payload Deserialized JSON map of the response body
     * @return ETag string if found, otherwise null
     */
    private static String findETagInBody(Map<String, Object> payload) {
        if (payload == null) {
            return null;
        }

        if (payload.containsKey('eTag')) {
            return String.valueOf(payload.get('eTag'));
        }
        if (payload.containsKey('ETag')) {
            return String.valueOf(payload.get('ETag'));
        }
        if (payload.containsKey('etag')) {
            return String.valueOf(payload.get('etag'));
        }
        return null;
    }

    /**
     * @description Extracts the '_eTag' field injected by {@link #withETagInBody} from
     * a previously fetched configuration JSON string. Used as a fallback in
     * {@link #patchConfigurationCharacteristics} when individual PATCH responses do not
     * return an ETag header.
     * @param configResponseWithETag JSON string previously enriched with '_eTag'
     * @return ETag string if present in the JSON, otherwise null
     */
    private static String extractETagFromConfig(String configResponseWithETag) {
        try {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(configResponseWithETag);
            if (payload.containsKey('_eTag')) {
                return String.valueOf(payload.get('_eTag'));
            }
        } catch (Exception ex) {
            return null;
        }
        return null;
    }

    /**
     * @description Constructs the GET /api/v2/kbdetermination path with all applicable
     * query parameters from the provided filter values.
     * @param productId    SAP product ID (optional)
     * @param validityDate ISO date string for validity filter (optional)
     * @param type         Knowledge base type filter (optional)
     * @param plant        Plant filter (optional)
     * @return Relative URL path with encoded query string
     */
    private static String buildKbDeterminationPath(String productId, String validityDate, String type, String plant) {
        List<String> params = new List<String>();

        if (!String.isBlank(productId)) {
            params.add('productid=' + encode(productId));
        }
        if (!String.isBlank(validityDate)) {
            params.add('date=' + encode(validityDate));
        }

        List<String> filterParts = new List<String>();
        if (!String.isBlank(type)) {
            filterParts.add('type EQ \'' + type + '\'');
        }
        if (!String.isBlank(plant)) {
            filterParts.add('plant EQ \'' + plant + '\'');
        }
        if (!filterParts.isEmpty()) {
            params.add('$filter=' + encode(String.join(filterParts, ' AND ')));
        }

        String path = '/api/v2/kbdetermination';
        if (!params.isEmpty()) {
            path += '?' + String.join(params, '&');
        }

        return path;
    }

    /**
     * @description Constructs the PATCH path for a single item characteristic.
     * Pattern: /api/v2/configurations/{configId}/items/{itemId}/characteristics/{characteristicId}.
     * @param configId         Unique configuration session ID
     * @param itemId           Numeric item identifier
     * @param characteristicId Characteristic identifier within the item
     * @return Fully encoded relative path for the characteristic endpoint
     */
    private static String buildCharacteristicPath(String configId, Integer itemId, String characteristicId) {
        return '/api/v2/configurations/' + encode(configId) +
            '/items/' + String.valueOf(itemId) +
            '/characteristics/' + encode(characteristicId);
    }

    /**
     * @description Creates a headers map containing the 'If-Match' header for optimistic concurrency.
     * Returns null if the provided ETag is blank, which signals callers to omit the header.
     * @param etag Current ETag value (may be null or blank)
     * @return Map with 'If-Match' entry, or null if etag is blank
     */
    private static Map<String, String> buildIfMatchHeader(String etag) {
        if (String.isBlank(etag)) {
            return null;
        }
        return new Map<String, String>{
            'If-Match' => etag
        };
    }

    /**
     * @description Extracts the expected weak ETag from a 412 SAP VC error body such as
     *              "Passed If-Match header parameter value 5 did not match expected value 6".
     * @param errorBody Raw SAP VC error body
     * @return Weak ETag in the form W/"6", or null if not found
     */
    private static String extractExpectedWeakETagFromError(String errorBody) {
        if (String.isBlank(errorBody)) {
            return null;
        }

        String marker = 'expected value ';
        Integer markerIndex = errorBody.indexOf(marker);
        if (markerIndex < 0) {
            return null;
        }

        Integer startIndex = markerIndex + marker.length();
        String digits = '';
        while (startIndex < errorBody.length()) {
            String ch = errorBody.substring(startIndex, startIndex + 1);
            if (ch < '0' || ch > '9') {
                break;
            }
            digits += ch;
            startIndex++;
        }

        if (!String.isBlank(digits)) {
            return 'W/"' + digits + '"';
        }
        return null;
    }

    /**
     * @description Increments a weak ETag of the form W/"n".
     * @param etag Weak ETag string
     * @return Incremented weak ETag, or null if format does not match
     */
    private static String incrementWeakETag(String etag) {
        if (String.isBlank(etag)) {
            return null;
        }

        if (!etag.startsWith('W/"') || !etag.endsWith('"')) {
            return null;
        }

        String digits = etag.substring(3, etag.length() - 1);
        if (String.isBlank(digits)) {
            return null;
        }

        Integer currentValue;
        try {
            currentValue = Integer.valueOf(digits);
        } catch (Exception ex) {
            return null;
        }

        return 'W/"' + String.valueOf(currentValue + 1) + '"';
    }

    /**
     * @description Builds a success result map for a single characteristic PATCH operation.
     * @param statusCode     HTTP status code from the individual PATCH response
     * @param operationETag  ETag returned in the PATCH response header (may be null)
     * @return Map with 'status', 'statusCode', and 'eTag' entries
     */
    private static Map<String, Object> buildSuccessResult(Integer statusCode, String operationETag) {
        return new Map<String, Object>{
            'status' => 'success',
            'statusCode' => statusCode,
            'eTag' => operationETag
        };
    }

    /**
     * @description Builds an error result map for a failed characteristic PATCH operation.
     * @param statusCode  HTTP status code from the individual PATCH response
     * @param errorBody   Raw response body with the error detail from SAP VC
     * @return Map with 'status', 'statusCode', and 'error' entries
     */
    private static Map<String, Object> buildErrorResult(Integer statusCode, String errorBody) {
        return new Map<String, Object>{
            'status' => 'error',
            'statusCode' => statusCode,
            'error' => errorBody
        };
    }

    /**
     * @description Creates a CalloutException whose message is a JSON object containing the
     * HTTP status code and raw response body. Provides structured error information to callers.
     * @param response HTTP response with a non-2xx status
     * @param prefix   Human-readable prefix for the error message
     * @return CalloutException ready to be thrown
     */
    private static CalloutException buildCalloutException(HttpResponse response, String prefix) {
        String responseBody = response.getBody();
        String safeBody = responseBody == null ? 'No response body' : responseBody;
        String message = '{"error":true,"status":' + response.getStatusCode() +
            ',"message":"' + prefix + ' ' + response.getStatusCode() + ': ' + safeBody.escapeJava() + '"}';
        return new CalloutException(message);
    }

    /**
     * @description URL-encodes a string value using UTF-8. Used when building URL path
     * segments and query parameter values to ensure safe transmission.
     * @param value String to encode
     * @return URL-encoded string
     */
    private static String encode(String value) {
        return EncodingUtil.urlEncode(value, 'UTF-8');
    }

    /**
     * @description Returns true if the given HTTP status code falls in the 2xx success range.
     * @param statusCode HTTP response status code
     * @return true if 200 ≤ statusCode < 300, false otherwise
     */
    private static Boolean isSuccess(Integer statusCode) {
        return statusCode >= 200 && statusCode < 300;
    }

    /**
     * @description Asserts that a required string parameter is not blank.
     * Throws an IllegalArgumentException with the given message if the value is null or empty.
     * @param value   The value to check
     * @param message Exception message to use if the check fails
     */
    private static void validateRequired(String value, String message) {
        if (String.isBlank(value)) {
            throw new IllegalArgumentException(message);
        }
    }
}
