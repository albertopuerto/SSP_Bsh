import { LightningElement, api, track } from 'lwc';
import loadOrderItems from '@salesforce/apex/GroupLineItems_controller.loadOrderItems';
import { getLogger } from 'c/logger';
export default class LineItemsInGroup extends LightningElement {
    @api recordId;
    @api ComponentTitle;
    @track orderGroups = [];
    hasError = false;
    columns = [
        { label: 'Product Name', fieldName: 'Link', type: 'url' ,
            typeAttributes: {
                label: { fieldName: 'productName' },
                target: '_self'
            }},
            { label: 'Product Code', fieldName: 'ftxt_ProductCode__c', type: 'string' },
            { label: 'Total Price', fieldName: 'TotalPrice', type: 'currency' }
    ];
    connectedCallback() {
        loadOrderItems({ groupId: this.recordId })
            .then((result) => {
                this.orderGroups = result.map((order) => {
                    return {
                        ...order,
                        Link: '/' + order.Id,
                        productName: order.Product2.Name
                    };
                });
                this.ComponentTitle = this.ComponentTitle + ' (' + this.orderGroups.length + ')';
                this.hasError = false;
                console.log('Order groups:', result);
            })
            .catch((error) => {
                this.logger.error('system Error').setField({ Message__c: 'FLW-SYS-00006 - Error loading order Items' }).addTag('FLW-SYS');
                this.logger.saveLog();
                this.hasError = true;
            });
    }
}