import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getListViewDetail from '@salesforce/apex/APTS_ListViewIdGeneric.getListViewDetail';
import hasCustomPermission from '@salesforce/apex/EtasCoreUtils.hasCustomPermission';
import { getLogger } from 'c/logger';
import MyAgreements from '@salesforce/label/c.MyAgreements';
import MyQueue from '@salesforce/label/c.MyQueue';
import NewAgreement from '@salesforce/label/Apttus.NewAgreement';
import StoreExecutedAgreement from '@salesforce/label/Apttus.StoreExecutedAgreement';

export default class AptsHomePageLinks extends NavigationMixin(LightningElement) {
    @track myAgreementsList;
    @track clausesList;
    @track displayAgreementButton = false;
    @api logger = getLogger();

    label = {
        MyAgreements: MyAgreements,
        MyQueue: MyQueue,
        NewAgreement,
        StoreExecutedAgreement
    };

    get sldsColClass(){
        return this.displayAgreementButton ? 'slds-col slds-size_1-of-4' : 'slds-col slds-size_1-of-3';
    }

    checkCustomPermission() {
        hasCustomPermission({permissionName : 'CreateNewAgreement'})
        .then(result => {
            this.displayAgreementButton = result;
            console.log('agreement button', this.displayAgreementButton);
            if(!this.displayAgreementButton){
                this.logger.error('hasCustomPermission').setField({ Message__c: 'FLW-PER-00001 - user does not have permission CreateNewAgreement' }).addTag('FLW-PER');
                this.logger.saveLog();
            }
        })
        .catch(error => {
            this.logger.error('system Error').setField({ Message__c: 'FLW-SYS-00001 - error checking custom permission' }).addTag('FLW-SYS');
            this.logger.saveLog();
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
                this.logger.error('system Error').setField({ Message__c: 'FLW-SYS-00002 - Error fetching list view' }).addTag('FLW-SYS');
                this.logger.saveLog();
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
                this.logger.error('system Error').setField({ Message__c: 'FLW-SYS-00003 - Error navigating to My Agreements' }).addTag('FLW-SYS');
                this.logger.saveLog();
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
                this.logger.error('system Error').setField({ Message__c: 'FLW-SYS-00004 - Error navigating to My Queue' }).addTag('FLW-SYS');
                this.logger.saveLog();
            });
    }
}