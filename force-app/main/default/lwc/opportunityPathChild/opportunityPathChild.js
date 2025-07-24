import { LightningElement,track,api } from 'lwc';
import getFieldList from '@salesforce/apex/pathOpportunityFieldManager.getFieldList';


export default class OpportunityPathChild extends LightningElement {
    
    @api oppid;
    @api fields;
    @api objecttype;
    @api guidance;

    @track fieldList;

    connectedCallback(){

        setTimeout(() => {
            this.getObjectFieldList();
        }, 1500);
   
    }

    getObjectFieldList(){

      

        getFieldList({objectStep: this.fields})
                    .then(result => {
                       alert(result);
                       this.fieldList= result;
                   
                    }).catch((error) => {
                  
                        console.error("Error in retrieve:", error);
                    });
                }
}
