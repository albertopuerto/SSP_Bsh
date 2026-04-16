/**
 * VcpErrorHandler - Central error handling & logging for VCP integration
 * Uses Nebula Logger for distributed tracing across CPQ to VCP to SAP
 * Features:
 * - Error categorization (user vs technical)
 * - Correlation ID generation for full trace
 * - User-friendly messages for CPQ
 * - Detailed technical logs via Nebula Logger
 */
public class VcpErrorHandler {
    
    public enum ErrorCategory {
        USER_VALIDATION,       // Invalid input, business rule violation
        USER_NOT_FOUND,        // Product/config not found
        TECHNICAL_API,         // SAP timeout, 5xx, unavailable
        TECHNICAL_INTEGRATION, // Malformed response, parsing error
        TECHNICAL_SYSTEM       // SF governor limits, callout limits
    }
    
    public class VcpError {
        public String correlationId { get; set; }
        public ErrorCategory category { get; set; }
        public String userMessage { get; set; }
        public String technicalMessage { get; set; }
        public String stackTrace { get; set; }
        public String sapEndpoint { get; set; }
        public Integer sapStatusCode { get; set; }
        public DateTime occurredAt { get; set; }
        
        public VcpError() {
            this.correlationId = generateCorrelationId();
            this.occurredAt = DateTime.now();
        }
    }
    
    // PUBLIC ERROR HANDLING METHODS
    
    public static VcpError handleException(
        Exception ex,
        String operation,
        String calloutEndpoint,
        Object context
    ) {
        VcpError err = new VcpError();
        ErrorCategory category = categorizeException(ex);
        
        err.category = category;
        err.technicalMessage = ex.getTypeName() + ': ' + ex.getMessage();
        err.stackTrace = ex.getStackTraceString();
        err.sapEndpoint = calloutEndpoint;
        err.userMessage = getUserFriendlyMessage(category, ex.getMessage());
        
        logErrorViaNebulaLogger(err, operation, context, LoggingLevel.ERROR);
        
        return err;
    }
    
    public static VcpError handleHttpResponse(
        HttpResponse response,
        String operation,
        String calloutEndpoint
    ) {
        if (isSuccess(response.getStatusCode())) {
            return null;
        }
        
        VcpError err = new VcpError();
        err.sapStatusCode = response.getStatusCode();
        err.sapEndpoint = calloutEndpoint;
        err.technicalMessage = 'HTTP ' + response.getStatusCode() + ': ' + response.getStatus();
        
        try {
            Map<String, Object> sapError = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            err.technicalMessage += ' | SAP Error: ' + JSON.serialize(sapError);
        } catch (Exception e) {
            String bodyPreview = response.getBody();
            if (bodyPreview.length() > 500) {
                bodyPreview = bodyPreview.substring(0, 500) + '...';
            }
            err.technicalMessage += ' | Response Body: ' + bodyPreview;
        }
        
        err.category = categorizeHttpStatus(response.getStatusCode());
        err.userMessage = getUserFriendlyMessage(err.category, err.technicalMessage);
        
        LoggingLevel level = (err.category == ErrorCategory.USER_VALIDATION || 
                              err.category == ErrorCategory.USER_NOT_FOUND)
            ? LoggingLevel.WARN
            : LoggingLevel.ERROR;
        
        logErrorViaNebulaLogger(err, operation, null, level);
        
        return err;
    }
    
    public static VcpError handleValidationError(String operation, String validationMessage, Object context) {
        VcpError err = new VcpError();
        err.category = ErrorCategory.USER_VALIDATION;
        err.technicalMessage = validationMessage;
        err.userMessage = getUserFriendlyMessage(ErrorCategory.USER_VALIDATION, validationMessage);
        
        logErrorViaNebulaLogger(err, operation, context, LoggingLevel.WARN);
        
        return err;
    }
    
    // PRIVATE CATEGORIZATION AND MESSAGING
    
