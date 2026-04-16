# VCP Error Handling Integration Guide

## Current Status (Aligned with Code)

This guide reflects the implementation currently deployed in the VCP flow.

What is implemented now:
- Central error handling in `VcpErrorHandler.cls`
- User-friendly messages by category
- Correlation IDs (`VCP-YYYYMMDD-HHMMSS-XXXXXXXX`)
- Error propagation to LWC as `AuraHandledException` including `[Error ID: ...]`
- Nebula logging using the same direct API style already used in this repo (`Logger` class)

Important alignment note:
- Logging now uses `Logger` directly (same family as `FlowLogger`), not `nlogs.*` and not ad-hoc custom APIs.

---

## 1. Architecture in Practice

Request path:
1. LWC calls `VcpConfigManagerController`
2. Controller validates input and delegates business operation
3. On error, controller calls `VcpErrorHandler`
4. `VcpErrorHandler` categorizes + generates correlation ID + logs in Nebula
5. Controller throws `AuraHandledException` with user message + correlation ID
6. LWC shows friendly message and keeps correlation ID for support

This gives traceability without exposing technical details to end users.

---

## 2. Apex Logging Pattern (Nebula Direct)

The logging method inside `VcpErrorHandler` is intentionally minimal and robust.

```apex
private static void logErrorViaNebulaLogger(
    VcpError err,
    String operation,
    Object context,
    LoggingLevel level
) {
    try {
        Map<String, Object> details = new Map<String, Object> {
            'correlationId' => err.correlationId,
            'operation' => operation,
            'category' => String.valueOf(err.category),
            'httpStatus' => err.sapStatusCode,
            'sapEndpoint' => err.sapEndpoint,
            'userMessage' => err.userMessage,
            'technicalMessage' => err.technicalMessage,
            'stackTrace' => err.stackTrace,
            'occurredAt' => err.occurredAt,
            'userId' => UserInfo.getUserId(),
            'orgId' => UserInfo.getOrganizationId(),
            'userName' => UserInfo.getUserName(),
            'context' => context
        };

        Logger.setScenario('VCP_Configuration');
        String message = 'VCP Integration Error | ' + JSON.serialize(details);

        if (level == LoggingLevel.WARN) {
            Logger.warn(message).addTag('VCP').addTag('Integration');
        } else if (level == LoggingLevel.INFO) {
            Logger.info(message).addTag('VCP').addTag('Integration');
        } else {
            Logger.error(message).addTag('VCP').addTag('Integration');
        }

        Logger.saveLog();

    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'VCP ERROR LOGGING FAILED');
        System.debug(LoggingLevel.ERROR, 'Nebula Logger Exception: ' + e.getMessage());
    }
}
```

Why this is the chosen approach:
- Same usage style as existing Nebula classes in this codebase
- No namespace ambiguity
- No dependency on org-specific custom fields for basic logging
- Keeps correlation ID in every logged message for support traceability

---

## 3. Controller Contract

`VcpConfigManagerController` currently follows this contract:
- Validate required inputs early
- For validation issues, call `handleValidationError(...)`
- For unexpected errors, call `handleException(...)`
- Throw `AuraHandledException` with:
  - friendly user message
  - `[Error ID: <correlationId>]`

This guarantees the UI gets a support-friendly ID every time.

---

## 4. LWC Contract

`vcpConfigManager.js` currently:
- Extracts correlation ID from message
- Strips technical suffix from user-visible message
- Logs local activity with endpoint + timestamp + correlationId
- Shows user message and asks to share Error ID with support

This keeps UX clean and still gives support enough data to trace in Nebula.

---

## 5. Error Categories Used

- `USER_VALIDATION`
- `USER_NOT_FOUND`
- `TECHNICAL_API`
- `TECHNICAL_INTEGRATION`
- `TECHNICAL_SYSTEM`

Each category maps to a friendly message. Technical details remain in logs.

---

## 6. Correlation ID Format

Format:
- `VCP-YYYYMMDD-HHMMSS-XXXXXXXX`

Example:
- `VCP-20260416-145522-a1b2c3d4`

This ID is generated once per handled error and used across:
- Apex error object
- Nebula log entry message
- User-facing error message
- LWC activity log

---

## 7. Monitoring Reality (Current)

`VcpMonitoringQueries.cls` is currently in a compatibility-first version.

Meaning:
- It avoids assumptions about org-specific custom fields on `Log__c`
- It uses safer/standard-access patterns so deploys do not fail across orgs

If later you want rich dashboards (Topic/Scenario/custom fields), we can add that in a second pass once exact fields are confirmed in the target org.

---

## 8. What Support Team Should Do

When user reports an Error ID:
1. Copy `VCP-...` from UI
2. Search in Nebula logs by message text containing that ID
3. Read full JSON payload in message
4. Use `operation`, `category`, `sapEndpoint`, `httpStatus` to diagnose

Even with minimal field mapping, this is enough for end-to-end traceability.

---

## 9. Scope of This Version

This version optimizes for:
- Reliability of deploy
- Guaranteed traceability
- Alignment with current Nebula usage in this repository

This version does not try to enforce:
- full custom-field mapping on `Log__c`
- rich analytics queries tied to org-specific metadata

Those can be layered later without breaking the current error flow.
