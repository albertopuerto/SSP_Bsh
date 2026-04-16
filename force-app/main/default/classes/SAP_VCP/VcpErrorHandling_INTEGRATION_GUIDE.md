# VCP Error Handling Integration Guide

## Overview

This guide explains how to integrate **`VcpErrorHandler`** into the VCP configuration system to provide:

- **User-friendly error messages** — Non-technical language for end users in the UI
- **Technical error distinction** — Separate handling for user errors vs. system failures
- **Correlation IDs** — Unique identifiers (e.g., `VCP-20260414-153045-a1b2c3d4`) that trace a single error across the entire stack
- **Centralized logging** — All errors logged to Nebula Logger for support investigation
- **E2E traceability** — Support teams can query by correlation ID to find root causes

### Key Components

| Component | Purpose |
|-----------|---------|
| **`VcpErrorHandler.cls`** | Central error handler — categorizes exceptions, generates correlation IDs, logs to Nebula Logger |
| **`VcpErrorHandlerTest.cls`** | 14 comprehensive tests covering all error scenarios |
| **`VcpMonitoringQueries.cls`** | SOQL query helpers to fetch and analyze errors from Nebula Logger |
| **Correlation ID** | Unique ID format: `VCP-20260414-153045-a1b2c3d4` = `VCP-{YYYYMMDD}-{HHMMSS}-{8-char-random}` |

### Error Categories

Errors are classified into one of 5 categories:

| Category | When It Occurs | Log Level | User Message |
|----------|---|---|---|
| **USER_VALIDATION** | User provides invalid input (missing field, bad format) | WARN | "Please check your input..." |
| **USER_NOT_FOUND** | SAP returns 404 (product doesn't exist) | WARN | "Product/config no longer available..." |
| **TECHNICAL_API** | Network/callout failure (timeout, refused, no internet) | ERROR | "Service temporarily unavailable..." |
| **TECHNICAL_INTEGRATION** | Response parsing fails (bad JSON, missing fields) | ERROR | "Integration error, please contact support..." |
| **TECHNICAL_SYSTEM** | Salesforce governor limit hit or system exception | ERROR | "System is experiencing issues..." |

---

## 1. Controller Integration (`VcpConfigManagerController`)

### Why This Pattern?

The controller is the **entry point** for all errors from LWC calls. By integrating `VcpErrorHandler` here, you ensure:

1. **All exceptions are caught** — No unhandled exceptions reach the UI as cryptic traces
2. **User-friendly messages** — Non-technical users never see stack traces or technical jargon
3. **Unique tracing** — Every error gets a correlation ID, making it traceable in logs
4. **Consistent logging** — All errors are automatically logged to Nebula Logger

### Implementation Pattern

Follow this pattern for each `@AuraEnabled` method:

```apex
@AuraEnabled(cacheable=false)
public static String createConfigurationV2(String configData) {
    // 1. Define operation and endpoint (for logging/tracing)
    String operation = 'POST /api/v2/configurations';
    String endpoint = 'callout:SAP_VC_Product_Configuration/api/v2/configurations';
    
    try {
        // 2. Validate input EARLY using VcpErrorHandler
        if (String.isBlank(configData)) {
            VcpErrorHandler.VcpError validationErr = VcpErrorHandler.handleValidationError(
                operation,
                'Configuration data is required',  // User-friendly message
                new Map<String, Object> {
                    'userId' => UserInfo.getUserId(),
                    'userName' => UserInfo.getUserName()
                }
            );
            // Return to user with correlation ID for support reference
            throw new AuraHandledException(
                validationErr.userMessage + '\n[Error ID: ' + validationErr.correlationId + ']'
            );
        }
        
        // 3. Validate JSON structure (catches malformed data)
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
        
        // 4. Call business logic (may throw Exception)
        String result = SAPVcProductConfigurationService.createConfigurationV2(configData);
        return result;
        
    } catch (AuraHandledException ex) {
        // Already handled with correlation ID — re-throw to LWC
        throw ex;
        
    } catch (Exception ex) {
        // 5. Catch unexpected errors (API timeouts, parse errors, system limits, etc)
        VcpErrorHandler.VcpError err = VcpErrorHandler.handleException(
            ex,                    // The exception object
            operation,             // What were we trying to do?
            endpoint,              // Which SAP endpoint?
            new Map<String, Object> {
                'configData' => configData,       // What data was sent?
                'userId' => UserInfo.getUserId(), // Who triggered it?
                'orgId' => UserInfo.getOrganizationId()
            }
        );
        
        // Return to user with user-friendly message + correlation ID
        throw new AuraHandledException(
            err.userMessage + '\n[Error ID: ' + err.correlationId + ']'
        );
    }
}
```

### What Happens Under the Hood?

When you call `VcpErrorHandler.handleException()`:

```
1. VcpErrorHandler analyzes the exception type:
   - CalloutException? → TECHNICAL_API
   - TypeException (JSON parsing)? → TECHNICAL_INTEGRATION
   - LimitException? → TECHNICAL_SYSTEM
   
2. Generates unique correlation ID:
   ID = "VCP-" + today's date + current time + 8 random hex chars
   Example: "VCP-20260414-153046-a1b2c3d4"
   
3. Creates user-friendly message (no technical terms):
   Internal stack trace → "Integration error, please contact support"
   
4. Logs to Nebula Logger with:
   - Correlation ID
   - Operation name
   - Error category
   - Full stack trace (for support)
   - Request context (userId, configData)
   - Timestamp
   
5. Returns VcpError object with:
   - userMessage (safe for user display)
   - technicalMessage (full details for logs)
   - correlationId (for tracing)
   - sapEndpoint (which service failed?)
```

### Second Method Example (`GET`)

```apex

```apex
@AuraEnabled(cacheable=false)
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
        
        String result = SAPVcProductConfigurationService.createConfigurationV2(configData);
        return result;
        
    } catch (AuraHandledException ex) {
        throw ex;
        
    } catch (Exception ex) {
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
        
        throw new AuraHandledException(
            err.userMessage + '\n[Error ID: ' + err.correlationId + ']'
        );
    }
}

