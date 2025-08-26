// 1. Apex Scheduled Batch Job Class
global class AthenaAccountNotificationBatch implements Database.Batchable<sObject>, Schedulable {    
    
    // Batch start method - defines the query for accounts to process
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime fourteenDaysAgo = System.now().addDays(-14);
        String query = 'SELECT Id, Name, OwnerId, Owner.Email, Owner.Name, ' +
                      'pkl_Status__c, dtm_DatetimeofcreationinAthena__c ' +
                      'FROM Account ' +
                      'WHERE pkl_Status__c = \'Created in Athena\' ' +
                      'AND 	dtm_DatetimeofcreationinAthena__c <= :fourteenDaysAgo';
        
        return Database.getQueryLocator(query);
    }
    
    // Batch execute method - processes each chunk of records
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();        
        
        for (Account acc : scope) {
            if (acc.Owner != null && String.isNotBlank(acc.Owner.Email)) {
                
                String htmlBody = '<p>Dear ' + acc.Owner.Name + ',</p>' +
                                '<p><strong>Bosch Partner Number not received in 14 days for ' + acc.Name + 
                                '</strong>. Please contact application support by sending this information.</p>' +
                                '<p>Best regards,<br/>System Administrator</p>';
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{acc.Owner.Email});
                email.setSubject('Bosch Partner Number - Action Required for ' + acc.Name);                
                email.setHtmlBody(htmlBody);
                email.setSaveAsActivity(false);
                emailsToSend.add(email);
            }
            acc.pkl_Status__c = 'Bosch Partner Number not Received';
            accountsToUpdate.add(acc);
        }
        // Update accounts
        if (!accountsToUpdate.isEmpty()) {
            try {
                Database.SaveResult[] results = Database.update(accountsToUpdate, false);
                // Log any failures
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        Logger.error('Failed to update account', + accountsToUpdate[i].Id + 
                                   ', Error: ' + results[i].getErrors());
                    }
                }
            } catch (Exception e) {
                Logger.error('Error updating accounts: ' + e.getMessage());
            } finally {
            Logger.saveLog();
        	}
        }
        
        // Send emails
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
                
                // Log results
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        Logger.error('Error sending emails', results[i].getErrors()[0].getMessage());
                    }
                }
            } catch (Exception e) {
                Logger.error('Error sending emails', e);
                throw e;
            } finally {
            Logger.saveLog();
        	}
        }
    }
    
    // Batch finish method - cleanup and logging
    global void finish(Database.BatchableContext bc) {
        Logger.info('Batch Job Finished with job id.'+bc.getJobId());
        Logger.saveLog();
    }
    
    // Schedulable interface method - runs the batch job
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new AthenaAccountNotificationBatch(), 200);
    }
}