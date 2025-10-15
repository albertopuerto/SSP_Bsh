/**
* @author       APB
* @description  CreditLimitWrappers: Class that contains the credit limit wrappers
*/
public without sharing class CreditLimitWrappers {

    /**
	* @author       APB
	* @description  Account Request wrapper
	*/
    public class AccountRequest{
        public String debtorPartyInternalID;
        public String schemeAgencyID;
        public String creditsegmentInternalID;
        public String languageCode;
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Request wrapper CheckingSchedule
	*/
    public class CheckingSchedule{
        public Date ValuationDate;
        public Decimal CheckedAmount;
        public String CreditSegmentInternalID;
        public String currencyCode;
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Request wrapper DebtorParty
	*/
    public class DebtorParty{
        public String InternalID;
        public String schemeAgencyID;
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Request wrapper
	*/
    public class CreditWorthinessQueryRequest{
        public String CreditSegmentInternalID;
        public CheckingSchedule CheckingSchedule;
        public DebtorParty DebtorParty;
    }

     // response side of the wrapper

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CheckingDescs
	*/
    public class CheckingDescs{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CheckingDescs languageCode
	    */
        public String languageCode { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CheckingDescs dollar
	    */
        public String dollar { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper DebtorPartyInternalID
	*/
    public class DebtorPartyInternalID {
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper DebtorPartyInternalID schemeID
	    */
        public String schemeID { get; set; } // replace with @schemeId
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper DebtorPartyInternalID schemeAgencyID
	    */
        public String schemeAgencyID { get; set; } // replace with @schemeAgencyID
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper DebtorPartyInternalID dollar
	    */
        public String dollar { get; set; } // replace with $
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper DebtorPartyResponse
	*/
    public class DebtorPartyResponse{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper DebtorPartyResponse internalID
	    */
        public DebtorPartyInternalID internalID { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper RatingValidityPeriod
	*/
    public class RatingValidityPeriod {
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper RatingValidityPeriod endDateTime
	    */
        public String endDateTime { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper Rating
	*/
    public class Rating{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper Rating code
	    */
        public String code { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper Rating validityPeriod
	    */
        public RatingValidityPeriod validityPeriod { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper RiskValidityPeriod
	*/
    public class RiskClassValidityPeriod {
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper endDateTime
	    */
        public String endDateTime { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper Risk
	*/
    public class RiskClass{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper Risk code
	    */
        public String code { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper Risk validityPeriod
	    */
        public RiskClassValidityPeriod validityPeriod { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CreditLimitAmount
	*/
    public class CreditLimitAmount{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditLimitAmount currencyCode
	    */
        public String currencyCode { get; set; } // replace with @currencyCode
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditLimitAmount dollar
	    */
        public String dollar { get; set; }   // replace with $
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CreditLimitValidityPeriod
	*/
    public class CreditLimitValidityPeriod {
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditLimitValidityPeriod endDateTime
	    */
        public String endDateTime { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CreditLimitResponse
	*/
    public class CreditLimitResponse{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditLimitResponse amount
	    */
        public CreditLimitAmount amount { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditLimitResponse validityPeriod
	    */
        public CreditLimitValidityPeriod validityPeriod { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CreditExposureAmount
	*/
    public class CreditExposureAmount{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditExposureAmount currencyCode
    	*/
        public String currencyCode { get; set; } // replace with @currencyCode
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditExposureAmount dollar
	    */
        public String dollar { get; set; }  // replace with $
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CreditExposure
	*/
    public class CreditExposure{
        /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CreditExposure amount
	*/
        public CreditExposureAmount amount { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness
	*/
    public class CreditWorthiness{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness creditSegmentInternalID
	    */
        public String creditSegmentInternalID { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness indicator
	    */
        public String indicator { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness checkingDescription
	    */
        public List<CheckingDescs> checkingDescription { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness debtorPartyBlockedIndicator
	    */
        public String debtorPartyBlockedIndicator { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness debtorPartySpecialAttentionRequiredIndicator
	    */
        public String debtorPartySpecialAttentionRequiredIndicator { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness dynamicCheckHorizonEndDate
	    */
        public String dynamicCheckHorizonEndDate { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness debtorParty
	    */
        public DebtorPartyResponse debtorParty { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness rating
	    */
        public Rating rating { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness riskClass
	    */
        public RiskClass riskClass { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness creditLimit
	    */
        public CreditLimitResponse creditLimit { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthiness creditExposure
	    */
        public CreditExposure creditExposure { get; set; }
    }
    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper CreditWorthinessResponse
	*/
    public class CreditWorthinessResponse{
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper CreditWorthinessResponse creditWorthiness
	    */
        public CreditWorthiness creditWorthiness { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper Body
	*/
    public class Body {
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper Body creditWorthinessResponse
	    */
        public CreditWorthinessResponse creditWorthinessResponse { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper Envelope
	*/
    public class Envelope {
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper Envelope header
	    */
        public String header { get; set; }
        /**
	    * @author       APB
	    * @description  CreditWorthinessQueryRequest Response wrapper Envelope body
	    */
        public Body body { get; set; }
    }

    /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper
	*/
    public class WrapperResponse {
        /**
	* @author       APB
	* @description  CreditWorthinessQueryRequest Response wrapper envelope
	*/
        public Envelope envelope { get; set; }
    }



    //account response

    /**
	* @author       APB
	* @description  Account Response wrapper RelatedAccountsCommitmentTotalAmount
	*/
    public class RelatedAccountsCommitmentTotalAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper CreditCommitmentTotalAmount
	*/
    public class CreditCommitmentTotalAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper CommitmentTotal
	*/
    public class CommitmentTotal{
        public String creditCommitmentTypeCode;
        public CreditCommitmentTotalAmount creditCommitmentTotalAmount;
        public RelatedAccountsCommitmentTotalAmount relatedAccountsCommitmentTotalAmount;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper CollectionAgencySubmittedAmount
	*/
    public class CollectionAgencySubmittedAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper WithDiscountTotalAmount
	*/
    public class WithDiscountTotalAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper WithDiscountPaymentsAverageArrearsDuration
	*/
    public class WithDiscountPaymentsAverageArrearsDuration{
        public String averageArrearsDuration;
        public WithDiscountTotalAmount currentYearTotalAmount;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper WithoutDiscountTotalAmount
	*/
    public class WithoutDiscountTotalAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper WithoutDiscountPaymentsAverageArrearsDuration
	*/
    public class WithoutDiscountPaymentsAverageArrearsDuration{
        public String averageArrearsDuration;
        public WithoutDiscountTotalAmount currentYearTotalAmount;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper LastTwelfeMonthsSalesVolumeAmount
	*/
    public class LastTwelfeMonthsSalesVolumeAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper LastTwelfeMonthsCreditExposureMaximumAmount
	*/
    public class LastTwelfeMonthsCreditExposureMaximumAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper ReceivablesTotalAmount
	*/
    public class ReceivablesTotalAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper OldestOpenItemAmount
	*/
    public class OldestOpenItemAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper OldestOpenItem
	*/
    public class OldestOpenItem {
        public String accountingDocumentID;
        public String accountingDocumentItemID;
        public OldestOpenItemAmount oldestOpenItemAmount;
        public String overdueNetDate;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper PaymentBehaviourSummary
	*/
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

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditRiskValidityPeriod
	*/
    public class CreditRiskValidityPeriod{
        public String startDate;
        public String endDate;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditRiskDescription
	*/
    public class CreditRiskDescription{
        public String languageCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditRisk
	*/
    public class CreditRiskClass{
        public CreditRiskValidityPeriod validityPeriod;
        public String code;
        public CreditRiskDescription description;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditRatingValidityPeriod
	*/
    public class CreditRatingValidityPeriod{
        public String startDate;
        public String endDate;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditRating
	*/
    public class CreditRating{
        public CreditRatingValidityPeriod validityPeriod;
        public String code;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditExposureAmount
	*/
    public class AccountCreditExposureAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditExposure
	*/
    public class AccountCreditExposure{
        public AccountCreditExposureAmount amount;
        public String percent;
        public String dynamicCheckCreditHorizonEndDate;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditLimitAmount
	*/
    public class AccountCreditLimitValidityPeriod{
        public String startDate;
        public String endDate;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountCreditLimitAmount
	*/
    public class AccountCreditLimitAmount{
        public String currencyCode;
        public String dollar;
    }

    /**
	* @author       APB
	* @description  Account Response wrapper CreditSegmentDescription
	*/
    public class BlockingReasonCodeDescription{
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditSegmentDescription languageCode
	    */
        public String languageCode { get; set; }
    }

    /**
	* @author       APB
	* @description  Account Response wrapper CreditSegmentDescription
	*/
    public class CreditSegmentDescription{
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditSegmentDescription languageCode
	    */
        public String languageCode { get; set; }
    }

    /**
	* @author       APB
	* @description  Account Response wrapper AccountDebtorPartyInternalID
	*/
    public class AccountDebtorPartyInternalID{
        /**
	    * @author       APB
	    * @description  Account Response wrapper AccountDebtorPartyInternalID schemeID
	    */
        public String schemeID { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper AccountDebtorPartyInternalID schemeAgencyID
	    */
        public String schemeAgencyID { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper AccountDebtorPartyInternalID dollar
        */
        public String dollar { get; set; }
    }

    /**
	* @author       APB
	* @description  Account Response wrapper MessageHeader
	*/
    public class MessageHeader{
        /**
	    * @author       APB
	    * @description  Account Response wrapper MessageHeader iD
	    */
        public String iD { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper MessageHeader creationDateTime
        */
        public String creationDateTime {get; set;}
    }

    /**
	* @author       APB
	* @description  Account Response wrapper CreditManagementAccount
	*/
    public class CreditManagementAccount{
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount debtorPartyInternalID
	    */
        public AccountDebtorPartyInternalID debtorPartyInternalID { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditsegmentInternalID
	    */
        public String creditsegmentInternalID { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditSegmentDescription
	    */
        public CreditSegmentDescription creditSegmentDescription { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditWorthinessCheckingRuleCode
	    */
        public String creditWorthinessCheckingRuleCode { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditWorthinessCheckingSchemeCode
	    */
        public String creditWorthinessCheckingSchemeCode { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount specialAttentionRequiredIndicator
	    */
        public String specialAttentionRequiredIndicator { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount blockedIndicator
	    */
        public String blockedIndicator { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount blockingReasonCodeDescription
	    */
        public BlockingReasonCodeDescription blockingReasonCodeDescription { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditLimitAmount
	    */
        public AccountCreditLimitAmount creditLimitAmount { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditLimitValidityPeriod
	    */
        public AccountCreditLimitValidityPeriod creditLimitValidityPeriod { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditExposure
	    */
        public AccountCreditExposure creditExposure { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditRating
	    */
        public CreditRating creditRating { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount creditRiskClass
	    */
        public CreditRiskClass creditRiskClass { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount paymentBehaviourSummary
	    */
        public PaymentBehaviourSummary paymentBehaviourSummary { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccount commitmentTotal
	    */
        public List<CommitmentTotal> commitmentTotal { get; set; }
    }

    /**
	* @author       APB
	* @description  Account Response wrapper LogItem
	*/
    public class LogItem {
        /**
	    * @author       APB
	    * @description  Account Response wrapper LogItem typeID
	    */
        public String typeID {get;set;}
        /**
	    * @author       APB
	    * @description  Account Response wrapper LogItem severityCode
	    */
        public String severityCode {get;set;}
        /**
	    * @author       APB
	    * @description  Account Response wrapper LogItem note
	    */
        public String note {get;set;}
    }

    /**
	* @author       APB
	* @description  Account Response wrapper LogAccount
	*/
    public class LogAccount {
        /**
	    * @author       APB
	    * @description  Account Response wrapper LogAccount maximumLogItemSeverityCode
	    */
        public String maximumLogItemSeverityCode {get;set;}
        /**
	    * @author       APB
	    * @description  Account Response wrapper LogAccount item
	    */
        public LogItem item {get;set;}
    }

    /**
	* @author       APB
	* @description  Account Response wrapper CreditManagementAccountByIDResponse
	*/
    public class CreditManagementAccountByIDResponse {
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccountByIDResponse messageHeader
	    */
        public MessageHeader messageHeader { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccountByIDResponse creditManagementAccount
	    */
        public CreditManagementAccount creditManagementAccount {get;set;}
        /**
	    * @author       APB
	    * @description  Account Response wrapper CreditManagementAccountByIDResponse log
	    */
        public LogAccount log {get;set;}
    }

    /**
	* @author       APB
	* @description  Account Response wrapper Body
	*/
    public class AccountBody {
        /**
	    * @author       APB
	    * @description  Account Response wrapper Body creditManagementAccountByIDResponse
	    */
        public CreditManagementAccountByIDResponse creditManagementAccountByIDResponse { get; set; }
    }

    /**
	* @author       APB
	* @description  Account Response wrapper Envelope
	*/
    public class AccountEnvelope {
        /**
	    * @author       APB
	    * @description  Account Response wrapper Envelope header
	    */
        public String header { get; set; }
        /**
	    * @author       APB
	    * @description  Account Response wrapper Envelope body
	    */
        public AccountBody body { get; set; }
    }

    /**
	* @author       APB
	* @description  Account Response wrapper
	*/
    public class AccountWrapperResponse {
        /**
	    * @author       APB
	    * @description  Account Response wrapper envelope
	    */
        public AccountEnvelope envelope { get; set; }
    }

    /**
	* @author       APB
	* @description  Account Responses info wrapper
	*/
    public class CreditLimitInfoWrapper {
        /**
	    * @author       APB
	    * @description  Account Responses info wrapper status
	    */
        @AuraEnabled public Integer status { get; set; }
        /**
	    * @author       APB
	    * @description  Account Responses info wrapper message
	    */
        @AuraEnabled public String message { get; set; }
        /**
	    * @author       APB
	    * @description  Account Responses info wrapper success
	    */
        @AuraEnabled public Boolean success { get; set; }

    }
}