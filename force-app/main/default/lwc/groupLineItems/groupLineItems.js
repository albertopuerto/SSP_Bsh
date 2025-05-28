import { LightningElement, api, track } from 'lwc';
import loadOrderGroups from '@salesforce/apex/GroupLineItems_controller.loadOrderGroups';
import { getLogger } from 'c/logger';
export default class GroupLineItems extends LightningElement {
    @api recordId;
    @api ComponentTitle;
    @track orderGroups = [];
    hasError = false;
    columns = [
        { label: 'Group Name', fieldName: 'Link', type: 'url' ,
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_blank'
            }},
        { label: 'Products in group', fieldName: 'itemsGroup', type: 'number' },
        { label: 'Total Price', fieldName: 'totalPrice', type: 'currency' }
    ];
    connectedCallback() {
        loadOrderGroups({ quoteId: this.recordId })
            .then((result) => {
                this.orderGroups = result.map((group) => {
                    return {
                        ...group,
                        Link: '/' + group.SBQQ__Group__c,
                    };
                });
                this.hasError = false;
                console.log('Order groups:', result);
            })
            .catch((error) => {
                this.logger.error('system Error').setField({ Message__c: 'FLW-SYS-00005 - Error loading order groups' }).addTag('FLW-SYS');
                this.logger.saveLog();
                this.hasError = true;
            });
    }
}