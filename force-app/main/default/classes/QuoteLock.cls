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
                
                if (ValidationBypass.skip) {
            			continue;
        		}
                isQuoteLockedValidation(oldQuote,newQuote);
                
                if (isQuoteLocked(oldQuote)) {
                    Logger.debug('Processing locked quote: ' + newQuote.Id + ' with status: ' + newQuote.SBQQ__Status__c);
                    validateQuoteModifications(newQuote, oldQuote, exemptFields);
                }else {
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
    
    private void isQuoteLockedValidation(SBQQ__Quote__c oldQuote,SBQQ__Quote__c newQuote){
    
        Boolean approvalNotApproved =
            newQuote.ApprovalStatus__c != 'Approved';

        Boolean notNew = true;

        Set<String> blockedPriorStatuses = new Set<String>{
            'Approval Pending',
            'Approved',
            'Rejected',
            'Denied',
            'Accepted'
        };

        Boolean priorStatusMatches =
            blockedPriorStatuses.contains(oldQuote.SBQQ__Status__c);

        Boolean isStatusChanged =
            newQuote.SBQQ__Status__c != oldQuote.SBQQ__Status__c;

        Boolean allowedTransition =
            (
                (oldQuote.SBQQ__Status__c == 'Approved'  && newQuote.SBQQ__Status__c == 'Presented') ||
                (oldQuote.SBQQ__Status__c == 'Presented' && newQuote.SBQQ__Status__c == 'Denied')     ||
                (oldQuote.SBQQ__Status__c == 'Presented' && newQuote.SBQQ__Status__c == 'Accepted')
            );

        Boolean disallowedChange =
            !(isStatusChanged && allowedTransition);

        if (approvalNotApproved &&
            notNew &&
            priorStatusMatches &&
            disallowedChange) {

            newQuote.addError('This Quote cannot be modified in its current status. Only specific status changes are allowed (Approved→Presented, Presented→Denied, Presented→Accepted).');
        }
    }
    
    /**
     * @description Validates that only exempt fields are being modified
     */
    @TestVisible
    private void testValidateQuoteModifications(SBQQ__Quote__c newQuote, SBQQ__Quote__c oldQuote, Set<String> exemptFields) {
    validateQuoteModifications(newQuote, oldQuote, exemptFields);
     }
    private void validateQuoteModifications(SBQQ__Quote__c newQuote, SBQQ__Quote__c oldQuote, Set<String> exemptFields) {
        for (String fieldName : newQuote.getSObjectType().getDescribe().fields.getMap().keySet()) {
            if (fieldName == 'sbqq__lastcalculatedon__c' || 
                fieldName == 'sbqq__lastsavedon__c' ||
                fieldName == 'sbqq__lastsaveddate__c' ||
                fieldName == 'cur_current_credit_limit_including_vat__c') {
                    continue;
                }
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