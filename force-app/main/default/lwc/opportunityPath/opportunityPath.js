import { LightningElement, track} from 'lwc';
import getNonClosedStatusValues from '@salesforce/apex/pathOpportunity.getNonClosedStatusValues';
import getClosedStatusValues from '@salesforce/apex/pathOpportunity.getClosedStatusValues';
import getCloseReasons from '@salesforce/apex/pathOpportunity.getCloseReasons';
import getOpportunityFields from '@salesforce/apex/pathOpportunity.getOpportunityFields';
export default class PathOpportunity extends LightningElement {
@track statusList=[];
@track expandFields= false;
@track openClosingOpportunity= false;
@track closedStagesList=[];
@track showCloseReason= false;
@track closeReasons= [];

@track selectedStage;
@track closeReasonSelected;
@track selectedDescription;

fillPickLists(){
        getNonClosedStatusValues()
                .then(result => {
                    this.statusList =result.map((o) => ({ label: o, value: o }));
                   
                   // alert('test' + JSON.stringify(this.statusList));
                }).catch((error) => {
                    console.error("Error in retrieve:", error);
            });

        getClosedStatusValues()
                .then(result => {
                    this.closedStagesList =result.map((o) => ({ label: o, value: o }));
                   
                   // alert('test' + JSON.stringify(this.statusList));
                }).catch((error) => {
                    console.error("Error in retrieve:", error);
            });

            getCloseReasons()
                .then(result => {
                    this.closeReasons =result.map((o) => ({ label: o, value: o }));
                   
                   // alert('test' + JSON.stringify(this.statusList));
                }).catch((error) => {
                    console.error("Error in retrieve:", error);
            });
      }


connectedCallback(){
    this.fillPickLists();

}

selectStage(event){

    const stage = event.currentTarget;
    stage.classList.add('slds-is-active');
    stage.classList.add('slds-is-current');
    stage.classList.add('slds-path__nav');
    //console.log(stage);
    var stageName = event.currentTarget.dataset.id;

    if(stageName == 'Sales Chance (New)' || stageName == 'Acquisition (Sell)' || stageName == 'Quotation (Quoted)' || stageName == 'Accepted'){

        getOpportunityFields()
            .then(result => {
                    this.closeReasons =result.map((o) => ({ label: o, value: o }));
                   
                   // alert('test' + JSON.stringify(this.statusList));
                }).catch((error) => {
                    console.error("Error in retrieve:", error);
                    });

        this.openClosingOpportunity= false;
    }else{
        this.openClosingOpportunity= true;
    }

    
           // const tHeadElements = this.template.querySelectorAll('thead');
          //  const HeadElements = this.template.querySelectorAll('head');
        //    HeadElements.forEach(thead => {
         //   thead.classList.add('slds-is-fixed');
       // })
          //  tHeadElements.forEach(thead => {
         //   thead.classList.add('slds-is-fixed');
       // })
//if StageName == 'Sales Chance (New)' ||StageName == 'Aquisition (New)'

}/////

onCloseStatusSelected(){
    this.showCloseReason= true;
}




}