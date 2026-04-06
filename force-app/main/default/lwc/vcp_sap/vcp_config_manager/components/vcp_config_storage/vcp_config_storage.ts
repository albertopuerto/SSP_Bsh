import { ApexService, Logger } from '../../utils';
import { LightningElement, api } from 'lwc';

/**
 * Configuration Storage Component
 *
 * Handles loading, saving, and clearing SAP VC configuration from Quote custom field.
 */
export default class VcpConfigStorage extends LightningElement {
  @api quoteId: string | null = null;

  storedConfigId: string | null = null;
  isLoading = false;
  error: string | null = null;

  connectedCallback() {
    Logger.info('Config Storage initialized', { quoteId: this.quoteId });
    if (this.quoteId) {
      this.loadStoredConfig();
    }
  }

  /**
   * Load stored configuration from quote
   */
  async loadStoredConfig() {
    this.isLoading = true;
    this.error = null;

    try {
      Logger.startActivity('load-stored-config', 'Load Stored Configuration');

      // TODO: Implement Apex call to load config ID from quote
      const response = await ApexService.executeApex('CPQExternalConfiguratorController', 'getStoredConfigId', {
        params: { quoteId: this.quoteId }
      });

      if (response.success) {
        this.storedConfigId = response.data;
        Logger.completeActivity('load-stored-config', { configId: this.storedConfigId });

        this.dispatchEvent(
          new CustomEvent('loaded', {
            detail: { configId: this.storedConfigId },
            bubbles: true,
            composed: true
          })
        );
      } else {
        throw new Error(response.error || 'Failed to load stored configuration');
      }
    } catch (error: any) {
      const errorMsg = error?.message || String(error);
      this.error = errorMsg;
      Logger.failActivity('load-stored-config', errorMsg);

      this.dispatchEvent(
        new CustomEvent('error', {
          detail: { error: errorMsg },
          bubbles: true,
          composed: true
        })
      );
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Clear stored configuration
   */
  async clearConfig() {
    if (!confirm('Clear stored configuration?')) return;

    this.isLoading = true;
    this.error = null;

    try {
      Logger.startActivity('clear-config', 'Clear Configuration');

      // TODO: Implement Apex call to clear config ID from quote
      const response = await ApexService.executeApex('CPQExternalConfiguratorController', 'clearConfigId', {
        params: { quoteId: this.quoteId }
      });

      if (response.success) {
        this.storedConfigId = null;
        Logger.completeActivity('clear-config');
      } else {
        throw new Error(response.error || 'Failed to clear configuration');
      }
    } catch (error: any) {
      const errorMsg = error?.message || String(error);
      this.error = errorMsg;
      Logger.failActivity('clear-config', errorMsg);
    } finally {
      this.isLoading = false;
    }
  }
}
