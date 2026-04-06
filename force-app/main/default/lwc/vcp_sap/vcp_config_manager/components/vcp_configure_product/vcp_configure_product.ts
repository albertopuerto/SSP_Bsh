import { ConfigStore, Logger, TranslationService } from '../../utils';
import { LightningElement, api } from 'lwc';

/**
 * Configure Product Component (Step 2)
 *
 * Runtime configuration editor for SAP VC characteristics.
 * Supports language switching, field visibility, grouping modes, and PATCH generation.
 */
export default class VcpConfigureProduct extends LightningElement {
  // Controls
  visibilityMode: 'all' | 'editable' | 'grouped' = 'all';
  groupingMode: 'flat' | 'byCharacteristics' | 'byValue' = 'flat';
  eTag = '';
  eTagVersion = 0;

  // State
  configuration: object | null = null;
  characteristics: object[] = [];
  isLoading = false;
  error: string | null = null;
  patchJson: object | null = null;

  connectedCallback() {
    Logger.info('Configure Product (Step 2) initialized');

    // Subscribe to state changes
    ConfigStore.subscribe((state) => {
      this.configuration = state.configuration;
      this.eTag = state.eTag || '';
      this.eTagVersion = state.eTagVersion || 0;
    });

    // Subscribe to language changes
    TranslationService.onLanguageChange((lang) => {
      Logger.info('Language changed in Step 2', { language: lang });
    });
  }

  /**
   * Handle configuration submit (PATCH)
   */
  async handlePatch() {
    if (!this.eTag.trim()) {
      this.error = 'ETag is required for PATCH operation';
      return;
    }

    this.isLoading = true;
    this.error = null;

    try {
      Logger.startActivity('patch-config', 'PATCH Configuration');

      // TODO: Generate PATCH request and call Apex

      Logger.completeActivity('patch-config');
    } catch (error: any) {
      const errorMsg = error?.message || String(error);
      this.error = errorMsg;
      Logger.failActivity('patch-config', errorMsg);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Handle reset to Step 1
   */
  handleReset() {
    if (!confirm('Reset to Step 1?')) return;

    Logger.info('Resetting to Step 1');
    this.dispatchEvent(
      new CustomEvent('reset', {
        bubbles: true,
        composed: true
      })
    );
  }

  /**
   * Handle control changes
   */
  handleVisibilityModeChange(event: any) {
    this.visibilityMode = event.target.value;
    ConfigStore.setState({ visibilityMode: this.visibilityMode });
  }

  handleGroupingModeChange(event: any) {
    this.groupingMode = event.target.value;
    ConfigStore.setState({ groupingMode: this.groupingMode });
  }

  handleETagChange(event: any) {
    this.eTag = event.target.value;
    ConfigStore.setState({ eTag: this.eTag });
  }

  handleETagVersionChange(event: any) {
    this.eTagVersion = parseInt(event.target.value, 10);
    ConfigStore.setState({ eTagVersion: this.eTagVersion });
  }
}
