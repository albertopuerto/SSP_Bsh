/**
 * @description Test class for flw_Quote_BeforeCreate_PreFillFields flow
 * @author SNV1SF
 * @date 2026
 */


@isTest
public class QuoteValidateQuoteFieldsFlowTest {
        
@TestSetup  
     static void setupData() {  
    
         // Create a test Account
         Account account = (Account)TestFactory.createSObject(new Account(),'TestFactoryDefaults.AccountDefaults', true);    
         
         //Create Sales Area
         SalesArea__c salesArea = (SalesArea__c)TestFactory.createSObject(new SalesArea__c(),'TestFactoryDefaults.SalesAreaDefaults', true);
         
         // Create Sales Data Customer
         SalesAreaLink__c salesAreaLink = (SalesAreaLink__c)TestFactory.createSObject(new SalesAreaLink__c(),'TestFactoryDefaults.SalesAreaLinkDefaults', false);
         salesAreaLink.mdr_Account__c = account.Id;
         salesAreaLink.mdr_SalesArea__c = salesArea.Id;
         insert salesAreaLink;

         // Create Bosch Partner Functions
         BoschPartnerFunction__c billto = new BoschPartnerFunction__c();
         billto.Name ='Bill-to' ;
         billto.txt_PartnerFunction__c = 'BP';
         insert billto;
         
         BoschPartnerFunction__c shipto = new BoschPartnerFunction__c();
         shipto.Name ='Ship-to' ;
         shipto.txt_PartnerFunction__c = 'SH';
         insert shipto;
         
         //Create Bosch Partner: Partner Functions
         BoschPartner_PartnerFunction__c prf1 = new  BoschPartner_PartnerFunction__c();
         prf1.lkp_SalesDataCustomer__c = salesAreaLink.Id;
         prf1.mdr_BoschPartnerFunction__c = billto.Id;
         prf1.ReferencedAccount__c = account.Id;
         insert prf1;

         BoschPartner_PartnerFunction__c prf2 = new  BoschPartner_PartnerFunction__c();
         prf2.lkp_SalesDataCustomer__c = salesAreaLink.Id;
         prf2.mdr_BoschPartnerFunction__c = shipto.Id;
         prf2.ReferencedAccount__c = account.Id;
         insert prf2;

         // Create Opportunity
         Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity(),'TestFactoryDefaults.OpportunityDefaults', false);
         opp.Name ='Test Opportunity for Quote PreFill fields';
         opp.AccountId = account.Id;
         opp.lkp_SalesDataCustomer__c = salesAreaLink.Id;      
         insert opp;
     }           

@isTest
static void validateCreateQuoteInheritOpportunityFields() {
      // Get records
        Account acc = [SELECT Id FROM Account LIMIT 1];    
        SalesAreaLink__c salesAreaLink = [SELECT Id FROM SalesAreaLink__c LIMIT 1 ];        
        Opportunity opp = [SELECT Id, CurrencyIsoCode, lkp_SalesDataCustomer__c  FROM Opportunity LIMIT 1 ];
        BoschPartnerFunction__c pfBill = [SELECT Id, Name FROM BoschPartnerFunction__c WHERE txt_PartnerFunction__c = 'BP' LIMIT 1 ];
        BoschPartnerFunction__c pfShip = [SELECT Id, Name FROM BoschPartnerFunction__c WHERE txt_PartnerFunction__c = 'SH' LIMIT 1 ];
        BoschPartner_PartnerFunction__c bill = [SELECT ReferencedAccount__c FROM  BoschPartner_PartnerFunction__c WHERE mdr_BoschPartnerFunction__c = :pfBill.Id AND lkp_SalesDataCustomer__c = :opp.lkp_SalesDataCustomer__c];
        BoschPartner_PartnerFunction__c ship = [SELECT ReferencedAccount__c FROM  BoschPartner_PartnerFunction__c WHERE mdr_BoschPartnerFunction__c = :pfShip.Id AND lkp_SalesDataCustomer__c = :opp.lkp_SalesDataCustomer__c];
               
        SBQQ__Quote__c quote =  new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;        
        quote.lkp_SalesArea__c = opp.lkp_SalesDataCustomer__c;
        quote.CurrencyIsoCode = opp.CurrencyIsoCode;
        quote.lkp_BillToAccount__c = bill.ReferencedAccount__c;
        quote.lkp_ShipToAccount__c = ship.ReferencedAccount__c;
        insert quote;
    
        Test.startTest();
             Database.SaveResult result = Database.insert(quote, false);  
        Test.stopTest();
    
        Assert.areEqual(quote.CurrencyIsoCode, opp.CurrencyIsoCode, 'The quote has the same currency as the related opportunity.');
        Assert.areEqual(quote.lkp_SalesArea__c, opp.lkp_SalesDataCustomer__c, 'The quote has the same Sales Area as the related opportunity.');
        Assert.areEqual(quote.lkp_BillToAccount__c, bill.ReferencedAccount__c, 'The Bill-to account on the quote is the same as the Referenced Account on Bosch Partner: Partner Function record for Bill-to partner function');
        Assert.areEqual(quote.lkp_ShipToAccount__c, ship.ReferencedAccount__c, 'The Ship-to account on the quote is the same as the Referenced Account on Bosch Partner: Partner Function record for Ship-to partner function');
       
    
}        
    
}