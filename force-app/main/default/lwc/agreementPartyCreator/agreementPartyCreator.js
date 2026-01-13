import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import { LightningElement, api, track } from 'lwc';
import getRolePicklistValues from '@salesforce/apex/AgreementPartyController.getRolePicklistValues';
import getSignatureTypeValues from '@salesforce/apex/AgreementPartyController.getSignatureTypeValues';
import createAgreementParties from '@salesforce/apex/AgreementPartyController.createAgreementParties';


let rowCounter = 0;

export default class AgreementPartyCreator extends NavigationMixin(LightningElement) {
    @api recordId; // Agreement Id
    @track rows = [];
    @track roleOptions = [];
    @track typeOptions = [];
    @track showBanner = true;

    connectedCallback() {
        this.addRow();
        getRolePicklistValues().then(data => {
            this.roleOptions = data.map(role => ({ label: role, value: role }));
        });
        getSignatureTypeValues().then(data => {
            this.typeOptions = data.map(type => ({ label: type, value: type }));
        });       
    }

    addRow() {
        this.rows = [...this.rows, {
            id: `row-${rowCounter++}`,
            pkl_PartyRole__c: '',
            lkp_AgreementParty__c: null
        }];
    }

    removeRow(event) {
        const rowId = event.target.dataset.id;
        this.rows = this.rows.filter(r => r.id !== rowId);
    }

    handleRoleChange(event) {
        const rowId = event.target.dataset.id;
        const row = this.rows.find(r => r.id === rowId);
        if (row) row.pkl_PartyRole__c = event.detail.value;
    }

    handleTypeChange(event) {
        const rowId = event.target.dataset.id;
        const row = this.rows.find(r => r.id === rowId);
        if (row) row.pkl_MultyPartySignatureType__c = event.detail.value;
    }    

    handleAccountChange(event) {
        const rowId = event.detail.index;
        const row = this.rows.find(r => r.id === rowId);        
        if (row) row.lkp_AgreementParty__c = event.detail.accountId[0];        
    }

    handleContactChange(event) {
        const rowId = event.detail.index;
        const row = this.rows.find(r => r.id === rowId);        
        if (row) row.lkp_MultiPartySignedBy__c = event.detail.contactId[0];        
    }

    handleDateChange(event) {
        const rowId = event.currentTarget.dataset.id;        
        const row = this.rows.find(r => r.id === rowId);        
        if (row) row.dat_MultyPartySignedDate__c = event.detail.value;        
    }

    

    async handleSave() {
        const payload = this.rows.map(row => ({
            mdr_Agreement__c : this.recordId,
            pkl_PartyRole__c : row.pkl_PartyRole__c,
            lkp_AgreementParty__c : row.lkp_AgreementParty__c,
            lkp_MultiPartySignedBy__c : row.lkp_MultiPartySignedBy__c,
            pkl_MultyPartySignatureType__c : row.pkl_MultyPartySignatureType__c,
            dat_MultyPartySignedDate__c : row.dat_MultyPartySignedDate__c

        }));        
    try {
        const success = await createAgreementParties({ parties: payload });                
        console.log('BOOLEAN: '+success);
        this.dispatchEvent(new ShowToastEvent({

        title: success ? 'Success' : 'Error',
        message: success 
            ? 'Agreement Parties created successfully' 
            : 'Unable to save Agreement Parties. Please check required fields.',
        variant: success ? 'success' : 'error'

        }));
        if (success){
            this.showBanner = false;
            this.rows = [];
            this.addRow();            
        }

    } catch (error) {
        console.error('Unexpected error creating records:', error);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.body?.message || error.message || 'Unexpected failure',
            variant: 'error'
        }));
    }
    }

}