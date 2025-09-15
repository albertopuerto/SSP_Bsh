import { LightningElement, track , api ,wire} from 'lwc';
import { getObjectInfo } from 'lightning/uiRecordApi';
import getAuthorizatiToken from '@salesforce/apex/CreditLimitGetAuthorizations.getAuthorizationToken';
import callGetLimit from '@salesforce/apex/CreditLimitManager.callGetLimit';
import checkAthenaId from '@salesforce/apex/CreditLimitManager.checkAthenaId';
import getObjectCurrency from '@salesforce/apex/CreditLimitManager.getObjectCurrency';
import { getRecord } from "lightning/uiRecordApi";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class creditLimit extends LightningElement {
   @track accountRecord = false;
   @track quoteRecord = false;
   @track orderRecord = false;
   @track showAccountLimit = false;
   @track showError = false;
   @track accountLimit = 0;
   @track authToken;
   @api objectApiName;
   @api recordId;
   @track quoteLimitMessage;
   @track quoteLimitSuccess = false;
   @track quoteLimitError= false;
   @track orderLimitMessage;
   @track orderLimitSuccess = false;
   @track orderLimitError= false;

   @track disableButton= false;

   @track errorMessage;

   @track isLoading= true;

   @track objectCurrency;
   
   @track creditInfoWrapper;

   @track recordData;

   @track buttonTitle = '';

    @wire(getRecord, { recordId: "$recordId", fields: ["Account.txt_AthenaUUID__c"] })
    wiredAccount({ data, error }) {
    
    if(data){
    this.recordData = data;
    this.detectObject();
    }
    
  //  alert('aaaaa '+ JSON.stringify(data.fields));
    
  }

   detectObject(){

    this.emptyVariables();
        
    if(this.objectApiName == 'Account'){
        
        this.accountRecord = true;
    
        if (this.recordData.fields.txt_AthenaUUID__c.value !=null) {
        
            this.disableButton=false;
            this.buttonTitle= '';
            
        }else{
       
            this.disableButton=true; 
            this.buttonTitle= 'Please fill the Athena ID before checking the Credit Limit';
           
        }
    /*
            checkAthenaId({objectRecordId : this.recordId})
            .then(result => {
               
           
            })*/
        
    }else if(this.objectApiName == 'SBQQ__Quote__c'){
        this.quoteRecord = true;
    }else if(this.objectApiName == 'Order'){
        this.orderRecord = true;
    }
    }
    
    connectedCallback(){
    
    setTimeout(() => {
     this.detectObject();
    
     if(this.quoteRecord== true){
      
        this.getQuoteCreditLimit();
        
     }
     this.getOrderCreditLimit();
    }, 500);
   
    //this.getAuthorizationToken();
    
    }

    getAuthorizationToken(){
        getAuthorizatiToken({recordId : this.recordId})
        .then(result => {
            this.authToken = result;
        })
    }

    
    refreshCallMethodWorthiness(){
        this.emptyVariables();
        this.isLoading=true;
      //  alert('quoteRecord '+ this.quoteRecord);
      //  alert('orderRecord '+ this.orderRecord);

        if(this.quoteRecord== true){
      
            this.getQuoteCreditLimit();
        
        }else if(this.orderRecord==true){

            this.getOrderCreditLimit();
        }
    }

    emptyVariables(){
        this.errorMessage= '';
        this.quoteLimitMessage= '';
        this.orderLimitMessage= '';
        this.accountLimit= 0;
        this.showAccountLimit= false;
        this.showError= false;
        this.quoteLimitSuccess = false;
        this.quoteLimitError= false;
        this.quoteLimitMessage= '';
        this.orderLimitSuccess= false;
        this.orderLimitError= false;
        this.orderLimitMessage= '';
    }
   
   // call to a class for the three methods one class apart with the three calls to the three endpoints and the respective errors to nebula, If there is any error or failure send a toast
getAccountCreditLimit(){
        

         getObjectCurrency({isAccount:this.accountRecord,isQuote: this.quoteRecord, isOrder: this.orderRecord,objectRecordId : this.recordId})
            .then(result => {
                if(result != null){
                    this.objectCurrency=result;
                }
            })

       
        callGetLimit({isAccount:this.accountRecord,isQuote: this.quoteRecord, isOrder: this.orderRecord,objectRecordId : this.recordId})
            .then(result => {
                if(result != null){
                    this.creditInfoWrapper = result;
                   
                    console.log('wrap message '+JSON.stringify(result));
                
                    this.accountLimit= this.creditInfoWrapper.message;

                    if(this.creditInfoWrapper.success== true){
                        this.showAccountLimit= true;
                    }else{
                        this.showError= true;     
                        this.errorMessage= this.creditInfoWrapper.message;               
                    }
                }
            })
      
   }

   getQuoteCreditLimit(){ 
    
        callGetLimit({isAccount:this.accountRecord,isQuote: this.quoteRecord, isOrder: this.orderRecord,objectRecordId : this.recordId})
            .then(result => {
              
                if(result.success == false){
                    
                    this.quoteLimitMessage= result.message;
                    this.quoteLimitError=true;

                }else{
                   
                    this.quoteLimitMessage= 'The credit limit has not been exceeded yet';
                    this.quoteLimitSuccess= true;
                }
               
                this.isLoading= false;
               
            })
   }

   getOrderCreditLimit(){
        callGetLimit({isAccount:this.accountRecord,isQuote: this.quoteRecord, isOrder: this.orderRecord,objectRecordId : this.recordId})
            .then(result => {

                if(result.success == false){
                    
                    this.orderLimitMessage= result.message;
                    this.orderLimitError=true;

                }else{
                   
                    this.orderLimitMessage= 'The credit limit has not been exceeded yet';
                    this.orderLimitSuccess= true;
                }
              
                this.isLoading= false;
            })
   }
}