    private static ErrorCategory categorizeException(Exception ex) {
        String exType = ex.getTypeName();
        
        if (exType.contains('CalloutException') || exType.contains('Timeout')) {
            return ErrorCategory.TECHNICAL_API;
        }
        
        if (exType.contains('JsonException') || exType.contains('TypeException')) {
            return ErrorCategory.TECHNICAL_INTEGRATION;
        }
        
        if (exType.contains('LimitException')) {
            return ErrorCategory.TECHNICAL_SYSTEM;
        }
        
        if (exType.contains('IllegalArgumentException') || exType.contains('Validation')) {
            return ErrorCategory.USER_VALIDATION;
        }
        
        return ErrorCategory.TECHNICAL_SYSTEM;
    }
    
    private static ErrorCategory categorizeHttpStatus(Integer statusCode) {
        if (statusCode >= 200 && statusCode < 300) {
            return null;
        }
        
        if (statusCode >= 400 && statusCode < 500) {
            if (statusCode == 404) {
                return ErrorCategory.USER_NOT_FOUND;
            }
            return ErrorCategory.USER_VALIDATION;
        }
        
        if (statusCode >= 500 && statusCode < 600) {
            return ErrorCategory.TECHNICAL_API;
        }
        
        return ErrorCategory.TECHNICAL_API;
    }
    
    private static String getUserFriendlyMessage(ErrorCategory category, String technicalDetail) {
        if (category == ErrorCategory.USER_VALIDATION) {
            return 'Invalid product configuration. Please verify your selections and try again.';
        } else if (category == ErrorCategory.USER_NOT_FOUND) {
            return 'The requested product or configuration is no longer available. Please contact your sales representative.';
        } else if (category == ErrorCategory.TECHNICAL_API) {
            return 'The pricing service is temporarily unavailable. Please try again in a few moments.';
        } else if (category == ErrorCategory.TECHNICAL_INTEGRATION) {
            return 'The pricing service encountered an unexpected issue. Our team has been notified and will investigate.';
        } else if (category == ErrorCategory.TECHNICAL_SYSTEM) {
            return 'The configuration system is currently experiencing issues. Please try again later or contact your administrator.';
        } else {
            return 'An unexpected error occurred. Please contact your support team.';
        }
    }
    
    // NEBULA LOGGER INTEGRATION
    
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

            // Align with existing Nebula usage in this repo (e.g. FlowLogger): direct Logger API.
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
            System.debug(LoggingLevel.ERROR, 'Original Error - Correlation ID: ' + err.correlationId);
            System.debug(LoggingLevel.ERROR, 'Original Error - Technical Detail: ' + err.technicalMessage);
        }
    }
    
    // CORRELATION ID GENERATION
    
    private static String generateCorrelationId() {
        DateTime now = DateTime.now();
        return 'VCP-' 
            + now.format('yyyyMMdd-HHmmss')
            + '-' 
            + generateRandomSuffix(8);
    }
    
    private static String generateRandomSuffix(Integer length) {
        String seed = String.valueOf(DateTime.now().getTime()) + '-' + String.valueOf(Crypto.getRandomLong());
        Blob digest = Crypto.generateDigest('SHA-256', Blob.valueOf(seed));
        String hex = EncodingUtil.convertToHex(digest).toLowerCase();
        Integer safeLen = Math.max(1, Math.min(length, hex.length()));
        return hex.substring(0, safeLen);
    }
    
    // UTILITY METHODS
    
    private static Boolean isSuccess(Integer statusCode) {
        return statusCode >= 200 && statusCode < 300;
    }
    
    public static String extractCorrelationIdFromMessage(String message) {
        if (String.isBlank(message)) {
            return null;
        }
        
        Integer startIdx = message.indexOf('[VCP-');
        if (startIdx == -1) {
            return null;
        }
        
        Integer endIdx = message.indexOf(']', startIdx);
        if (endIdx == -1) {
            return null;
        }
        
        return message.substring(startIdx + 1, endIdx);
    }
}
