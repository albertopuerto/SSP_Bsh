import { LightningElement, track, api } from 'lwc';
import getMyApprovals from '@salesforce/apex/ApprovalController.getMyApprovals';
import { getLogger } from 'c/logger';

export default class MyApprovals extends LightningElement {
    @track approvals;
    @track error;
    @api logger = getLogger();

    columns = [
        {
            label: 'Name',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }
        },
        {
            label: 'Status',
            fieldName: 'sbaa__Status__c'
        },
        {
            label: 'Quote',
            fieldName: 'quoteLink',
            type: 'url',
            typeAttributes: { label: { fieldName: 'QuoteName' }, target: '_self' }
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date',
            typeAttributes: { day: 'numeric', month: 'short', year: 'numeric' }
        }
    ];

    connectedCallback() {
        this.loadApprovals();
    }

    loadApprovals() {
        getMyApprovals()
            .then(data => {
                this.approvals = data.map(row => ({
                    ...row,
                    recordLink: '/' + row.Id,
                    quoteLink: row.Quote__c ? '/' + row.Quote__c : null,
                    QuoteName: row.Quote__r ? row.Quote__r.Name : 'View Quote'
                }));
                this.logger.error('undefined').setField({ Message__c: 'FLW-PER-00001 - undefined' }).addTag('FLW-UND');
                this.logger.saveLog();
            })
            .catch(error => {
                this.logger.error('undefined').setField({ Message__c: 'FLW-PER-00001 - undefined' }).addTag('FLW-UND');
                this.logger.saveLog();
            });
    }
}