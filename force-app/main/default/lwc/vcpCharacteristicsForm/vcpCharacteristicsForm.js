import { LightningElement, api } from 'lwc';

export default class VcpCharacteristicsForm extends LightningElement {
    @api characteristics = [];
    @api visibilityMode = 'visible';
    @api labelMode = 'api';


    get filteredCharacteristics() {
        if (!Array.isArray(this.characteristics)) {
            return [];
        }
        if (this.visibilityMode === 'visible') {
            return this.characteristics.filter((c) => c.visible);
        }
        return this.characteristics;
    }

    get hasCharacteristics() {
        return this.filteredCharacteristics.length > 0;
    }

    handleChange(event) {
        const charId = event.target.dataset.charId;
        const newValue = event.detail.value;
        this.dispatchEvent(
            new CustomEvent('characteristicchange', {
                detail: { charId, newValue }
            })
        );
    }
}
