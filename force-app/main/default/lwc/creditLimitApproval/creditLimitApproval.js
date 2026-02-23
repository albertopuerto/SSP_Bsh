import { LightningElement, api,wire,track } from 'lwc';
import hasSubsProducts from '@salesforce/apex/CreditLimitApprovalController.hasSubsProducts';
import callCreditLimit from '@salesforce/apex/CreditLimitApprovalController.callCreditLimit';
import quoteGetFields from '@salesforce/apex/CreditLimitApprovalController.quoteGetFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CreditLimitApproval extends NavigationMixin(LightningElement) {

    @api recordId;
    showSpinner = true;
    showError = false;
    showExceeded= false;
    currency;
    accountLimit;
    vat;
    quoteAmount;

    @track quoteRecord;

    approvalCheck(){

        hasSubsProducts({quoteId : this.recordId})

        .then(result => {

            if(result === true){
                this.handleError(); 
            }
            else{
                this.callCreditLimitMethods();
               // this.getQuoteFields();

            }
        })
    }

    getQuoteFields(){

        quoteGetFields({quoteId : this.recordId})

        
    }

    callCreditLimitMethods(){

        callCreditLimit({quoteId : this.recordId})
        .then(result => {

            this.quoteRecord = result;

                if(this.quoteRecord.pkl_PaymentTerms__c == 'Prepayment' && this.quoteRecord.cur_CreditLimit__c >= this.quoteRecord.cur_Current_Credit_Limit_including_VAT__c ){
                    //this.openSubmitForApproval();
                    alert('enough credit limit');
                }else if(this.quoteRecord.pkl_PaymentTerms__c == 'Prepayment' && this.quoteRecord.cur_CreditLimit__c < this.quoteRecord.cur_Current_Credit_Limit_including_VAT__c){
                    alert('credit limit exceeded');
                    this.currency=this.quoteRecord.CurrencyIsoCode;
                    this.accountLimit= this.quoteRecord.cur_CreditLimit__c;
                    this.vat= this.quoteRecord.cur_Current_Credit_Limit_including_VAT__c - this.quoteRecord.SBQQ__NetAmount__c;
                    this.quoteAmount= this.quoteRecord.SBQQ__NetAmount__c;

                    this.showSpinner=false;
                    this.showExceeded= true;
                }
        })
    }

    connectedCallback(){

        this.approvalCheck();
    }

    openSubmitForApproval(){

        const vfPageUrl = '/apex/SubmitQuote?id=' + this.recordId;
        window.location.href = vfPageUrl;

        /*this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: vfPageUrl
            }
        })*/
       
    }

    handleError(){
        
        this.showSpinner=false;
        this.showError= true;
        
    }
   
}