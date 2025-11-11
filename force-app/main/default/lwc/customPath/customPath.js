import { LightningElement, track,api} from 'lwc';
import getContext from '@salesforce/apex/CustomPath.getContext';
import updateStage from '@salesforce/apex/CustomPath.updateStage';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ERRORTITLE = 'You encountered some errors when trying to save this record';

export default class CustomPath extends LightningElement {

    @api recordId;

    @track showPath = true;
    @track stageguidance;

    @track statusList=[];
    @track expandFields= false;
    @track openClosingFlow= false;

    @track selectedStage;
    @track currentStage;
    @track closeLossReasonSelected;
    @track fieldList
    @track tooltip = { visible: false, text: '', top: 0, left: 0, width: 100, height: 100 };



    finalStage;
    wonStages;
    closeLossReasonSelected = '';
    closeLossDescription = '';
    guidanceMap={};
    context={};
    contextLoaded= false;

    /*======================================================
                Getters            
    ========================================================*/

    get objectName(){
        return this.context ? this.context.entityName : '';
    }
    get closeReasons(){
        return this.context.lostReasons.map(reason => ({ label: reason, value: reason }));
    }

    get closedStagesList(){
        return this.context.closedStatus.map(stage => ({ label: stage, value: stage }));
    }

    get chevronIcon(){
        return this.expandFields ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get disableChevronIcon(){
        return this.selectedStage == this.finalStage;
    }

    get showStageDetails(){
        return this.selectedStage !== this.finalStage && this.expandFields;
    }

    get completeButtonText(){
        let text = 'Mark as Current Stage';
        if(this.selectedStage == this.finalStage || this.isfinalStageValue(this.selectedStage)) {
            text = 'Select Closed Stage';
        } 
        else if(this.selectedStage == this.context.currentStage) {
            text = 'Mark Stage as Complete';
        } 
        return text;
    }

    get isSelectedCurrent(){
        return this.selectedStage === this.context.currentStage;
    }

    get showCloseReason(){
        return this.closeStage === 'Lost';
    }

    get showTooltip(){
        return this.tooltip.visible;
    }

    get toolTipText(){
        return this.tooltip.text;
    }

    get tooltipStyle(){
        return `position:fixed; top: ${this.tooltip.top}px; left: ${this.tooltip.left}px; width: ${this.tooltip.width}px; height: ${this.tooltip.height}px; z-index: 1;`;
    }
    
    get flowName(){
        return this.context && this.context.closeFlow ? this.context.closeFlow : '';
    }

    get flowInputs(){
        return [
            { name: 'recordId', type: 'String', value: this.recordId },
        ];
    }

    /*======================================================
          Lifecycle hooks - connectedCallback and childs
    ========================================================*/
    connectedCallback(){
        this.initialize();
    }
    initialize(){
        if(this.recordId){
            getContext({recordId: this.recordId})
                .then(result => {
                    if(result == null){
                        this.showPath= false;
                        return;
                    }
                    this.context = result;
                    this.selectedStage = result.currentStage;
                    this.finalStage = result.finalStage;
                    this.wonStages = result.wonStages ? result.wonStages : [];
                    for (let step of result.pathAssistantSteps) {
                        this.guidanceMap[step.picklistValueName] = step;
                    }
                    this.contextLoaded= true;
                    this.statusList = this.context.nonClosedStatus.map(status => ({ label: status, value: status, className: '', title: this.getStageTitle(status) }));
                    this.statusList.push({ label: this.finalStage, value: this.finalStage, className: '' });
                    
                    this.refreshGuidance();
                    this.refreshPath();
                }).catch((error) => {
                    this.toast('Error loading context', this.getPrintableError(error), 'error');
            });
        }else{
            this.showPath= false;
        }
    }

    refreshPath(){
        const completeClass = 'slds-path__item runtime_sales_pathassistantPathAssistantTab slds-is-complete';
        const currentClass = 'slds-path__item runtime_sales_pathassistantPathAssistantTab slds-is-current slds-is-active';
        const incompleteClass = 'slds-path__item runtime_sales_pathassistantPathAssistantTab slds-is-incomplete';
        const lossClass = 'slds-is-current slds-is-lost slds-is-active slds-path__item runtime_sales_pathassistantPathAssistantTab'
        
        let className=completeClass;
        if(this.isfinalStageValue(this.context.currentStage)){
            this.statusList[this.statusList.length - 1].value = this.context.currentStage;
            this.statusList[this.statusList.length - 1].label = this.context.currentStage;
            this.statusList[this.statusList.length - 1].title = this.getStageTitle(this.context.currentStage);
            if (!this.wonStages.includes(this.context.currentStage)){
                className=incompleteClass;
            }
        };
        let currentIndex = this.statusList.findIndex(s => s.value === this.context.currentStage);
        for (let i = 0; i < this.statusList.length; i++) {
            if (className==completeClass && this.selectedStage == this.statusList[i].value){
                className=currentClass;
            }
            else if (this.isfinalStageValue(this.statusList[i].value) && !this.wonStages.includes(this.statusList[i].value)){
                className=lossClass;
            }
            else if (this.statusList.findIndex(s => s.value === this.statusList[i].value) > currentIndex){
                className=incompleteClass;
            }
            this.statusList[i].className= className;
        }    
    }

    refreshGuidance(){
        if(this.guidanceMap && this.guidanceMap[this.selectedStage]){
            var guidance= this.guidanceMap[this.selectedStage].info      
            this.fieldList= this.guidanceMap[this.selectedStage].fieldNames.join(' ');
            this.stageguidance= guidance;
            this.expandFields= true;
        }               
    }

    /*===========================
       Event Handlers for path
    ===========================*/
    expandPath(){
        this.expandFields = !this.expandFields;
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
            if(this.isfinalStageValue(this.selectedStage) || this.selectedStage == this.finalStage){
                this.showCloseModal();
            }else if (this.selectedStage == this.context.currentStage){
                let nextStage = this.getNextStage(this.selectedStage);
                if (!this.isfinalStageValue(nextStage) && nextStage != this.finalStage){
                    this.statusList[this.statusList.length -1].value = this.finalStage;
                    this.statusList[this.statusList.length -1].label = this.finalStage;
                    this.updateStage(nextStage);
                }
                else if (nextStage == this.finalStage || this.isfinalStageValue(nextStage)) {
                    this.showCloseModal();
                }
            }
            else{
                this.updateStage(this.selectedStage);
                if(this.selectedStage != this.statusList[this.statusList.length -1].value){
                    this.statusList[this.statusList.length -1].value = this.finalStage;
                    this.statusList[this.statusList.length -1].label = this.finalStage;
                }
            }
        }catch(e){            
            console.error('[UpdateOppStage] update error', e);
            this.toast(ERRORTITLE, 'Stage: ' + this.getPrintableError(e), 'error');
        }
    }

