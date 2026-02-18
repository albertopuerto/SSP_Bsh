@isTest
public class SolutionQuotationService_Test {

    /**
    * @author       APB
    * @description  Method used to create the records
    */
    @testSetup
    public static void initRecords(){

        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c= '3123213';
        testAccountList[0].BillingCountryCode= 'DE';
        insert testAccountList;
        
        Order[] orderList = (Order [])TestFactory.createSObjectList(new Order(),1);
        orderList[0].Status= 'Draft';
        orderList[0].AccountId= testAccountList[0].Id;
        insert orderList;
    }

    @IsTest
    static void testErrorFromSAP() {

        User productManagerUser = createUser();
        Test.startTest();

        EmailTemplate template = new EmailTemplate();
        template.Description= 'ErrorInOrderWhenSendingToSap';
        template.Name= 'ErrorInOrderWhenSendingToSap';
        template.HtmlValue = '<html> <head></head><body>     <p>Dear Owner_Name Owner_LastName ,</p>     <p>On the transfer of your Order Order_Number for AccountName an error has occurred and the Order was not sent to SAP.</p>     <p>The following details have been provided by the interface:</p>     <p>Status Code: Status_Code<br />     Status Text: Status_Text<br />     CorrelationId: Correlation_Id</p>     <p>Please contact your SCC Department to clarify details.</p>     <p>Here is the Link to your Order: <a href="Order_Link">Order_Link</a></p> </body> </html>';
       	template.DeveloperName= 'ErrorInOrderWhenSendingToSap';
        template.FolderId= productManagerUser.Id;
        template.TemplateType= 'custom';
        insert template;

        System.runAs(productManagerUser){

        	Order orderTest = [SELECT Id,Status,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c from Order LIMIT 1];

            orderTest.OwnerId= productManagerUser.Id;
            update orderTest;
            
			String errorSapResponseBody =  '{"solutionQuotationCreateError": {' +
            '"Id": "' + orderTest.Id + '",' +
            '"Status Code": "1",' +
            '"Status Text": "Error",' +
            '"CorrelationId": "15734634262546"' +
        	'}}';

            RestRequest req = new RestRequest();
        	req.requestBody = Blob.valueOf(errorSapResponseBody);
        	req.httpMethod = 'POST';
        	req.requestURI = '/services/apexrest/solutionQuotation';

        	RestContext.request = req;
            String responseString = SolutionQuotationService.handlePostRequest();
            Map<String, Object> errorMessage = (Map<String, Object>) JSON.deserializeUntyped(responseString);

    	    Assert.areEqual('Error processed successfully', (String) errorMessage.get('errorMessage') ,'The status is succesfully processed');

        }
        Test.stopTest();

    }

    static User createUser(){
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
       PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesBasic' LIMIT 1];
       PermissionSetLicense psl = [SELECT Id from PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' ];

       PermissionSetLicenseAssign pslassignment = new PermissionSetLicenseAssign(
            PermissionSetLicenseId = psl.Id,
            AssigneeId = productManagerUser.Id
        );
        insert pslassignment;

        // Assign the Permission Set to the test user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = productManagerUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
        return productManagerUser;
    }
}