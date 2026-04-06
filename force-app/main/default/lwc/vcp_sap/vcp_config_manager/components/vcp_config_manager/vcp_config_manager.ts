import { ConfigStore, Logger } from '../../utils';
import { LightningElement, api } from 'lwc';

const DEMO_CONTEXT = {
  productCode: 'F-00K-115-059',
  quoteLineId: '-',
  productId: '01tbY000006KA6MQAW',
  quoteId: 'a3vbY000007ZezRQAS'
} as const;

/**
 * VCP Config Manager - Main Container Component
 *
 * Orchestrates the complete E2E testing interface for SAP Variant Configuration.
 * Manages visibility between Step 1 (Create Configuration) and Step 2 (Configure Product).
 */
export default class VcpConfigManager extends LightningElement {
  @api quoteId: string | null = null;
  @api productCode: string | null = null;
  @api productId: string | null = null;
  @api quoteLineId: string | null = null;

  // State trackers
  step1Visible = true;
  step2Visible = false;
  configStorageVisible = true;
  isLoading = false;
  error: string | null = null;

  connectedCallback() {
    this.applyDemoDefaults();

    Logger.info('VCP Config Manager initialized', {
      quoteId: this.quoteId,
      productCode: this.productCode,
      productId: this.productId,
      quoteLineId: this.quoteLineId
    });

    // Store product context in state
    ConfigStore.setState({
      quoteId: this.quoteId,
      productId: this.productId,
      quoteLineId: this.quoteLineId,
      productKey: this.productCode
    });

    // Subscribe to state changes
    const unsubscribe = ConfigStore.subscribe((state) => {
      this.step1Visible = state.step1Visible;
      this.step2Visible = state.step2Visible;
      this.configStorageVisible = state.configStorageVisible;
      this.isLoading = state.isLoading;
      this.error = state.error;
    });

    // Cleanup on disconnect
    this.initializedCleanup = unsubscribe;
  }

  disconnectedCallback() {
    if (this.initializedCleanup) {
      this.initializedCleanup();
    }
  }

  private initializedCleanup?: () => void;

  private applyDemoDefaults() {
    const missingContext = !this.quoteId && !this.productCode && !this.productId && !this.quoteLineId;

    if (!missingContext) {
      return;
    }

    this.quoteId = DEMO_CONTEXT.quoteId;
    this.productCode = DEMO_CONTEXT.productCode;
    this.productId = DEMO_CONTEXT.productId;
    this.quoteLineId = DEMO_CONTEXT.quoteLineId;

    Logger.info('Using demo Quick Action defaults', {
      quoteId: this.quoteId,
      productCode: this.productCode,
      productId: this.productId,
      quoteLineId: this.quoteLineId
    });
  }

  /**
   * Handle Step 1 completion - show Step 2, hide Step 1
   */
  handleStep1Complete() {
    Logger.info('Step 1 completed, showing Step 2');
    ConfigStore.setState({
      step1Visible: false,
      step2Visible: true,
      configStorageVisible: false
    });
  }

  /**
   * Handle Step 2 complete - return to Step 1
   */
  handleStep2Reset() {
    Logger.info('Step 2 reset, returning to Step 1');
    ConfigStore.setState({
      step1Visible: true,
      step2Visible: false,
      configStorageVisible: true
    });
  }

  /**
   * Handle global error
   */
  handleError(event: any) {
    const error = event.detail?.error || 'Unknown error';
    Logger.error('Global error:', { error });
    ConfigStore.setState({ error });
  }
}
