import { LightningElement, api } from 'lwc';
export default class ContactLookup extends LightningElement {

    @api index;

    handleChange(event) {
        const contactId = event.detail.value; // this is the actual Account Id
        this.dispatchEvent(new CustomEvent('contactchange', {
            detail: { contactId, index: this.index }
        }));
    }
}