/**
 * VcpMonitoringQueries - Utility class for querying VCP logs via Nebula Logger
 * 
 * Usage in Apex:
 *   List<Log__c> recentErrors = VcpMonitoringQueries.getErrorsByTimeRange(1);
 *   List<Log__c> errorsByCorrelation = VcpMonitoringQueries.getErrorsByCorrelationId('VCP-...');
 *   Map<String, Integer> counts = VcpMonitoringQueries.getErrorCountsByCategory();
 */
public class VcpMonitoringQueries {
    
    public static List<Log__c> getErrorsByTimeRange(Integer daysBack) {
        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        
        return [
            SELECT Id, Timestamp__c, Message__c, Scenario__c, Exception_Message__c,
                   Exception_Stack_Trace__c, Context__c, UserName__c, User__c
            FROM Log__c
            WHERE Topic__c = 'Integration'
              AND Scenario__c = 'VCP_Configuration'
              AND Timestamp__c >= :cutoffDate
            ORDER BY Timestamp__c DESC
            LIMIT 10000
        ];
    }
    
    public static List<Log__c> getErrorsByCorrelationId(String correlationId) {
        if (String.isBlank(correlationId)) {
            return new List<Log__c>();
        }
        
        String searchTerm = '%' + correlationId + '%';
        
        return [
            SELECT Id, Timestamp__c, Message__c, Exception_Message__c, 
                   Exception_Stack_Trace__c, Context__c, UserName__c, User__c
            FROM Log__c
            WHERE Topic__c = 'Integration'
              AND Scenario__c = 'VCP_Configuration'
              AND Exception_Message__c LIKE :searchTerm
            ORDER BY Timestamp__c ASC
            LIMIT 10000
        ];
    }
    
    public static Map<String, Integer> getErrorCountsByCategory(Integer daysBack) {
        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        
        List<Log__c> logs = [
            SELECT Id, Exception_Message__c
            FROM Log__c
            WHERE Topic__c = 'Integration'
              AND Scenario__c = 'VCP_Configuration'
              AND Timestamp__c >= :cutoffDate
            LIMIT 10000
        ];
        
        Map<String, Integer> categoryCount = new Map<String, Integer> {
            'USER_VALIDATION' => 0,
            'USER_NOT_FOUND' => 0,
            'TECHNICAL_API' => 0,
            'TECHNICAL_INTEGRATION' => 0,
            'TECHNICAL_SYSTEM' => 0,
            'UNKNOWN' => 0
        };
        
        for (Log__c log : logs) {
            String category = extractCategoryFromMessage(log.Exception_Message__c);
            if (categoryCount.containsKey(category)) {
                categoryCount.put(category, categoryCount.get(category) + 1);
            } else {
                categoryCount.put(category, categoryCount.get('UNKNOWN') + 1);
            }
        }
        
        return categoryCount;
    }
    
    public static Map<String, Integer> getTopFailingOperations(Integer daysBack, Integer topN) {
        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        
        List<Log__c> logs = [
            SELECT Id, Exception_Message__c
            FROM Log__c
            WHERE Topic__c = 'Integration'
              AND Scenario__c = 'VCP_Configuration'
              AND Timestamp__c >= :cutoffDate
            LIMIT 10000
        ];
        
        Map<String, Integer> operationCount = new Map<String, Integer>();
        
        for (Log__c log : logs) {
            String operation = extractOperationFromMessage(log.Exception_Message__c);
            if (String.isNotBlank(operation)) {
                if (operationCount.containsKey(operation)) {
                    operationCount.put(operation, operationCount.get(operation) + 1);
                } else {
                    operationCount.put(operation, 1);
                }
            }
        }
        
        List<String> sortedOps = operationCount.keySet().asList();
        // Manual bubble sort (descending by count)
        for (Integer i = 0; i < sortedOps.size(); i++) {
            for (Integer j = i + 1; j < sortedOps.size(); j++) {
                if (operationCount.get(sortedOps.get(j)) > operationCount.get(sortedOps.get(i))) {
                    String temp = sortedOps.get(i);
                    sortedOps.set(i, sortedOps.get(j));
                    sortedOps.set(j, temp);
                }
            }
        }
        
        Map<String, Integer> topOps = new Map<String, Integer>();
        for (Integer i = 0; i < Math.min(Math.abs(topN), sortedOps.size()); i++) {
            topOps.put(sortedOps.get(i), operationCount.get(sortedOps.get(i)));
        }
        
        return topOps;
    }
    
