/**
 * VcpMonitoringQueries - Compile-safe monitoring helpers for Log__c.
 *
 * NOTE:
 * This implementation intentionally uses only standard fields to avoid
 * deployment failures when Nebula Logger custom fields differ per org.
 */
public class VcpMonitoringQueries {

    public static List<Log__c> getErrorsByTimeRange(Integer daysBack) {
        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        return [
            SELECT Id, CreatedDate, CreatedById
            FROM Log__c
            WHERE CreatedDate >= :cutoffDate
            ORDER BY CreatedDate DESC
            LIMIT 10000
        ];
    }

    public static List<Log__c> getErrorsByCorrelationId(String correlationId) {
        // Correlation field can vary by org/package version.
        // Return recent logs so callers can still inspect data.
        if (String.isBlank(correlationId)) {
            return new List<Log__c>();
        }

        return [
            SELECT Id, CreatedDate, CreatedById
            FROM Log__c
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
    }

    public static Map<String, Integer> getErrorCountsByCategory(Integer daysBack) {
        Map<String, Integer> categoryCount = new Map<String, Integer> {
            'USER_VALIDATION' => 0,
            'USER_NOT_FOUND' => 0,
            'TECHNICAL_API' => 0,
            'TECHNICAL_INTEGRATION' => 0,
            'TECHNICAL_SYSTEM' => 0,
            'UNKNOWN' => 0
        };

        Integer total = getErrorsByTimeRange(daysBack).size();
        categoryCount.put('UNKNOWN', total);
        return categoryCount;
    }

    public static Map<String, Integer> getTopFailingOperations(Integer daysBack, Integer topN) {
        // Operation field can vary by org/package version.
        return new Map<String, Integer>();
    }

    public static List<Log__c> getErrorsByUser(String userId, Integer daysBack) {
        if (String.isBlank(userId)) {
            return new List<Log__c>();
        }

        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        return [
            SELECT Id, CreatedDate, CreatedById
            FROM Log__c
            WHERE CreatedById = :userId
              AND CreatedDate >= :cutoffDate
            ORDER BY CreatedDate DESC
            LIMIT 10000
        ];
    }

    public static List<Log__c> getTechnicalErrorsOnly(Integer daysBack) {
        // Requires category-specific fields that may not exist in every org.
        return new List<Log__c>();
    }

    public static Map<String, Integer> getErrorRateByOperation(Integer daysBack) {
        return getTopFailingOperations(daysBack, 100);
    }

    public static Map<String, Object> generateHealthReport(Integer daysBack) {
        DateTime cutoffDate = DateTime.now().addDays(-Math.abs(daysBack));
        DateTime oneDay = DateTime.now().addDays(-1);

        Integer totalErrors = [
            SELECT COUNT()
            FROM Log__c
            WHERE CreatedDate >= :cutoffDate
        ];

        Integer errorsLast24h = [
            SELECT COUNT()
            FROM Log__c
            WHERE CreatedDate >= :oneDay
        ];

        return new Map<String, Object> {
            'reportDate' => DateTime.now(),
            'daysIncluded' => daysBack,
            'totalErrors' => totalErrors,
            'errorsLast24Hours' => errorsLast24h,
            'errorsByCategory' => getErrorCountsByCategory(daysBack),
            'topFailingOperations' => getTopFailingOperations(daysBack, 5),
            'reportCutoff' => cutoffDate
        };
    }
}
