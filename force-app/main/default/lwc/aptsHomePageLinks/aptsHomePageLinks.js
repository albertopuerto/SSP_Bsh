import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getListViewDetail from '@salesforce/apex/APTS_ListViewIdGeneric.getListViewDetail';
import hasCustomPermission from '@salesforce/apex/EtasCoreUtils.hasCustomPermission';

export default class AptsHomePageLinks extends NavigationMixin(LightningElement) {
    @track myAgreementsList;
    @track clausesList;
    @track displayAgreementButton = false;

    get sldsColClass(){
        return this.displayAgreementButton ? 'slds-col slds-size_1-of-4' : 'slds-col slds-size_1-of-3';
    }

    checkCustomPermission() {
        hasCustomPermission({permissionName : 'CreateNewAgreement'})
        .then(result => {
            this.displayAgreementButton = result;
            console.log('agreement button', this.displayAgreementButton);
            if(!this.displayAgreementButton){
                console.log('user does not have permission CreateNewAgreement');
            }
        })
        .catch(error => {
            console.error('error checking custom permission', error);
        })
    }

    connectedCallback() {
        this.doInit();
    }

    doInit() {
        this.getListViewDetail('Apttus__APTS_Agreement__c', 'APTS_My_Agreements', 'myAgreementsList');
        this.checkCustomPermission();
    }

    getListViewDetail(objectName, viewName, compId) {
        getListViewDetail({ objectName: objectName, viewName: viewName })
            .then(result => {
                this[compId] = result;
            })
            .catch(error => {
                console.error('Error fetching list view: ', error);
            });
    }

    createWizard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/Apttus__AgreementStoreExecuted'
            }
        });
    }

    newAgreement() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/APTSMD_startWizard?type=Agreement Wizard'
            }
        });
    }
    
    gotoMyAgreements() {
         getListViewDetail({ 
            objectName: 'Apttus__APTS_Agreement__c', 
            viewName: 'APTS_My_Agreements'  // Fixed to match the view name used in doInit
        })
            .then(listViewId => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/lightning/o/Apttus__APTS_Agreement__c/list?filterName=' + listViewId
                    }
                });
            })
            .catch(error => {
                console.error('Error navigating to My Agreements: ', error);
            });
    }

    gotoMyDashBoard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/Dashboard/01Z3i000000956eEAA/view?queryScope=userFolders'
            }
        });
    }

    myQueueAgreements() {
        getListViewDetail({ 
            objectName: 'Apttus__APTS_Agreement__c', 
            viewName: 'APTS_My_Queue_Agreements' 
        })
            .then(listViewId => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/lightning/o/Apttus__APTS_Agreement__c/list?filterName=' + listViewId
                    }
                });
            })
            .catch(error => {
                console.error('Error navigating to My Queue: ', error);
            });
    }
}