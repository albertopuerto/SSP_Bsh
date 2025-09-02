import { LightningElement,track,api } from 'lwc';
import getFieldList from '@salesforce/apex/pathOpportunityFieldManager.getFieldList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityPathChild extends LightningElement {
    
    @api oppid;
    @api fields;
    @api objecttype;
    @api guidance;

    @track isModeEdition = false;
    
    fieldList =[];
    
    connectedCallback() {
        this.loadFields();
    }

    loadFields() {
    getFieldList({ objectStep: this.fields })
        .then(result => { this.fieldList = result; })
        .catch(error => { console.error('Error in retrieve:', error); });
    }
    
    enableEdition(event){
        this.isModeEdition= true;
    }

    handleSubmit(event) {
        alert('entro ' + this.fieldList);

        event.preventDefault(); // stop the form from submitting

        const fields = event.detail.fields;
       
        this.template.querySelector('lightning-record-form').submit(fields);
        
    }
     handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'The record has been modified succesfully',
            message: 'The record has been modified succesfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.isModeEdition= false;
    }
}