    async updateStage(stage){
        try{
            await updateStage({value: stage, recordId: this.recordId, objName: this.context.entityName, fieldName: this.context.fieldName});
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.toast('Stage updated', 'Stage updated successfully.','success');
            this.context.currentStage = stage;
            this.selectedStage = stage;
            this.refreshPath();
        }catch(e){
            console.error('[UpdateOppStage] update error', e);
            this.toast(ERRORTITLE, 'Stage: ' + this.getPrintableError(e), 'error');
        }
    }

pathStageMouseOver(event) {
    // Guarda el elemento ancla (<li>)
    this.stageTarget = event.currentTarget;

    if (!this.stageTarget) {
        return;
    }

    let text = this.stageTarget.dataset.tooltip || this.stageTarget.dataset.id || '';
    text = this.getStageTitle(text);

    // Inicializa visible, pero sin calcular posición aún
    this.tooltip = { visible: true, text, top: -9999, left: -9999 };

    // Usa requestAnimationFrame para medir después de que el DOM se actualice
    requestAnimationFrame(() => {
        if (!this.stageTarget) return; // por si ya se hizo mouseleave

        const rect = this.stageTarget.getBoundingClientRect();
        //get tooltip dimensions from DOM
        const tooltipEl = this.template.querySelector('.slds-popover_tooltip');
        if (!tooltipEl) return;

        const tooltipRect = tooltipEl.getBoundingClientRect();
        const w = Math.round(tooltipRect.width);
        const h = Math.round(tooltipRect.height);
        const GAP = 12;

        let left = rect.left + (rect.width / 2) - (w / 2);
        let top = rect.top + h + GAP;

        if (top < 8) {
            top = rect.bottom + GAP;
        }

        left = Math.max(8, Math.min(left, window.innerWidth - w - 8));

        this.tooltip = { visible: true, text, top: Math.round(top), left: Math.round(left) };
    });
}



    pathStageMouseOut(event){
        this.tooltip = { ...this.tooltip, visible: false };
    }

    /*===================================
       Event Handlers for modal fields
    ====================================*/
    onCloseStatusSelected(event){
        this.closeStage = event.detail.value;
        this.closeLossReasonSelected = '';
        this.closeLossDescription = '';
    }

    onCloseLossReasonChange(event){
        this.closeLossReasonSelected = event.detail.value;
    }

    onLossDescriptionChange(event){
        this.closeLossDescription = event.detail.value;
    }

    showCloseModal(){
        this.openClosingFlow = true;
    }

    cancelClosingFlow(){
        this.openClosingFlow = false;
    }

    getNextStage(stage){
        const stageIndex = this.statusList.findIndex(s => s.value === stage);
        if (stageIndex !== -1 && stageIndex < this.statusList.length - 1) {
            return this.statusList[stageIndex + 1].value;
        }
        return null;
    }

    handleFlowStatus(event) {
        const status = event.detail.status;
        console.log('Estado del flow:', status);

        if (status === 'FINISHED') {
            // Cierra modal o haz alguna acción
            this.openClosingFlow = false;
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.initialize();
        }
    }
    /*===================================
       Common methods
    ====================================*/
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

    isfinalStageValue(stage){
        return this.contextLoaded ? this.context.closedStatus.includes(stage) : false;
    }

    getStageTitle(stage){
        let title= stage;
        if(this.context.stageDurations && this.context.stageDurations[stage]>1){ 
            title = this.context.stageDurations[stage] + ' days in ' + stage;
        } else if (this.context.stageDurations && this.context.stageDurations[stage]==1){
            title  = this.context.stageDurations[stage] + ' day in ' + stage;
        }
        return title;
    }
}