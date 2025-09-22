public without sharing class CreditLimitWrappers {
    public class AccountRequest{
        public String DebtorPartyInternalID;
        public String schemeAgencyID;
        public String CreditsegmentInternalID;
        public String languageCode;
    }

    public class CheckingSchedule{
        public Date ValuationDate;
        public Decimal CheckedAmount;
        public String CreditSegmentInternalID;
        public String currencyCode;
    }

    public class DebtorParty{
        public String InternalID;
        public String schemeAgencyID;
    }

    public class CreditWorthinessQueryRequest{
        public String CreditSegmentInternalID;
        public CheckingSchedule CheckingSchedule;
        public DebtorParty DebtorParty;
        
    }

     // response side of the wrapper 

    public class CheckingDescs{
        public String languageCode { get; set; }  // replace with @languageCode
        public String dollar { get; set; }   // replace with $
    }

    public class debtorPartyInternalID {
        public String schemeID { get; set; } // replace with @schemeId
        public String schemeAgencyID { get; set; } // replace with @schemeAgencyID
        public String dollar { get; set; } // replace with $
    }


    public class DebtorPartyResponse{
        public debtorPartyInternalID InternalID { get; set; }
    }

    public class ratingValidityPeriod {
        public String EndDateTime { get; set; }
    }

    public class Rating{
        public String Code { get; set; }
        public RatingValidityPeriod ValidityPeriod { get; set; }
    }

    public class RiskClassValidityPeriod {
        public String EndDateTime { get; set; }
    }

    public class RiskClass{
        public String Code { get; set; }
        public RiskClassValidityPeriod ValidityPeriod { get; set; }
    }

    public class creditLimitAmount{
        public String currencyCode { get; set; } // replace with @currencyCode
        public String dollar { get; set; }   // replace with $
    }

    public class creditLimitValidityPeriod {
        public String EndDateTime { get; set; }
    }

     public class creditLimitResponse{
        public creditLimitAmount Amount { get; set; }
        public creditLimitValidityPeriod ValidityPeriod { get; set; }
    }

     public class creditExposureAmount{
        public String currencyCode { get; set; } // replace with @currencyCode
        public String dollar { get; set; }  // replace with $
    }

    public class creditExposure{
        public creditExposureAmount Amount { get; set; }
    }

   
    public class CreditWorthiness{
        public String CreditSegmentInternalID { get; set; }
        public String Indicator { get; set; }
        public List<CheckingDescs> CheckingDescription { get; set; }
        public String DebtorPartyBlockedIndicator { get; set; }
        public String DebtorPartySpecialAttentionRequiredIndicator { get; set; }
        public String DynamicCheckHorizonEndDate { get; set; }
        public DebtorPartyResponse DebtorParty { get; set; }
        public Rating Rating { get; set; }
        public RiskClass RiskClass { get; set; }
        public creditLimitResponse creditLimit { get; set; }
        public creditExposure CreditExposure { get; set; }

      //  public 
    }
    
    public class CreditWorthinessResponse{
        public CreditWorthiness CreditWorthiness { get; set; }
    }

    public class Body {
        public CreditWorthinessResponse CreditWorthinessResponse { get; set; }
    }

    public class Envelope {
        public String Header { get; set; }
        public Body Body { get; set; }
    }

     public class wrapperResponse {
        public Envelope Envelope { get; set; }
    }



//account response

     public class RelatedAccountsCommitmentTotalAmount{
        public String currencyCode;
        public String dollar;
     }
     public class CreditCommitmentTotalAmount{
        public String currencyCode;
        public String dollar;
     }
     public class CommitmentTotal{
        public String CreditCommitmentTypeCode;
        public CreditCommitmentTotalAmount CreditCommitmentTotalAmount;
        public RelatedAccountsCommitmentTotalAmount RelatedAccountsCommitmentTotalAmount;
     }
     public class CollectionAgencySubmittedAmount{
        public String currencyCode;
        public String dollar;
     }
     public class withDiscountTotalAmount{
        public String currencyCode;
        public String dollar;
     }
     public class WithDiscountPaymentsAverageArrearsDuration{
        public String AverageArrearsDuration;
        public withDiscountTotalAmount CurrentYearTotalAmount;
     }

    public class withoutDiscountTotalAmount{
        public String currencyCode;
        public String dollar;
     }
     public class WithoutDiscountPaymentsAverageArrearsDuration{
        public String AverageArrearsDuration;
        public withoutDiscountTotalAmount CurrentYearTotalAmount;
     }
     public class LastTwelfeMonthsSalesVolumeAmount{
        public String currencyCode;
        public String dollar;
     }
     public class LastTwelfeMonthsCreditExposureMaximumAmount{
        public String currencyCode;
        public String dollar;
     }
     public class ReceivablesTotalAmount{
        public String currencyCode;
        public String dollar;
     }
     public class OldestOpenItemAmount{
        public String currencyCode;
        public String dollar;
     }
     public class OldestOpenItem {
        public String AccountingDocumentID;
        public String AccountingDocumentItemID;
        public OldestOpenItemAmount OldestOpenItemAmount;
        public String OverdueNetDate;
     }
     public class PaymentBehaviourSummary{
        public OldestOpenItem OldestOpenItem;
        public ReceivablesTotalAmount ReceivablesTotalAmount;
        public String DaysOfSalesOutstandingAverageDuration;
        public LastTwelfeMonthsCreditExposureMaximumAmount LastTwelfeMonthsCreditExposureMaximumAmount;
        public LastTwelfeMonthsSalesVolumeAmount LastTwelfeMonthsSalesVolumeAmount;
        public WithoutDiscountPaymentsAverageArrearsDuration WithoutDiscountPaymentsAverageArrearsDuration;
        public WithDiscountPaymentsAverageArrearsDuration WithDiscountPaymentsAverageArrearsDuration;
        public CollectionAgencySubmittedAmount CollectionAgencySubmittedAmount;
        
     }

     public class CreditRiskValidityPeriod{
        public String StartDate;
        public String EndDate;
     }
     public class CreditRiskDescription{
        public String languageCode;
        public String dollar;
     }
      public class CreditRiskClass{
        public CreditRiskValidityPeriod ValidityPeriod;
        public String Code;
        public CreditRiskDescription Description;
     }

     public class CreditRatingValidityPeriod{
        public String StartDate;
        public String EndDate;
     }
      public class CreditRating{
        public CreditRatingValidityPeriod ValidityPeriod;
        public String Code;
     }
      public class accountCreditExposureAmount{
        public String currencyCode;
        public String dollar;
     }
      public class accountCreditExposure{
        public accountCreditExposureAmount Amount;
        public String Percent;
        public String DynamicCheckCreditHorizonEndDate;
     }

     public class accountCreditLimitValidityPeriod{
        public String StartDate;
        public String EndDate;
     }
     public class accountCreditLimitAmount{
        public String currencyCode;
        public String dollar;
     }

    public class BlockingReasonCodeDescription{
        public String languageCode { get; set; }
    }

    public class CreditSegmentDescription{
        public String languageCode { get; set; }
    }

    public class accountDebtorPartyInternalID{
        public String schemeID { get; set; }
        public String schemeAgencyID { get; set; }
        public String dollar { get; set; }
    }

     public class MessageHeader{
        public String ID { get; set; }
        public String CreationDateTime {get; set;}
    }
   
    public class CreditManagementAccount{
        public accountDebtorPartyInternalID DebtorPartyInternalID { get; set; }
        public String CreditsegmentInternalID { get; set; }
        public CreditSegmentDescription CreditSegmentDescription { get; set; }
        public String CreditWorthinessCheckingRuleCode { get; set; }
        public String CreditWorthinessCheckingSchemeCode { get; set; }
        public String SpecialAttentionRequiredIndicator { get; set; }
        public String BlockedIndicator { get; set; }
        public BlockingReasonCodeDescription BlockingReasonCodeDescription { get; set; }
        public accountCreditLimitAmount CreditLimitAmount { get; set; }
        public accountCreditLimitValidityPeriod CreditLimitValidityPeriod { get; set; }
        public accountCreditExposure CreditExposure { get; set; }
        public CreditRating CreditRating { get; set; }
        public CreditRiskClass CreditRiskClass { get; set; }
        public PaymentBehaviourSummary PaymentBehaviourSummary { get; set; }
        public List<CommitmentTotal> CommitmentTotal { get; set; }
    }    
    public class LogItem {
        public String TypeID {get;set;}
        public String SeverityCode {get;set;}
        public String Note {get;set;}
    }
        
    public class LogAccount {
        public String MaximumLogItemSeverityCode {get;set;}
        public LogItem Item {get;set;}
    }    
      //  public 
    
    public class CreditManagementAccountByIDResponse {
        public MessageHeader MessageHeader { get; set; }
        public CreditManagementAccount CreditManagementAccount {get;set;}
        public LogAccount Log {get;set;}
    }

    public class accountBody {
        public CreditManagementAccountByIDResponse CreditManagementAccountByIDResponse { get; set; }
    }

    public class accountEnvelope {
        public String Header { get; set; }
        public accountBody Body { get; set; }
    }

     public class accountWrapperResponse {
        public accountEnvelope Envelope { get; set; }
    }
    
    public class creditLimitInfoWrapper {
        @AuraEnabled public Integer status { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Boolean success { get; set; }
        
    }
}