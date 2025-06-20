// flowModal.js
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FlowModal extends NavigationMixin(LightningElement) {
    isModalOpen = true; // Opens automatically
    flowApiName = 'flw_OnboardButton_OnboardAccount'; // Replace with your flow API name    

    closeModal() {
        this.isModalOpen = false;
        this.navigateToAccountListView();
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.closeModal();
            this.navigateToAccountListView();
        }
    }

    // Navigate to Account List View
    navigateToAccountListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            },
            state: {
                filterName: '_Recent' // Optional: specify list view
            }
        });
    }
}