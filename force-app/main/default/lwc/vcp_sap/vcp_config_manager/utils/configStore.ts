/**
 * Configuration Store
 *
 * Centralized state management for VCP configuration lifecycle.
 * Uses a simple event-emitter pattern for state updates.
 */

export interface ConfigurationState {
  // Configuration Metadata
  configId: string | null;
  quoteId: string | null;
  productId: string | null;
  quoteLineId: string | null;
  kbId: string | null;
  productKey: string | null;
  mode: string | null;

  // Configuration Data
  configuration: Record<string, any> | null;
  characteristics: Record<string, any>[] | null;
  eTag: string | null;
  eTagVersion: number;

  // Runtime State
  currentLanguage: 'api' | 'en' | 'es' | 'de';
  translations: Record<string, Record<string, string>>;
  isLoading: boolean;
  error: string | null;
  lastUpdated: number | null;

  // UI State
  step1Visible: boolean;
  step2Visible: boolean;
  configStorageVisible: boolean;
  visibilityMode: 'all' | 'editable' | 'grouped';
  groupingMode: 'flat' | 'byCharacteristics' | 'byValue';
}

type StateListener = (state: ConfigurationState) => void;

const initialState: ConfigurationState = {
  configId: null,
  quoteId: null,
  productId: null,
  quoteLineId: null,
  kbId: null,
  productKey: null,
  mode: null,
  configuration: null,
  characteristics: null,
  eTag: null,
  eTagVersion: 0,
  currentLanguage: 'api',
  translations: {},
  isLoading: false,
  error: null,
  lastUpdated: null,
  step1Visible: true,
  step2Visible: false,
  configStorageVisible: true,
  visibilityMode: 'all',
  groupingMode: 'flat'
};

export class ConfigStore {
  private static state: ConfigurationState = { ...initialState };
  private static listeners: StateListener[] = [];

  /**
   * Get current state snapshot
   */
  static getState(): ConfigurationState {
    return { ...this.state };
  }

  /**
   * Update partial state
   */
  static setState(updates: Partial<ConfigurationState>): void {
    this.state = { ...this.state, ...updates };
    this.notifyListeners();
  }

  /**
   * Subscribe to state changes
   */
  static subscribe(listener: StateListener): () => void {
    this.listeners.push(listener);

    // Return unsubscribe function
    return () => {
      this.listeners = this.listeners.filter((registeredListener) => registeredListener !== listener);
    };
  }

  /**
   * Notify all listeners of state change
   */
  private static notifyListeners(): void {
    this.listeners.forEach((listener) => {
      try {
        listener(this.getState());
      } catch (error) {
        console.error('Error in state listener:', error);
      }
    });
  }

  /**
   * Reset state to initial values
   */
  static reset(): void {
    this.state = { ...initialState };
    this.notifyListeners();
  }

  /**
   * Get state snapshot and clear old state
   */
  static getStateSnapshot(): ConfigurationState {
    return this.getState();
  }
}

export default ConfigStore;