@AuraEnabled(cacheable=false)
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
        
        // Call service
        return SAPVcProductConfigurationService.getConfigurationV2(configId);
        
    } catch (AuraHandledException ex) {
        throw ex;
        
    } catch (Exception ex) {
        VcpErrorHandler.VcpError err = VcpErrorHandler.handleException(
            ex, 
            operation, 
            endpoint,
            new Map<String, Object>{ 
                'configId' => configId, 
                'userId' => UserInfo.getUserId() 
            }
        );
        throw new AuraHandledException(
            err.userMessage + '\n[Error ID: ' + err.correlationId + ']'
        );
    }
}
```

---

## 2. LWC Integration (`vcpConfigManager.js`)

### Why This Pattern?

The LWC is the **user-facing layer**. When errors bubble up from the controller:

1. **Extract correlation ID** — From the error message (controller added it)
2. **Display user-friendly message** — Without technical jargon
3. **Show correlation ID to user** — "Share this with support to find your error"
4. **Log to activity log** — Record the error attempt for debugging
5. **Let user retry** — They have context about what failed

### Implementation

#### Step 1: Add correlation ID extraction method

```javascript
// Simple helper to extract the ID from "[VCP-20260414-153045-a1b2c3d4]"
extractCorrelationId(message) {
    const startIdx = message.indexOf('[VCP-');
    const endIdx = message.indexOf(']', startIdx);
    return startIdx !== -1 && endIdx !== -1 
        ? message.substring(startIdx + 1, endIdx) 
        : null;
}
```

This finds the correlation ID that the controller inserted into the error message. The ID is wrapped in `[VCP-...]` so it's easy to extract.

#### Step 2: Wrap API calls with error handling

```javascript
async handleCreateConfiguration() {
    this.isBusy = true;
    try {
        // Build request
        const createPayload = {
            kbId: this.kbId || '-3',
            productKey: this.productKey || this.effectiveProductCode,
            date: this.selectedDate || null,
            autoCleanup: this.autoCleanup
        };
        
        // Log the request (for debugging)
        this.logSapRequest('POST /api/v2/configurations', JSON.stringify(createPayload));
        
        // Call controller (may throw AuraHandledException with correlation ID)
        const rawCreate = await createConfigurationV2({ 
            configData: JSON.stringify(createPayload) 
        });
        
        // Log the success response
        this.logSapResponse('POST /api/v2/configurations', rawCreate);
        
        // Parse and extract configuration ID
        const parsedCreate = this.safeParseJson(rawCreate);
        const extractedConfigId = this.extractConfigId(parsedCreate);
        
        if (extractedConfigId) {
            this.storedConfigId = extractedConfigId;
            await this.persistConfigIdToQuote(extractedConfigId);
            await this.loadConfiguration(extractedConfigId, 'Create');
            this.showSuccess('Configuration created', `Configuration ${extractedConfigId} ready.`);
        }
        
    } catch (error) {
        // IMPORTANT: Handle the error gracefully
        
        // 1. Extract the error message from the exception
        const fullMessage = this.extractErrorMessage(error);  // "Product key required... [Error ID: VCP-...]"
        
        // 2. Extract correlation ID (if present)
        const correlationId = this.extractCorrelationId(fullMessage);
        // correlationId = "VCP-20260414-153045-a1b2c3d4" or null
        
        // 3. Extract just the user message (remove the "[Error ID: ...]" part)
        const userMessage = fullMessage.split('[Error ID:')[0].trim() || 'An error occurred';
        // userMessage = "Product key required"
        
        // 4. Log to activity log with correlation ID for support tracing
        this.logActivity('Create ERROR', userMessage, {
            bodyDetail: JSON.stringify({
                correlationId,
                timestamp: new Date().toISOString(),
                endpoint: 'POST /api/v2/configurations',
                userMessage
            })
        });
        
        // 5. Display error to user with correlation ID
        let displayMessage = userMessage;
        if (correlationId) {
            // Format: "Product key required
            //          Error ID: VCP-20260414-153045-a1b2c3d4
            //          Share this ID with support"
            displayMessage += `\n\nError ID: ${correlationId}\nShare this ID with support for faster resolution.`;
        }
        
        this.showError('Configuration Failed', displayMessage);
        
    } finally {
        this.isBusy = false;
    }
}
```

### What Happens From User's Perspective?

**Success Case:**
```
User clicks "Create Configuration"
    ↓
