/**
 * @description Domain class for Quote (SBQQ__Quote__c) - handles quote locking logic
 * @author TLQ1KOR
 * @date 2025
 */
public class QuoteLock extends fflib_SObjectDomain {
    
    /**
     * Domain class constructor
     */
    public QuoteLock(List<SBQQ__Quote__c> records) {
        super(records);
    }
    
    /**
     * Domain class factory method - Required for fflib
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new QuoteLock(sObjectList);
        }
    }
    
    /**
     * @return List of Quote records cast to proper type
     */
    public List<SBQQ__Quote__c> getQuotes() {
        return (List<SBQQ__Quote__c>) getRecords();
    }
    
    /**
     * fflib trigger event - called before records are updated
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        try {
            Logger.debug('QuoteLock.onBeforeUpdate started for ' + getQuotes().size() + ' quote(s)');
            
            Set<String> exemptFields = getExemptFields();
            Logger.debug('Total exempt fields loaded: ' + exemptFields.size());
            
            for (SBQQ__Quote__c newQuote : getQuotes()) {
                SBQQ__Quote__c oldQuote = (SBQQ__Quote__c) existingRecords.get(newQuote.Id);
                
                if (isQuoteLocked(oldQuote)) {
                    Logger.debug('Processing locked quote: ' + newQuote.Id + ' with status: ' + newQuote.SBQQ__Status__c);
                    validateQuoteModifications(newQuote, oldQuote, exemptFields);
                } else {
                    Logger.debug('Quote modification allowed. QuoteId: ' + newQuote.Id + ', Status: ' + newQuote.SBQQ__Status__c);
                }
            }
            
            Logger.debug('QuoteLock.onBeforeUpdate completed successfully');
            
        } catch (Exception ex) {
            Logger.error('Error in QuoteLock.onBeforeUpdate', ex);
            throw ex;
        } finally {
            Logger.saveLog();
        }
    }
    
    /**
     * @description Determines if a quote should be locked from modifications
     */
    private Boolean isQuoteLocked(SBQQ__Quote__c quote) {
        return quote.SBQQ__Status__c == 'Rejected' || 
               quote.SBQQ__Status__c == 'Denied' || 
               quote.SBQQ__Status__c == 'Accepted';
    }
    
    /**
     * @description Validates that only exempt fields are being modified
     */
    private void validateQuoteModifications(SBQQ__Quote__c newQuote, SBQQ__Quote__c oldQuote, Set<String> exemptFields) {
        for (String fieldName : newQuote.getSObjectType().getDescribe().fields.getMap().keySet()) {
            if (!exemptFields.contains(fieldName) && newQuote.get(fieldName) != oldQuote.get(fieldName)) {
                Logger.debug('Quote modification blocked. QuoteId: ' + newQuote.Id + 
                           ', Status: ' + newQuote.SBQQ__Status__c + 
                           ', ModifiedField: ' + fieldName + 
                           ', OldValue: ' + String.valueOf(oldQuote.get(fieldName)) + 
                           ', NewValue: ' + String.valueOf(newQuote.get(fieldName)));
                
                newQuote.addError('The Quote cannot be modified because the status is Rejected, Accepted, or Denied.');
                break;
            }
        }
    }
    
    /**
     * @description Gets exempt fields from custom setting
     */
    private Set<String> getExemptFields() {
        Set<String> exemptFields = new Set<String>();
        
        Map<String, cs_BlockFieldExemption__c> exemptions = cs_BlockFieldExemption__c.getAll();
        Logger.debug('Loaded custom settings: ' + exemptions.size() + ' exemption records');
        
        for (cs_BlockFieldExemption__c exemption : exemptions.values()) {
            if (exemption.ObjectName__c == 'SBQQ__Quote__c') {
                exemptFields.add(exemption.FieldName__c);
                Logger.debug('Added exempt field: ' + exemption.FieldName__c + ' for quote object');
            }
        }
        
        return exemptFields;
    }
}