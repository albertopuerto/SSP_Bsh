import { LightningElement, api } from 'lwc';

export default class AccountLookup extends LightningElement {
    @api index;

    handleChange(event) {
        const accountId = event.detail.value; // this is the actual Account Id
        this.dispatchEvent(new CustomEvent('accountchange', {
            detail: { accountId, index: this.index }
        }));
    }
}