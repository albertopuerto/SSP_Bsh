import { LightningElement, api } from 'lwc';

export default class VcpCharacteristicsGroupTabs extends LightningElement {
    @api groups = []; // [{key, groupId, groupLabel, characteristics[]}]
    @api visibilityMode = 'visible';
    @api labelMode = 'api';

    get hasGroups() {
        return Array.isArray(this.groups) && this.groups.length > 0;
    }

    handleCharacteristicChange(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent('characteristicchange', {
                detail: event.detail
            })
        );
    }
}