LWC calls controller's createConfigurationV2()
    ↓
Controller validates → calls SAP → returns config ID
    ↓
LWC displays: ✅ "Configuration created - ID: abc123"
```

**Error Case (User validates their input first):**
```
User clicks "Create Configuration" WITHOUT entering a Product Key
    ↓
LWC calls controller's createConfigurationV2({ productKey: "" })
    ↓
Controller's validation catches it:
  - Calls VcpErrorHandler.handleValidationError()
  - Gets back: userMessage = "Product key is required"
               correlationId = "VCP-20260414-153045-a1b2c3d4"
  - Throws AuraHandledException with both in the message
    ↓
LWC catches the exception in the catch block
  - Extracts correlationId: "VCP-20260414-153045-a1b2c3d4"
  - Extracts userMessage: "Product key is required"
  - Logs to activity log
    ↓
User sees:
  ❌ Configuration Failed
  Product key is required
  
  Error ID: VCP-20260414-153045-a1b2c3d4
  Share this ID with support for faster resolution.
```

**Error Case (SAP API times out):**
```
User fills all fields correctly and clicks "Create"
    ↓
Controller calls SAP API
    ↓
SAP API times out (CalloutException thrown)
    ↓
VcpErrorHandler.handleException() catches it:
  - Detects: CalloutException → TECHNICAL_API category
  - userMessage = "Pricing service temporarily unavailable..."
  - correlationId = "VCP-20260414-153046-b2c3d4e5"
  - Logs everything to Nebula Logger (full stack, request, etc)
    ↓
LWC catches and displays:
  ❌ Configuration Failed
  Pricing service temporarily unavailable...
  
  Error ID: VCP-20260414-153046-b2c3d4e5
  Share this ID with support for faster resolution.
    ↓
Support receives error ID from user → queries Nebula Logger
  → Finds exact error, root cause, stack trace
  → Can see: "SAP API didn't respond for 30 seconds"
  → Escalates to SAP team or increases timeout value
```

---

## 3. Understanding Error Categories & Flow

### Category 1: USER_VALIDATION

**When:** User provides bad input  
**Who detects it:** Your controller code (validation logic)  
**Example:** Missing required field, bad date format, invalid character

```
User enters: "" (empty product key)
           ↓
Controller: if (!payload.containsKey('productKey')) { handleValidationError(...) }
           ↓
Category: USER_VALIDATION
User sees: "Product key is required — please provide a value"
Log level: WARN (expected, not a system failure)
```

### Category 2: USER_NOT_FOUND

**When:** SAP returns HTTP 404 (resource doesn't exist)  
**Who detects it:** Your service code checking HTTP status  
**Example:** User requests config that was deleted, product no longer in KB

```
User: "Get config ABC123"
           ↓
SAP API: "404 Not Found — configuration ABC123 deleted"
           ↓
VcpErrorHandler.handleHttpResponse(response, ...) detects 404
           ↓
