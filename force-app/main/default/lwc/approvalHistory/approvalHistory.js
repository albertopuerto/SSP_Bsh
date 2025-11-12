import { LightningElement, track } from 'lwc';
import getUserApprovalHistory from '@salesforce/apex/ApprovalController.getMyHistoryApprovals';

export default class ApprovalHistory extends LightningElement {
    @track approvals = [];
    @track error;
    
    columns = [
        {
            label: 'Name',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_self' },
            sortable: true
        },
        {
            label: 'Approver',
            fieldName: 'ApproverName',
            type: 'text'
        },
        {
            label: 'Quote',
            fieldName: 'QuoteName',
            type: 'text'
        },
        {
            label: 'Status',
            fieldName: 'sbaa__Status__c',
            type: 'text'
        },
        {
            label: 'Last Modified',
            fieldName: 'LastModifiedDate',
            type: 'date',
            sortable: true
        }
    ];

    connectedCallback() {
        this.loadApprovalHistory();
    }

    loadApprovalHistory() {
        getUserApprovalHistory()
            .then(data => {
                this.approvals = data.map(row => ({
                    ...row,
                    recordLink: '/' + row.Id,
                    ApproverName: row.sbaa__ApprovedBy__r?.Name || row.sbaa__RejectedBy__r?.Name || '—',
                    QuoteName: row.Quote__r?.Name || ''
                }));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.approvals = [];
            });
    }
}