import { LightningElement, track,api} from 'lwc';
import getNonClosedStatusValues from '@salesforce/apex/pathOpportunity.getNonClosedStatusValues';
import getClosedStatusValues from '@salesforce/apex/pathOpportunity.getClosedStatusValues';
import getCloseReasons from '@salesforce/apex/pathOpportunity.getCloseReasons';
import getOpportunityFields from '@salesforce/apex/pathOpportunity.getOpportunityFields';
import getOpportunityActualStage from '@salesforce/apex/pathOpportunity.getOpportunityActualStage';

export default class PathOpportunity extends LightningElement {

@api recordId;
@api objectApiName;

@track actualStep;
@track opportunityActual;
@track stageguidance;
    
@track statusList=[];
@track expandFields= false;
@track openClosingOpportunity= false;
@track closedStagesList=[];
@track showCloseReason= false;
@track closeReasons= [];

@track selectedStage;
@track closeReasonSelected;
@track selectedDescription;
@track fieldList ='';

getActualOpportunityData(){
    
    getOpportunityActualStage({opportunityId: this.recordId})
    
        .then(result => {

                    this.selectedStage = result;
                    this.getObjectPath();
                   
                }).catch((error) => {
                    console.error("Error in retrieve:", error);
            });
}

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
    this.getActualOpportunityData();

}
getObjectPath(){

    getOpportunityFields({opportunityId: this.recordId,newStage: this.selectedStage})
            .then(result => {
              //  this.actualStep=JSON.stringify(result);
                this.fieldList='';

                var fields= '';
                fields = result.fieldNames.map(fieldWrapper => {
                    this.fieldList += fieldWrapper + ' ';
                });


                var guidance= result.info.replace('<p>','');
                guidance= guidance.replace('</p>','');
                this.stageguidance= guidance;

                this.template.querySelector('c-opportunity-path-child').getObjectFieldList();
               
                }).catch((error) => {
                    console.error("Error in retrieve:", error);
                    alert(error);
                    });

    
}


selectStage(event){

    const stage = event.currentTarget;
    stage.classList.add('slds-is-active');
    stage.classList.add('slds-is-current');
    stage.classList.add('slds-path__nav');
    //console.log(stage);
    this.selectedStage = event.currentTarget.dataset.id;

    if(this.selectedStage == 'Sales Chance (New)' || this.selectedStage == 'Acquisition (Sell)' || this.selectedStage == 'Quotation (Quoted)' || this.selectedStage == 'Accepted'){

        
        this.getObjectPath();

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