Category: USER_NOT_FOUND
User sees: "Configuration no longer available — it may have been deleted"
Log level: WARN (expected, user action caused it)
```

### Category 3: TECHNICAL_API

**When:** Network or callout fails  
**Who detects it:** Apex callout framework  
**Example:** Timeout, connection refused, DNS failure, SSL error

```
SAP server is down or slow
           ↓
Apex throws: new CalloutException("Connection timeout")
           ↓
VcpErrorHandler.handleException() detects: CalloutException
           ↓
Category: TECHNICAL_API
User sees: "Service temporarily unavailable — please try again later"
Log level: ERROR (system failure, not user fault)
Stack trace: SAVED in Nebula Logger (support can investigate)
```

### Category 4: TECHNICAL_INTEGRATION

**When:** Response parsing fails  
**Who detects it:** JSON deserialization  
**Example:** SAP returns invalid JSON, missing required fields, wrong data type

```
SAP returns: "} invalid json {"
           ↓
Apex: JSON.deserializeUntyped() throws TypeException
           ↓
VcpErrorHandler.handleException() detects: TypeException
           ↓
Category: TECHNICAL_INTEGRATION
User sees: "Integration issue — contact support with Error ID"
Log level: ERROR
Details logged: Exact response from SAP, parsing error, correlation ID
```

### Category 5: TECHNICAL_SYSTEM

**When:** Salesforce governor limits hit  
**Who detects it:** Apex runtime  
**Example:** Too many SOQL queries, DML statements, heap size exceeded

```
While processing: 1000 configurations in a loop
           ↓
Apex throws: LimitException("SOQL queries used up (100/100)")
           ↓
VcpErrorHandler.handleException() detects: LimitException
           ↓
Category: TECHNICAL_SYSTEM
User sees: "System is experiencing high load — please try again"
Log level: ERROR
Details: Which limit? How many used? Request context?
```

---

## 4. Real-World Error Scenarios

### Scenario 1: Invalid Product Key (USER_VALIDATION)

```
Timeline:
  1. User clicks "Create Configuration" without filling Product Key field
  2. LWC calls: createConfigurationV2({ productKey: "" })
  3. Controller receives request
  4. Validation: if (String.isBlank(payload.productKey)) → FAIL
  5. VcpErrorHandler.handleValidationError() called
     - Generates Correlation ID: VCP-20260414-153045-a1b2c3d4
     - Creates user message: "Product key is required"
     - Logs to Nebula Logger at WARN level
     - Returns VcpError object
  6. Controller throws AuraHandledException with message + ID
  7. LWC catches exception
  8. Extracts: correlationId = "VCP-20260414-153045-a1b2c3d4"
              userMessage = "Product key is required"
  9. Shows toast: "❌ Configuration Failed
                    Product key is required
                    Error ID: VCP-20260414-153045-a1b2c3d4"
 10. Logs to activity log with error type

User experience: Immediate, clear feedback. Can fix and retry.
Support experience: Not needed (expected user error).
```

### Scenario 2: SAP API Timeout (TECHNICAL_API)

```
Timeline:
  1. User fills all fields correctly and clicks "Create"
  2. LWC calls: createConfigurationV2({ productKey: "PROD123", ... })
  3. Controller validates input ✓
  4. Service calls SAP: POST /api/v2/configurations with payload
  5. SAP server doesn't respond within 60 seconds
  6. Apex throws: new CalloutException("Timeout after 60 sec")
  7. VcpErrorHandler.handleException(calloutException, ...) called
     - Detects: CalloutException → TECHNICAL_API
     - Generates: Correlation ID: VCP-20260414-153046-b2c3d4e5
     - User message: "Pricing service temporarily unavailable..."
     - Technical details: Full stack trace, request payload, SAP endpoint
     - Logs to Nebula Logger at ERROR level (system failure)
  8. Controller throws AuraHandledException with userMessage + ID
  9. LWC catches and shows: "❌ Configuration Failed
                             Pricing service temporarily unavailable...
                             Error ID: VCP-20260414-153046-b2c3d4e5
                             Share this ID with support"
 10. User contacts support: "Got error VCP-20260414-153046-b2c3d4e5"

Support workflow:
  1. Opens Nebula Logger UI
  2. Searches: Correlation_ID = "VCP-20260414-153046-b2c3d4e5"
  3. Finds log record with:
     - Exact error: "Timeout after 60 sec"
     - Stack trace: Which line in SAPVcProductConfigurationService?
     - Request: The configuration data that was sent
     - Timestamp: 2026-04-14 15:30:46
     - User: albertoPoC
  4. Root cause: SAP server was down for maintenance
  5. Resolution: Wait for SAP restart, or increase timeout in config
