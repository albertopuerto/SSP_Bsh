public without sharing class CreditLimitWrappers {
    public class AccountRequest{
        public String debtorPartyInternalID;
        public String schemeAgencyID;
        public String creditsegmentInternalID;
        public String languageCode;
    }

    public class CheckingSchedule{
        public Date valuationDate;
        public Decimal checkedAmount;
        public String creditSegmentInternalID;
        public String currencyCode;
    }

    public class DebtorParty{
        public String internalID;
        public String schemeAgencyID;
    }

    public class CreditWorthinessQueryRequest{
        public String creditSegmentInternalID;
        public CheckingSchedule checkingSchedule;
        public DebtorParty debtorParty;
        
    }

     // response side of the wrapper

    public class CheckingDescs{
        public String languageCode { get; set; }  // replace with @languageCode
        public String dollar { get; set; }   // replace with $
    }

    public class DebtorPartyInternalID {
        public String schemeID { get; set; } // replace with @schemeId
        public String schemeAgencyID { get; set; } // replace with @schemeAgencyID
        public String dollar { get; set; } // replace with $
    }


    public class DebtorPartyResponse{
        public DebtorPartyInternalID internalID { get; set; }
    }

    public class RatingValidityPeriod {
        public String endDateTime { get; set; }
    }

    public class Rating{
        public String code { get; set; }
        public RatingValidityPeriod validityPeriod { get; set; }
    }

    public class RiskClassValidityPeriod {
        public String endDateTime { get; set; }
    }

    public class RiskClass{
        public String code { get; set; }
        public RiskClassValidityPeriod validityPeriod { get; set; }
    }

    public class CreditLimitAmount{
        public String currencyCode { get; set; } // replace with @currencyCode
        public String dollar { get; set; }   // replace with $
    }

    public class CreditLimitValidityPeriod {
        public String endDateTime { get; set; }
    }

     public class CreditLimitResponse{
        public CreditLimitAmount amount { get; set; }
        public CreditLimitValidityPeriod validityPeriod { get; set; }
    }

     public class CreditExposureAmount{
        public String currencyCode { get; set; } // replace with @currencyCode
        public String dollar { get; set; }  // replace with $
    }

    public class CreditExposure{
        public CreditExposureAmount amount { get; set; }
    }

   
    public class CreditWorthiness{
        public String creditSegmentInternalID { get; set; }
        public String indicator { get; set; }
        public List<CheckingDescs> checkingDescription { get; set; }
        public String debtorPartyBlockedIndicator { get; set; }
        public String debtorPartySpecialAttentionRequiredIndicator { get; set; }
        public String dynamicCheckHorizonEndDate { get; set; }
        public DebtorPartyResponse debtorParty { get; set; }
        public Rating rating { get; set; }
        public RiskClass riskClass { get; set; }
        public CreditLimitResponse creditLimit { get; set; }
        public CreditExposure creditExposure { get; set; }

      //  public 
    }
    
    public class CreditWorthinessResponse{
        public CreditWorthiness creditWorthiness { get; set; }
    }

    public class Body {
        public CreditWorthinessResponse creditWorthinessResponse { get; set; }
    }

    public class Envelope {
        public String header { get; set; }
        public Body body { get; set; }
    }

     public class WrapperResponse {
        public Envelope envelope { get; set; }
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
        public String creditCommitmentTypeCode;
        public CreditCommitmentTotalAmount creditCommitmentTotalAmount;
        public RelatedAccountsCommitmentTotalAmount relatedAccountsCommitmentTotalAmount;
     }
     public class CollectionAgencySubmittedAmount{
        public String currencyCode;
        public String dollar;
     }
     public class WithDiscountTotalAmount{
        public String currencyCode;
        public String dollar;
     }
     public class WithDiscountPaymentsAverageArrearsDuration{
        public String averageArrearsDuration;
        public WithDiscountTotalAmount currentYearTotalAmount;
     }

    public class WithoutDiscountTotalAmount{
        public String currencyCode;
        public String dollar;
     }
     public class WithoutDiscountPaymentsAverageArrearsDuration{
        public String averageArrearsDuration;
        public WithoutDiscountTotalAmount currentYearTotalAmount;
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
        public String accountingDocumentID;
        public String accountingDocumentItemID;
        public OldestOpenItemAmount oldestOpenItemAmount;
        public String overdueNetDate;
     }
     public class PaymentBehaviourSummary{
        public OldestOpenItem oldestOpenItem;
        public ReceivablesTotalAmount receivablesTotalAmount;
        public String daysOfSalesOutstandingAverageDuration;
        public LastTwelfeMonthsCreditExposureMaximumAmount lastTwelfeMonthsCreditExposureMaximumAmount;
        public LastTwelfeMonthsSalesVolumeAmount lastTwelfeMonthsSalesVolumeAmount;
        public WithoutDiscountPaymentsAverageArrearsDuration withoutDiscountPaymentsAverageArrearsDuration;
        public WithDiscountPaymentsAverageArrearsDuration withDiscountPaymentsAverageArrearsDuration;
        public CollectionAgencySubmittedAmount collectionAgencySubmittedAmount;
        
     }

     public class CreditRiskValidityPeriod{
        public String startDate;
        public String endDate;
     }
     public class CreditRiskDescription{
        public String languageCode;
        public String dollar;
     }
      public class CreditRiskClass{
        public CreditRiskValidityPeriod validityPeriod;
        public String code;
        public CreditRiskDescription description;
     }

     public class CreditRatingValidityPeriod{
        public String startDate;
        public String endDate;
     }
      public class CreditRating{
        public CreditRatingValidityPeriod validityPeriod;
        public String code;
     }
      public class AccountCreditExposureAmount{
        public String currencyCode;
        public String dollar;
     }
      public class AccountCreditExposure{
        public AccountCreditExposureAmount amount;
        public String percent;
        public String dynamicCheckCreditHorizonEndDate;
     }

     public class AccountCreditLimitValidityPeriod{
        public String startDate;
        public String endDate;
     }
     public class AccountCreditLimitAmount{
        public String currencyCode;
        public String dollar;
     }

    public class BlockingReasonCodeDescription{
        public String languageCode { get; set; }
    }

    public class CreditSegmentDescription{
        public String languageCode { get; set; }
    }

    public class AccountDebtorPartyInternalID{
        public String schemeID { get; set; }
        public String schemeAgencyID { get; set; }
        public String dollar { get; set; }
    }

     public class MessageHeader{
        public String iD { get; set; }
        public String creationDateTime {get; set;}
    }
   
    public class CreditManagementAccount{
        public AccountDebtorPartyInternalID debtorPartyInternalID { get; set; }
        public String creditsegmentInternalID { get; set; }
        public CreditSegmentDescription creditSegmentDescription { get; set; }
        public String creditWorthinessCheckingRuleCode { get; set; }
        public String creditWorthinessCheckingSchemeCode { get; set; }
        public String specialAttentionRequiredIndicator { get; set; }
        public String blockedIndicator { get; set; }
        public BlockingReasonCodeDescription blockingReasonCodeDescription { get; set; }
        public AccountCreditLimitAmount creditLimitAmount { get; set; }
        public AccountCreditLimitValidityPeriod creditLimitValidityPeriod { get; set; }
        public AccountCreditExposure creditExposure { get; set; }
        public CreditRating creditRating { get; set; }
        public CreditRiskClass creditRiskClass { get; set; }
        public PaymentBehaviourSummary paymentBehaviourSummary { get; set; }
        public List<CommitmentTotal> commitmentTotal { get; set; }
    }    
    public class LogItem {
        public String typeID {get;set;}
        public String severityCode {get;set;}
        public String note {get;set;}
    }
        
    public class LogAccount {
        public String maximumLogItemSeverityCode {get;set;}
        public LogItem item {get;set;}
    }    
      //  public 
    
    public class CreditManagementAccountByIDResponse {
        public MessageHeader messageHeader { get; set; }
        public CreditManagementAccount creditManagementAccount {get;set;}
        public LogAccount log {get;set;}
    }

    public class AccountBody {
        public CreditManagementAccountByIDResponse creditManagementAccountByIDResponse { get; set; }
    }

    public class AccountEnvelope {
        public String header { get; set; }
        public AccountBody body { get; set; }
    }

     public class AccountWrapperResponse {
        public AccountEnvelope envelope { get; set; }
    }
    
    public class CreditLimitInfoWrapper {
        @AuraEnabled public Integer status { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Boolean success { get; set; }
        
    }
}