    public static List<Log__c> getErrorsByUser(String userId, Integer daysBack) {
        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        
        return [
            SELECT Id, Timestamp__c, Message__c, Exception_Message__c,
                   UserName__c, User__c
            FROM Log__c
            WHERE Topic__c = 'Integration'
              AND Scenario__c = 'VCP_Configuration'
              AND User__c = :userId
              AND Timestamp__c >= :cutoffDate
            ORDER BY Timestamp__c DESC
            LIMIT 10000
        ];
    }
    
    public static List<Log__c> getTechnicalErrorsOnly(Integer daysBack) {
        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        
        List<Log__c> allErrors = [
            SELECT Id, Timestamp__c, Message__c, Exception_Message__c,
                   Exception_Stack_Trace__c, Context__c
            FROM Log__c
            WHERE Topic__c = 'Integration'
              AND Scenario__c = 'VCP_Configuration'
              AND Timestamp__c >= :cutoffDate
            ORDER BY Timestamp__c DESC
            LIMIT 10000
        ];
        
        List<Log__c> technicalErrors = new List<Log__c>();
        for (Log__c log : allErrors) {
            String category = extractCategoryFromMessage(log.Exception_Message__c);
            if (category.startsWith('TECHNICAL')) {
                technicalErrors.add(log);
            }
        }
        
        return technicalErrors;
    }
    
    public static Map<String, Integer> getErrorRateByOperation(Integer daysBack) {
        return getTopFailingOperations(daysBack, 100);
    }
    
    public static Map<String, Object> generateHealthReport(Integer daysBack) {
        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        
        Integer totalErrors = [
            SELECT COUNT() FROM Log__c
            WHERE Topic__c = 'Integration'
              AND Scenario__c = 'VCP_Configuration'
              AND Timestamp__c >= :cutoffDate
        ];
        
        Map<String, Integer> categoryBreakdown = getErrorCountsByCategory(daysBack);
        Map<String, Integer> topFailures = getTopFailingOperations(daysBack, 5);
        
        DateTime oneDay = DateTime.now().addDays(-1);
        Integer errorsLast24h = [
            SELECT COUNT() FROM Log__c
            WHERE Topic__c = 'Integration'
              AND Scenario__c = 'VCP_Configuration'
              AND Timestamp__c >= :oneDay
        ];
        
        return new Map<String, Object> {
            'reportDate' => DateTime.now(),
            'daysIncluded' => daysBack,
            'totalErrors' => totalErrors,
            'errorsLast24Hours' => errorsLast24h,
            'errorsByCategory' => categoryBreakdown,
            'topFailingOperations' => topFailures,
            'reportCutoff' => cutoffDate
        };
    }
    
    // PRIVATE PARSING HELPERS
    
    private static String extractCategoryFromMessage(String message) {
        if (String.isBlank(message)) {
            return 'UNKNOWN';
        }
        
        if (message.contains('USER_VALIDATION')) return 'USER_VALIDATION';
        if (message.contains('USER_NOT_FOUND')) return 'USER_NOT_FOUND';
        if (message.contains('TECHNICAL_API')) return 'TECHNICAL_API';
        if (message.contains('TECHNICAL_INTEGRATION')) return 'TECHNICAL_INTEGRATION';
        if (message.contains('TECHNICAL_SYSTEM')) return 'TECHNICAL_SYSTEM';
        
        return 'UNKNOWN';
    }
    
    private static String extractOperationFromMessage(String message) {
        if (String.isBlank(message)) {
            return null;
        }
        
        Integer opIdx = message.indexOf('Operation__c');
        if (opIdx == -1) {
            return null;
        }
        
        Integer colonIdx = message.indexOf(':', opIdx);
        if (colonIdx == -1) {
            return null;
        }
        
        Integer startIdx = colonIdx + 1;
        while (startIdx < message.length() && (message.charAt(startIdx) == ' ' || message.charAt(startIdx) == '"')) {
            startIdx++;
        }
        
        if (startIdx >= message.length()) {
            return null;
        }
        
        Integer endIdx = startIdx;
        while (endIdx < message.length() && message.charAt(endIdx) != ' ' && message.charAt(endIdx) != '"' && message.charAt(endIdx) != ',') {
            endIdx++;
        }
        
        return message.substring(startIdx, endIdx).trim();
    }
}