```

### Scenario 3: Product Not Found in SAP KB (USER_NOT_FOUND)

```
Timeline:
  1. User has old Product Code "ABC_OLD_12345"
  2. That product was deleted from SAP Knowledge Base last month
  3. User clicks "Get Configuration Details"
  4. LWC calls: getConfigurationV2(configId)
  5. Controller validates ID ✓
  6. Service calls SAP: GET /api/v2/knowledgebases/ABC_OLD_12345
  7. SAP returns: HTTP 404 "Knowledge Base entry not found"
  8. SAPVcProductConfigurationService.handleHttpResponse() detects:
     - Status: 404
     - Calls: VcpErrorHandler.handleHttpResponse(response, "GET ...", "callout:...")
  9. VcpErrorHandler detects: 404 → USER_NOT_FOUND
     - Generates: Correlation ID: VCP-20260414-153047-c3d4e5f6
     - User message: "Product configuration no longer available..."
     - Reason: "This product was removed from the pricing system"
     - Logs at WARN level (expected, user's data is old)
 10. Controller throws AuraHandledException with userMessage + ID
 11. LWC shows: "⚠️  Configuration Failed
                 Product configuration no longer available
                 Error ID: VCP-20260414-153047-c3d4e5f6"

User experience: Clear reason. Can contact support if needed.
Support experience: "Product was deleted — customer needs to use current product codes"
```

---

## 5. Monitoring: How Support Finds Errors

### Finding Errors by Correlation ID

```sql
-- Support paste the ID from user: VCP-20260414-153046-b2c3d4e5

SELECT 
    Id, Message__c, Timestamp__c, 
    Exception_Message__c,  -- Full error text
    Apex_Method__c,        -- Which class/method?
    Topic__c,              -- "Integration"
    Scenario__c            -- "VCP_Configuration"
FROM Log__c
WHERE Message__c LIKE '%VCP-20260414-153046-b2c3d4e5%'
ORDER BY Timestamp__c DESC
LIMIT 10;

Result: Complete error record with stack trace, request context, who triggered it
```

### Finding Errors in Last 24 Hours

```sql
SELECT 
    Log_Level__c,          -- ERROR, WARN, INFO
    Error_Category__c,     -- USER_VALIDATION, TECHNICAL_API, etc
    Timestamp__c,
    Message__c,
    CreatedById,           -- Which user?
    COUNT(),
    COUNT(DISTINCT Message__c)  -- How many unique errors?
FROM Log__c
WHERE Topic__c = 'Integration'
  AND Scenario__c = 'VCP_Configuration'
  AND Timestamp__c >= LAST_N_DAYS:1
GROUP BY Log_Level__c, Error_Category__c, Timestamp__c
ORDER BY Timestamp__c DESC;

Result: Summary report: "Yesterday we had 23 WARNS (user validation), 2 ERRORs (API timeout)"
```

### Finding Top Failing Operations

```sql
SELECT 
    Apex_Method__c,        -- Which endpoint failing most?
    Error_Category__c,
    COUNT() as ErrorCount
FROM Log__c
WHERE Topic__c = 'Integration'
  AND Scenario__c = 'VCP_Configuration'
  AND Log_Level__c = 'ERROR'
  AND Timestamp__c >= LAST_N_DAYS:7
GROUP BY Apex_Method__c, Error_Category__c
ORDER BY ErrorCount DESC
LIMIT 10;

Result: "GET /api/v2/configurations failing 45 times (TECHNICAL_API = timeouts)"
  → Action: Increase timeout, or check SAP performance
```

---

## 6. Testing & Validation

### Test Coverage (`VcpErrorHandlerTest.cls` — 14 tests)

The implementation includes comprehensive tests covering all error paths:

| Test | Scenario | Validates |
|------|----------|-----------|
| `testUserValidationError` | Missing required field | USER_VALIDATION category + user message |
| `testUserNotFoundError` | SAP returns 404 | USER_NOT_FOUND category + 404 handling |
| `testTechnicalAPIErrorTimeout` | CalloutException (timeout) | TECHNICAL_API + call to Nebula Logger |
| `testTechnicalIntegrationErrorParseError` | JSON parse fails (TypeException) | TECHNICAL_INTEGRATION category |
| `testTechnicalSystemErrorGovLimits` | LimitException thrown | TECHNICAL_SYSTEM category |
| `testHTTP500ErrorIsReturnedAsError` | SAP returns HTTP 500 | 500 → ERROR, not success |
| `testHTTP200SuccessReturnsNull` | Success response | No VcpError returned (null) |
| `testCorrelationIdFormat` | Correlation ID generation | Format `VCP-YYYYMMDD-HHMMSS-8chars` |
| `testCorrelationIdUniqueAcrossMultipleErrors` | Generate 10 IDs | All unique (random != deterministic) |
| `testExtractCorrelationIdFromMessage` | Parse ID from message | `[VCP-...]` extraction works |
| `testExtractCorrelationIdReturnsNullWhenNotFound` | No ID in message | Safely returns null |
| `testErrorOccurredAtTimestamp` | Timestamp accuracy | Logged time ≈ actual time |
| `testUserValidationErrorLogsViaNebulaLogger` | Full flow | Nebula Logger.log() called + saved |
| `testErrorHandlingWithJsonParseError` | Non-JSON response from SAP | Handles gracefully |
| `testValidationErrorMessageDoesntExposeTechnicalDetail` | Message sanitizing | No jargon in user message |

Each test uses `Test.startTest()` / `Test.stopTest()` to simulate Apex execution and verify Nebula Logger calls.

---

## 7. Integration Checklist

Before deploying `VcpErrorHandler`, complete this checklist:

### Apex Classes
- [ ] Add `VcpErrorHandler.cls` to `manifest/package-sap-vc-deploy.xml`
- [ ] Add `VcpErrorHandlerTest.cls` to manifest
- [ ] Add `VcpMonitoringQueries.cls` to manifest
- [ ] Run tests locally: `sf apex run test --class-names VcpErrorHandlerTest`
- [ ] All 14+ tests pass ✅

### Controllers
- [ ] Update `VcpConfigManagerController` with try/catch pattern shown above
- [ ] Replace bare `catch (Exception e)` with `VcpErrorHandler.handleException()`
- [ ] Add validation errors with `VcpErrorHandler.handleValidationError()`
- [ ] All methods throw `AuraHandledException` with `userMessage + '[Error ID: ' + correlationId + ']'`
- [ ] Test one method manually (create configuration with bad input → see error ID)

### LWC (`vcpConfigManager.js`)
- [ ] Add `extractCorrelationId(message)` helper method
- [ ] Update `handleCreateConfiguration()` catch block with pattern shown
- [ ] Extract and display correlation ID in error messages
- [ ] Log errors to activity log with correlationId
- [ ] Test: Trigger an error → verify error ID shows to user

### Nebula Logger Configuration
- [ ] Verify Nebula Logger plugin is installed: `sf plugins list | grep nebula`
- [ ] Verify `Log__c` object exists in org
- [ ] Verify Nebula Logger API: `nlogs.Logger`, `nlogs.LogMessage`
- [ ] Optionally, Create a Nebula Logger dashboard for VCP errors

### Deploy & Test
- [ ] Deploy to sandbox org first
- [ ] Run smoke tests: good and bad configurations
- [ ] Verify errors appear in Nebula Logger
- [ ] Query logs: `SELECT * FROM Log__c WHERE Topic__c = 'Integration' LIMIT 10`
- [ ] Deploy to production
- [ ] Set up support runbook (how to query logs by correlation ID)

---

## 8. Support Runbook

### User reports: "I got error VCP-20260414-153046-b2c3d4e5"

```
1. OPEN: Nebula Logger UI or use SOQL
   
2. QUERY:
   SELECT Id, Message__c, Exception_Message__c, Timestamp__c 
   FROM Log__c 
   WHERE Message__c LIKE '%VCP-20260414-153046-b2c3d4e5%'
   LIMIT 5

3. READ RESULTS:
   - Log Level: ERROR or WARN?
   - Category: USER_VALIDATION / TECHNICAL_API / etc?
   - Exception Message: Full stack trace
   - Timestamp: When did it happen?
   - Apex Method: Which code path?
   
4. DIAGNOSIS:
   
   IF Category = USER_VALIDATION:
     → User error, expected
     → Confirm: "You need to enter Product Key"
     → No further action needed
     
   IF Category = USER_NOT_FOUND:
     → Product doesn't exist in SAP
     → Check: "Product ABC_OLD was removed from SAP KB"
     → Ask user: "Use current product codes instead"
     
   IF Category = TECHNICAL_API:
     → Network/SAP failure
     → Check SAP health: Is SAP down/slow?
     → Check Salesforce logs: Any callout errors?
     → Escalate to SAP team or increase timeout
     
   IF Category = TECHNICAL_INTEGRATION:
     → Response parsing failed
     → Check Exception_Message: "Invalid JSON from SAP"
     → Escalate to SAP: Data format changed?
     
   IF Category = TECHNICAL_SYSTEM:
     → Governor limits hit
     → Check Exception_Message: Which limit?
     → Optimize code: Batch processing, bulkify, etc.

5. RESOLVE:
   - Fix root cause (increased timeout, fixed SAP, etc)
   - Ask user to retry
   - Confirm error gone: No new log for this user's next attempt
```

### SQL Cheat-Sheet for Support

```sql
-- Top 10 errors today by frequency
SELECT Error_Category__c, Message__c, COUNT() as count
FROM Log__c
WHERE Topic__c = 'Integration' 
  AND Scenario__c = 'VCP_Configuration'
  AND Timestamp__c >= TODAY
GROUP BY Error_Category__c, Message__c
ORDER BY count DESC
LIMIT 10

-- Errors from specific user
SELECT Timestamp__c, Message__c, Log_Level__c
FROM Log__c  
WHERE Topic__c = 'Integration'
  AND Scenario__c = 'VCP_Configuration'
  AND CreatedById = '[USER_ID]'
ORDER BY Timestamp__c DESC
LIMIT 20

-- Timeouts last 7 days
SELECT Timestamp__c, Message__c, Exception_Message__c
FROM Log__c
WHERE Topic__c = 'Integration'
  AND Exception_Message__c LIKE '%Timeout%'
  AND Timestamp__c >= LAST_N_DAYS:7
ORDER BY Timestamp__c DESC

-- Errors by hour (for troubleshooting patterns)
SELECT HOUR_IN_DAY(Timestamp__c) as hour, COUNT() as errors
FROM Log__c
WHERE Topic__c = 'Integration'
  AND Log_Level__c = 'ERROR'
  AND Timestamp__c >= LAST_N_DAYS:1
GROUP BY HOUR_IN_DAY(Timestamp__c)
ORDER BY hour
```

---

## 9. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         LWC (Browser)                               │
│                    vcpConfigManager.js                              │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ User Action: Click "Create Configuration"                   │  │
│  │ Calls: await createConfigurationV2({configData: JSON})      │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
                    (SOAP call over HTTPS)
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  Salesforce Org (Apex)                              │
│            VcpConfigManagerController                               │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ @AuraEnabled                                                 │  │
│  │ createConfigurationV2(String configData) {                   │  │
│  │   try {                                                      │  │
│  │     // 1. VALIDATE INPUT                                      │  │
│  │     if (blank) {                                              │  │
│  │       VcpErrorHandler.handleValidationError(...)             │  │
│  │       ↓                                                        │  │
│  │       Category: USER_VALIDATION                               │  │
│  │       Correlation ID: VCP-20260414-153045-a1b2c3d4            │  │
│  │       throw AuraHandledException with correlationId           │  │
│  │     }                                                          │  │
│  │                                                               │  │
│  │     // 2. CALL SERVICE                                        │  │
│  │     String result = SAPVcProductConfigurationService         │  │
│  │       .createConfigurationV2(configData)                      │  │
│  │       ↓                                                        │  │
│  │       (Makes HTTP POST to SAP)                                │  │
│  │                                                               │  │
│  │   } catch (AuraHandledException) {                            │  │
│  │     throw;  // Already has correlationId                      │  │
│  │   } catch (Exception ex) {                                    │  │
│  │     // 3. CATCH UNEXPECTED ERRORS (Timeout, Parse, etc)      │  │
│  │     VcpErrorHandler.handleException(ex, ...)                 │  │
│  │       ↓                                                        │  │
│  │       Detects: CalloutException, TypeException, etc           │  │
│  │       Category: TECHNICAL_API / TECHNICAL_INTEGRATION         │  │
│  │       Correlation ID: VCP-20260414-153046-b2c3d4e5            │  │
│  │       ↓                                                        │  │
│  │       LOGS TO NEBULA LOGGER:                                  │  │
│  │         - Full stack trace                                    │  │
│  │         - Request context (configData, userId)                │  │
│  │         - Correlation ID                                      │  │
│  │         - Timestamp                                           │  │
│  │       ↓                                                        │  │
│  │       throw AuraHandledException with userMessage + id        │  │
│  │   }                                                            │  │
│  │ }                                                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
                    (SOAP response to LWC)
       userMessage="Product key required" +
       correlationId="VCP-20260414-153045-a1b2c3d4"
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         LWC (Browser)                               │
│                    vcpConfigManager.js                              │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ catch (error) {                                              │  │
│  │   correlationId = extractCorrelationId(message)              │  │
│  │   userMessage = "Product key required"                       │  │
│  │   ↓                                                            │  │
│  │   LOG TO ACTIVITY LOG:                                        │  │
│  │   "Create ERROR"                                              │  │
│  │   { correlationId, timestamp, endpoint, userMessage }         │  │
│  │   ↓                                                            │  │
│  │   SHOW TO USER:                                               │  │
│  │   "❌ Configuration Failed                                    │  │
│  │    Product key required                                       │  │
│  │                                                               │  │
│  │    Error ID: VCP-20260414-153045-a1b2c3d4                    │  │
│  │    Share this ID with support"                                │  │
│  │ }                                                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
            User sees error with Correlation ID
            Contacts support: "My error ID is VCP-20260414-153045-..."
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      Nebula Logger (Salesforce)                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ Support Team opens Nebula Logger UI                          │  │
│  │ Searches: Correlation ID = VCP-20260414-153045-a1b2c3d4      │  │
│  │ ↓                                                              │  │
│  │ FINDS LOG RECORD:                                             │  │
│  │ - Exception Message: Full Apex stack trace                    │  │
│  │ - Request Context: configData, userId, orgId                 │  │
│  │ - Operation: POST /api/v2/configurations                      │  │
│  │ - Category: USER_VALIDATION                                   │  │
│  │ - Timestamp: 2026-04-14 15:30:45                              │  │
│  │ - Created By: albertoPoC                                      │  │
│  │ ↓                                                              │  │
│  │ DIAGNOSIS:                                                     │  │
│  │ "User didn't enter Product Key -- expected user error"        │  │
│  │ ↓                                                              │  │
│  │ RESOLUTION:                                                    │  │
│  │ Message to user: "Please enter a valid Product Key"           │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 10. FAQ

**Q: Why both `userMessage` and `technicalMessage`?**
- `userMessage`: Safe display in UI, non-technical ("Service temporarily unavailable")
- `technicalMessage`: Full details for logs ("HTTP timeout after 30 sec at line 45 of SAPVcProductConfigurationService")
- User never sees technical message. Support only sees it in Nebula Logger.

**Q: How do I know if an error is my fault or SAP's fault?**
- `TECHNICAL_API` (timeout) → Check if SAP is responding. If slow, SAP's fault.
- `TECHNICAL_INTEGRATION` (parse error) → SAP returned bad data. SAP's fault.
- `USER_VALIDATION` → User's fault. They didn't fill required field.
- `USER_NOT_FOUND` → User's data is old. User needs to use current product codes.
- `TECHNICAL_SYSTEM` → Your code is inefficient. Your fault. Optimize queryloop.

**Q: Do I need to manually call Nebula Logger?**
- No. `VcpErrorHandler` calls it automatically via `logErrorViaNebulaLogger()`.
- Just call `VcpErrorHandler.handleException()` and everything is logged.

**Q: Can I query Nebula Logger logs from my code?**
- Yes. Use `VcpMonitoringQueries.cls` methods or write SOQL directly.
- Query `Log__c` object with `WHERE Topic__c = 'Integration' AND Scenario__c = 'VCP_Configuration'`

**Q: What if SAP doesn't respond with HTTP status?**
- `VcpErrorHandler.handleHttpResponse()` checks `response.getStatusCode()`.
- If SAP returns no status → exception is thrown → caught as `TECHNICAL_INTEGRATION`.

**Q: How long are error logs retained?**
- Depends on your Nebula Logger configuration.
- Typically: 30 days free in scratch org, configurable in production.
- Check: Nebula Logger setup in your org.

---

## Summary: Three Simple Rules

1. **In your Controller:**
   - Wrap ALL business logic in try/catch
   - Call `VcpErrorHandler.handleException(ex, ...)` in the catch
   - Throw `AuraHandledException` with `userMessage + correlationId`

2. **In your LWC:**
   - Extract correlation ID from error message: `extractCorrelationId(message)`
   - Display it to the user: "Error ID: VCP-..."
   - User shares ID with support

3. **In Support:**
   - Receive error ID from user
   - Query Nebula Logger by ID
   - Get full context: exception, stack trace, request, timestamp, user
   - Fix root cause
