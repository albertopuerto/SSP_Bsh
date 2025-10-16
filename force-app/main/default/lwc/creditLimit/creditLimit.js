import { LightningElement, track , api ,wire} from 'lwc';
import callGetLimit from '@salesforce/apex/CreditLimitManager.callGetLimit';
import getObjectCurrency from '@salesforce/apex/CreditLimitManager.getObjectCurrency';
import getAccountFields from '@salesforce/apex/CreditLimitManager.getAccountFields';
export default class creditLimit extends LightningElement {
   @track accountRecord = false;
   @track quoteRecord = false;
   @track orderRecord = false;
   @track showAccountLimit = false;
   @track showError = false;
   @track accountLimit;
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
   @track account =[];

   @track buttonTitle = '';

    @wire(getAccountFields,{objectRecordId : '$recordId'})
    wiredAccounts({ error,data }) {

    if(this.objectApiName == 'Account'){
    console.log('accounts' + JSON.stringify(data));
    
    if (data) {
        this.account = data;
        this.error = undefined;
        
        this.accountRecord = true;
    
            if (this.account[0].txt_AthenaUUID__c !=null) {
        
                this.disableButton=false;
                this.buttonTitle= '';
            
            }else{
       
                this.disableButton=true; 
                this.buttonTitle= 'Please fill the Athena ID before checking the Credit Limit';
           
            }
  
        
    } else if (error) {
        this.error = error;
        this.account = undefined;
    }
}
    
  }

   detectObject(){

    if(this.objectApiName == 'SBQQ__Quote__c'){
        this.quoteRecord = true;
    }else if(this.objectApiName == 'Order'){
        this.orderRecord = true;
    }
    }
    
    connectedCallback(){
    this.detectObject();
    
    if(this.quoteRecord== true){
      
        this.getQuoteCreditLimit();
    
    }
     this.getOrderCreditLimit();
    
    }
    
    refreshCallMethodWorthiness(){
        
        this.emptyVariables();
        this.isLoading=true;
    
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
        this.accountLimit;
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
    this.emptyVariables();
        
    getObjectCurrency({objectAPIName:this.objectApiName,objectRecordId : this.recordId})
        .then(result => {
            if(result != null){
                this.objectCurrency=result;
            }
        })

    callGetLimit({objectAPIName : this.objectApiName,objectRecordId : this.recordId})
        .then(result => {
            if(result != null){
                this.creditInfoWrapper = result;
                
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
    
    callGetLimit({objectAPIName : this.objectApiName,objectRecordId : this.recordId})
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
        callGetLimit({objectAPIName : this.objectApiName,objectRecordId : this.recordId})
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