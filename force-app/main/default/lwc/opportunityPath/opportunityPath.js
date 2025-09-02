import { LightningElement, track,api} from 'lwc';
import getNonClosedStatusValues from '@salesforce/apex/pathOpportunity.getNonClosedStatusValues';
import getClosedStatusValues from '@salesforce/apex/pathOpportunity.getClosedStatusValues';
import getCloseReasons from '@salesforce/apex/pathOpportunity.getCloseReasons';
import getOpportunityGuidance from '@salesforce/apex/pathOpportunity.getOpportunityGuidance';
import getOpportunityActualStage from '@salesforce/apex/pathOpportunity.getOpportunityActualStage';
import { updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName'
import LOSS_REASON from '@salesforce/schema/Opportunity.pkl_LossReason__c'
import LOSS_DESCRIPTION from '@salesforce/schema/Opportunity.txa_LossReasonDescription__c'

export default class PathOpportunity extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track showPath = true;
    @track opportunityActual;
    @track stageguidance;
        
    @track statusList=[];
    @track expandFields= true;
    @track openClosingOpportunity= false;
    @track closedStagesList=[];
    @track closeReasons= [];

    @track selectedStage;
    @track currentStage;
    @track closeLossReasonSelected;
    @track fieldList ='';

    closeLossDescription = '';
    guidancezaMap={};

    get chevronIcon(){
        return this.expandFields ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get disableChevronIcon(){
        return this.selectedStage == 'Closed';
    }

    get showStageDetails(){
        return this.selectedStage !== 'Closed' && this.expandFields;
    }

    get completeButtonText(){
        let text = 'Mark Stage as Complete';
        if(this.selectedStage == 'Closed') text = 'Select Closed Stage'
        else if(this.selectedStage == this.currentStage) text = 'Mark Stage as Complete'
        else text = 'Mark as Current Stage';
        return text;
    }

    get isSelectedCurrent(){
        return this.selectedStage === this.currentStage;
    }

    onCloseStatusSelected(event){
        this.closeLossReasonSelected = event.detail.value;
    }

    onLossDescriptionChange(event){
        this.closeLossDescription = event.detail.value;
    }

    get showCloseReason(){
        return this.closeLossReasonSelected === 'Lost';
    }

    getActualOpportunityData(){
        
        getOpportunityActualStage({opportunityId: this.recordId})
            .then(result => {

                        this.selectedStage = result;
                        this.currentStage = result;
                        this.getObjectPath();
                    
                    }).catch((error) => {
                        console.error("Error in retrieve:", error);
                });
    }

    fillPickLists(){

        getNonClosedStatusValues()
            .then(result => {
                this.statusList =[];
                for (let i = 0; i < result.length; i++) {
                    this.statusList.push({ label: result[i], value: result[i], className: '' });
                }
                this.refreshPath();
                this.refreshGuidance();
            }).catch((error) => {
                console.error("Error in retrieve:", error);
        });


        getClosedStatusValues()
                .then(result => {
                    this.closedStagesList =[];
                    this.closedStagesList =result.map((o) => ({ label: o, value: o }));
                }).catch((error) => {
                    console.error("Error in retrieve:", error);
            });

        getCloseReasons()
            .then(result => {
                this.closeReasons =result.map((o) => ({ label: o, value: o }));
            }).catch((error) => {
            
                console.error("Error in retrieve:", error);
        });
            
        }

    refreshPath(){
        const completeClass = 'slds-path__item runtime_sales_pathassistantPathAssistantTab slds-is-complete';
        const currentClass = 'slds-path__item runtime_sales_pathassistantPathAssistantTab slds-is-current slds-is-active';
        const incompleteClass = 'slds-path__item runtime_sales_pathassistantPathAssistantTab slds-is-incomplete';


        let className=completeClass;
        for (let i = 0; i < this.statusList.length; i++) {
            if (className==completeClass && this.selectedStage == this.statusList[i].value){
                className=currentClass;
            }
            else if (className==currentClass && this.selectedStage != this.statusList[i].value){
                className=incompleteClass;
            }
            this.statusList[i].className= className;
        }
    }

    connectedCallback(){
        this.getActualOpportunityData();
    }

    getObjectPath(){
        getOpportunityGuidance({opportunityId: this.recordId})
            .then(result => {
                if(result == null){
                    this.showPath= false;
                    return;
                }
                this.guidanceMap = result;
                this.fillPickLists();
        }).catch((error) => {
            console.error("Error in retrieve:", error);
        });
    }

    refreshGuidance(){
        if(this.guidanceMap && this.guidanceMap[this.selectedStage]){
            this.fieldList='';
            var fields= '';
            fields = this.guidanceMap[this.selectedStage].fieldNames.map(fieldWrapper => {
                this.fieldList += fieldWrapper + ' ';
            });


            var guidance= this.guidanceMap[this.selectedStage].info.replace('<p>','');
            guidance= guidance.replace('</p>','');
            this.stageguidance= guidance;

            this.template.querySelector('c-opportunity-path-child').getObjectFieldList();
        }               
    }

    selectStage(event) {
        const clicked = event.currentTarget.dataset.id;
        const active = 'slds-is-active';

        for (let i = 0; i < this.statusList.length; i++) {
            const s = this.statusList[i];
            if (s.value === clicked) {
                s.className = s.className + ' ' + active;

            } else {
                s.className = s.className.replace(active, '')
            }
        }
        this.selectedStage = clicked;       
        this.refreshGuidance();

        this.statusList = [...this.statusList];
    }

    async onSubmitStageClick(){
        try{
            if(this.selectedStage == 'Closed'){
                this.showCloseModal();
            }else if (this.selectedStage == this.currentStage){
                let nextStage = this.getNextStage(this.selectedStage);
                if (nextStage != 'Closed') {
                    this.updateStage(nextStage);
                }
                else if (nextStage == 'Closed') {
                    this.showCloseModal();
                }
            }
            else{
                this.updateStage(this.selectedStage);
            }
        }catch(e){            
            console.error('[UpdateOppStage] update error', e);
            this.toast('Error al actualizar Stage', this.getPrintableError(e), 'error');
        }
    }

    async updateStage(stage){
        const fields = {};
        fields[ID_FIELD.fieldApiName]   = this.recordId;
        fields[STAGE_FIELD.fieldApiName] = stage;

        try{
            await updateRecord({ fields });
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.toast('Stage updated', 'Stage updated successfully.','success');
            this.currentStage = stage;
            this.refreshPath();
        }catch(e){
            console.error('[UpdateOppStage] update error', e);
            this.toast('Error al actualizar Stage', this.getPrintableError(e), 'error');
        }
    }

    showCloseModal(){
        this.openClosingOpportunity = true;
    }

    cancelClosingOpportunity(){
        this.openClosingOpportunity = false;
    }

    saveClosingOpportunity(){
        const fields = {};
        fields[ID_FIELD.fieldApiName]   = this.recordId;
        fields[STAGE_FIELD.fieldApiName] = this.closeLossReasonSelected;
        fields[LOSS_REASON.fieldApiName] = this.closeLossReasonSelected;
        fields[LOSS_DESCRIPTION.fieldApiName] = this.closeLossDescription;

        updateRecord({ fields })
            .then(() => {
                getRecordNotifyChange([{ recordId: this.recordId }]);
                this.toast('Opportunity Closed', 'Opportunity closed successfully.','success');
                this.currentStage = this.closeLossReasonSelected;
                this.refreshPath();
                this.openClosingOpportunity= false;
                this.closeLossReasonSelected= '';
                this.closeLossDescription= '';
            }).catch((error) => {
                console.error('[CloseOpportunity] update error', error);
                this.toast('Error al cerrar oportunidad', this.getPrintableError(error), 'error');
        });
    }

    getNextStage(stage){
        const stageIndex = this.statusList.findIndex(s => s.value === stage);
        if (stageIndex !== -1 && stageIndex < this.statusList.length - 1) {
            return this.statusList[stageIndex + 1].value;
        }
        return null;
    }

    expandPath(){
        this.expandFields = !this.expandFields;
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    getPrintableError(error) {
        const fieldErrors = error?.body?.output?.fieldErrors;
        if (fieldErrors) {
            const msgs = Object.values(fieldErrors).flat().map(e => e.message).filter(Boolean);
            if (msgs.length) return msgs.join(' | ');
        }

        const recErrors = error?.body?.output?.errors;
        if (Array.isArray(recErrors) && recErrors.length) {
            const msgs = recErrors.map(e => e.message).filter(Boolean);
            if (msgs.length) return msgs.join(' | ');
        }

        return error?.body?.message || error?.message || 'Unexpected error';
    }

    stopPropagation(event) {
        event.stopPropagation();
    }
}