/**
* @author       TLQ1KOR
* @date         2025
* @description  BSSP-9781:If-002 Negative scenario 4
*/
@RestResource(urlMapping='/athenaAccountErrorHandler')
global with sharing class AccountErrorService {
    
    @HttpPost
    global static String handlePostRequest(String requestBody) {
        String id = '';
        String correlationId = '';
        
        try {
            Logger.info('AccountErrorService.handlePostRequest started');
            Logger.debug('Received request body: ' + requestBody);
            
            // Parse the incoming JSON payload
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Extract the businessPartnerCreateError object
            Map<String, Object> errorData = (Map<String, Object>) requestData.get('businessPartnerCreateError');
            
            // Extract required fields
            id = (String) errorData.get('Id');
            String statusCode = (String) errorData.get('Status Code');
            String statusText = (String) errorData.get('Status Text');
            correlationId = (String) errorData.get('CorrelationId');
            
            Logger.debug('Processing error for Account Id: ' + id + ', CorrelationId: ' + correlationId);
            
            // Query the Account
            List<Account> accounts = [SELECT Id, Name, OwnerId, Owner.Email, Owner.Name, Owner.FirstName, Owner.LastName 
                                    FROM Account 
                                    WHERE Id = :id 
                                    LIMIT 1];
            
            Account account = accounts[0];
            
            // Update Account Status to "Error in sending to Athena"
            account.pkl_Status__c = 'Error in sending to Athena';
            update account;
            
            Logger.debug('Account status updated to "Error in sending to Athena" for Account: ' + account.Name);
            
            // Create account link
            String accountLink = System.URL.getOrgDomainUrl().toExternalForm() + '/' + account.Id;
            
            // Send Email to Account Owner
            sendEmailNotification(
                account.Owner.FirstName, 
                account.Owner.LastName, 
                account.Name, 
                statusText, 
                correlationId, 
                accountLink,
                account.OwnerId,
                account.Id
            );
            
            Logger.info('Successfully processed error for Account: ' + account.Name + ', CorrelationId: ' + correlationId);

            
        } catch (Exception ex) {
            Logger.error('Exception in handlePostRequest for Account Id: ' + id + ', CorrelationId: ' + correlationId, ex);
        } finally {
            Logger.saveLog();
        }
        
        // Return success response
        return JSON.serialize(new Map<String, String>{
            'Id' => id,
            'errorcode' => '0',
            'errorMessage' => 'Error processed successfully',
            'correlationId' => correlationId
        });
    }
    
    private static void sendEmailNotification(String firstName, String lastName, String accountName, String statusText, String correlationId, String accountLink, Id ownerId, Id accountId) {
        try {
            Logger.debug('Sending email notification to Account Owner. AccountId: ' + accountId + ', OwnerId: ' + ownerId);
            
            // Get the email template
            List<EmailTemplate> templates = [SELECT Id, Subject, HtmlValue, Body 
                                           FROM EmailTemplate 
                                           WHERE DeveloperName = 'Athena_Account_Failed' 
                                           LIMIT 1];
            
            if (templates.isEmpty()) {
                Logger.debug('Email template Athena_Account_Failed not found');
                return;
            }
            
            EmailTemplate template = templates[0];
            
            // Create and send email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template.Id);
            email.setTargetObjectId(ownerId); // Set the email recipient to the account owner
            email.setWhatId(accountId); // Link the email to the account
            email.setSaveAsActivity(false);
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            
            Logger.info('Email sent successfully to account owner. AccountName: ' + accountName + ', CorrelationId: ' + correlationId);
            
        } catch (Exception ex) {
            Logger.error('Exception in sendEmailNotification for Account: ' + accountName + ', CorrelationId: ' + correlationId, ex);
        }
    }
}