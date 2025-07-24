import { LightningElement, api, track } from 'lwc';
import loadOrderGroups from '@salesforce/apex/GroupLineItems_controller.loadOrderGroups';
import { getLogger } from 'c/logger';

export default class GroupLineItems extends LightningElement {
    @api recordId;
    @api ComponentTitle;
    @track orderGroups = [];
    hasError = false;
    logger;

    // Move columns definition to getter to avoid initialization issues
    get columns() {
        return [
            { 
                label: 'Group Name', 
                fieldName: 'Link', 
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'Name' },
                    target: '_blank'
                }
            },
            { label: 'Products in group', fieldName: 'itemsGroup', type: 'number' },
            { label: 'Total Price', fieldName: 'totalPrice', type: 'currency' }
        ];
    }

    connectedCallback() {
        console.log('Component connected, recordId:', this.recordId);
        
        // Initialize logger safely
        try {
            this.logger = getLogger(this);
            console.log('Logger initialized successfully');
        } catch (loggerError) {
            console.error('Failed to initialize logger:', loggerError);
            // Continue without logger rather than failing
        }

        // Validate recordId
        if (!this.recordId) {
            console.error('No recordId provided');
            this.hasError = true;
            return;
        }

        // Load order groups with comprehensive error handling
        this.loadOrderGroupsData();
    }

    loadOrderGroupsData() {
        loadOrderGroups({ quoteId: this.recordId })
            .then((result) => {
                console.log('Raw result from Apex:', result);
                
                // Defensive checks for result
                if (!result) {
                    console.warn('No result returned from Apex');
                    this.orderGroups = [];
                    this.hasError = false;
                    return;
                }

                if (!Array.isArray(result)) {
                    console.error('Result is not an array:', typeof result, result);
                    this.hasError = true;
                    return;
                }

                // Process the results safely
                try {
                    this.orderGroups = result.map((group, index) => {
                        if (!group) {
                            console.warn(`Null group found at index ${index}`);
                            return {
                                Id: `empty-${index}`,
                                Name: 'Empty Group',
                                Link: '#',
                                itemsGroup: 0,
                                totalPrice: 0
                            };
                        }
                        
                        return {
                            Id: group.Id || `group-${index}`,
                            Name: group.Name || 'Unnamed Group',
                            Link: group.SBQQ__Group__c ? '/' + group.SBQQ__Group__c : '#',
                            itemsGroup: group.itemsGroup || 0,
                            totalPrice: group.totalPrice || 0,
                            ...group // Spread the original group properties
                        };
                    });

                    this.hasError = false;
                    console.log('Processed order groups:', this.orderGroups);
                } catch (processingError) {
                    console.error('Error processing order groups:', processingError);
                    this.hasError = true;
                    this.logError('Error processing order groups data', processingError);
                }
            })
            .catch((error) => {
                console.error('Error loading order groups:', error);
                this.hasError = true;
                this.logError('Error loading order groups from Apex', error);
            });
    }

    logError(message, error) {
        try {
            if (this.logger && typeof this.logger.error === 'function') {
                this.logger.error(message)
                    .setField({ Message__c: 'FLW-SYS-00005 - ' + message })
                    .addTag('FLW-SYS');
                this.logger.saveLog();
            } else {
                console.error('Logger not available for error:', message, error);
            }
        } catch (logError) {
            console.error('Error while logging:', logError);
        }
    }
}