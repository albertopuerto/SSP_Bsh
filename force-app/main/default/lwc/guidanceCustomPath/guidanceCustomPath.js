import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GuidanceCustomPath extends LightningElement {

    @api recordid;
    @api objectname;
    
    @track isModeEdition = false;
    
    _guidance;
    fieldList;
    _fields;

    @api
    get guidance() {
        return this._guidance;
    }
    set guidance(value) {
        this._guidance = value;
        this.updateGuidanceHtml();
    }

    @api
    set fields(value) {
        this._fields = value;
        this.fieldList = value ? value.split(' ') : [];
    }

    get fields() {
        return this._fields;
    }

    updateGuidanceHtml() {
        const container = this.template.querySelector('.guidance-container');
        if (container && this._guidance) {
            container.innerHTML = this._guidance;
        }
    }
    
    
    connectedCallback() {
        this.updateGuidanceHtml();
    }
    
    renderedCallback(){
        this.updateGuidanceHtml();
    }

   
    enableEdition(event){
        this.isModeEdition= true;
    }

    handleSubmit(event) {
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
    handleCancel(event) {
        this.isModeEdition= false;
    }

    cancelEdit(event){
        this.isModeEdition= false;
    }

    stopPropagation(event) {
        event.stopPropagation();
    }
}
