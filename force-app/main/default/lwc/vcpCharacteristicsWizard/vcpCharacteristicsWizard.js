import { LightningElement, api } from 'lwc';

export default class VcpCharacteristicsWizard extends LightningElement {
    @api characteristics = [];
    @api visibilityMode = 'visible';
    @api labelMode = 'api';

    currentStep = 0;
    pendingCharId = null;
    pendingValue = null;

    get steps() {
        if (!Array.isArray(this.characteristics)) {
            return [];
        }
        if (this.visibilityMode === 'visible') {
            return this.characteristics.filter((c) => c.visible);
        }
        return this.characteristics;
    }

    get currentCharacteristic() {
        return this.steps[this.currentStep] || null;
    }

    get isFirstStep() {
        return this.currentStep === 0;
    }

    get isLastStep() {
        return this.steps.length > 0 && this.currentStep === this.steps.length - 1;
    }

    get stepIndicator() {
        return `${this.currentStep + 1} / ${this.steps.length}`;
    }

    get progressPercent() {
        if (this.steps.length === 0) return 0;
        return Math.round(((this.currentStep + 1) / this.steps.length) * 100);
    }

    get hasSteps() {
        return this.steps.length > 0;
    }

    handleChange(event) {
        this.pendingCharId = this.currentCharacteristic?.id || null;
        this.pendingValue = event.detail.value;
    }

    handleNext() {
        this._emitPendingChange();
        if (!this.isLastStep) {
            this.currentStep += 1;
            this._clearPending();
        }
    }

    handleFinish() {
        this._emitPendingChange();
        this._clearPending();
        this.dispatchEvent(new CustomEvent('wizardfinish'));
    }

    handlePrevious() {
        this._clearPending();
        if (this.currentStep > 0) {
            this.currentStep -= 1;
        }
    }

    _emitPendingChange() {
        if (this.pendingCharId && this.pendingValue !== null) {
            this.dispatchEvent(
                new CustomEvent('characteristicchange', {
                    detail: { charId: this.pendingCharId, newValue: this.pendingValue }
                })
            );
        }
    }

    _clearPending() {
        this.pendingCharId = null;
        this.pendingValue = null;
    }
}
