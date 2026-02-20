import { LightningElement, api,wire } from 'lwc';
import hasSubsProducts from '@salesforce/apex/CreditLimitApprovalController.hasSubsProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CreditLimitApproval extends NavigationMixin(LightningElement) {

    @api recordId;
    showSpinner = true;
    showError = false;

    approvalCheck(){

        hasSubsProducts({quoteId : this.recordId})

        .then(result => {

            if(result === true){
                this.handleError(); 
            }
            else{
                this.openSubmitForApproval();
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