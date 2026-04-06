import { ConfigStore, Logger } from '../../utils';
import { LightningElement, api } from 'lwc';

/**
 * Create Configuration Component (Step 1)
 *
 * Handles initial SAP VC configuration creation.
 * Collects KB ID, Product Key, Quote ID and creates a new configuration request.
 */
export default class VcpCreateConfig extends LightningElement {
  @api quoteId: string | null = null;

  // Form inputs
  kbId = '';
  productKey = '';
  mode = 'F00K001001';
  autoCleanup = false;
  date = new Date().toISOString().split('T')[0];

  // State
  isLoading = false;
  error: string | null = null;
  requestJson: object | null = null;
  responseJson: object | null = null;

  connectedCallback() {
    Logger.info('Create Config (Step 1) initialized');
  }

  /**
   * Handle form submission
   */
  async handleCreateConfig() {
    if (!this.validateForm()) return;

    this.isLoading = true;
    this.error = null;

    try {
      Logger.startActivity('create-config', 'Create Configuration V2');

      // TODO: Build request and call Apex
      // const response = await ApexService.executeApex(...)

      Logger.completeActivity('create-config', { configId: 'temp-config-id' });

      // Dispatch completion event
      this.dispatchEvent(
        new CustomEvent('complete', {
          detail: { configId: 'temp-config-id' },
          bubbles: true,
          composed: true
        })
      );
    } catch (error: any) {
      const errorMsg = error?.message || String(error);
      this.error = errorMsg;
      Logger.failActivity('create-config', errorMsg);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Validate form inputs
   */
  validateForm(): boolean {
    if (!this.kbId.trim()) {
      this.error = 'KB ID is required';
      return false;
    }
    if (!this.productKey.trim()) {
      this.error = 'Product Key is required';
      return false;
    }
    return true;
  }

  /**
   * Handle input changes
   */
  handleKbIdChange(event: any) {
    this.kbId = event.target.value;
  }

  handleProductKeyChange(event: any) {
    this.productKey = event.target.value;
  }

  handleModeChange(event: any) {
    this.mode = event.target.value;
  }

  handleAutoCleanupChange(event: any) {
    this.autoCleanup = event.target.checked;
  }

  handleDateChange(event: any) {
    this.date = event.target.value;
  }
}
