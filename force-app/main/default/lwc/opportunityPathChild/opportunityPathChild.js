import { LightningElement,track,api } from 'lwc';
import getObjectRecordTypes from '@salesforce/apex/pathOpportunityFieldManager.getObjectRecordTypes';


export default class OpportunityPathChild extends LightningElement {
    
    @api oppid;
    @api fields;

    connectedCallback(){

        setTimeout(()=>{
            this.getFieldTypes();
        },5000)


    }

    getFieldTypes(){

        getObjectRecordTypes({objectStep: this.fields})
                    .then(result => {
                       alert(this.fields);
                   
                    }).catch((error) => {
                  
                        console.error("Error in retrieve:", error);
                    });
                }
}
