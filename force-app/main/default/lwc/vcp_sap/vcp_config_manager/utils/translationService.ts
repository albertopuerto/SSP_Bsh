/**
 * Translation Service
 *
 * Handles language support and translation loading for VCP UI.
 * Supports API IDs (default), English, Spanish, German.
 */

export type LanguageCode = 'api' | 'en' | 'es' | 'de';

export interface LanguageConfig {
  code: LanguageCode;
  label: string;
  flag?: string;
  flagUrl?: string;
}

export const SUPPORTED_LANGUAGES: Record<LanguageCode, LanguageConfig> = {
  api: {
    code: 'api',
    label: 'API IDs',
    flag: '🤖'
  },
  en: {
    code: 'en',
    label: 'English',
    flag: '🇺🇸',
    flagUrl: 'united-states.png'
  },
  es: {
    code: 'es',
    label: 'Spanish',
    flag: '🇪🇸',
    flagUrl: 'spain.png'
  },
  de: {
    code: 'de',
    label: 'German',
    flag: '🇩🇪',
    flagUrl: 'germany.png'
  }
};

type TranslationMap = Record<string, Record<string, string>>;

export class TranslationService {
  private static translations: TranslationMap = {};
  private static currentLanguage: LanguageCode = 'api';
  private static listeners: Set<(lang: LanguageCode) => void> = new Set();

  /**
   * Get supported languages
   */
  static getSupportedLanguages(): LanguageConfig[] {
    return Object.values(SUPPORTED_LANGUAGES);
  }

  /**
   * Get language config by code
   */
  static getLanguageConfig(code: LanguageCode): LanguageConfig {
    return SUPPORTED_LANGUAGES[code];
  }

  /**
   * Set current language
   */
  static setLanguage(code: LanguageCode): void {
    if (code in SUPPORTED_LANGUAGES) {
      this.currentLanguage = code;
      this.notifyListeners();
    }
  }

  /**
   * Get current language
   */
  static getCurrentLanguage(): LanguageCode {
    return this.currentLanguage;
  }

  /**
   * Load translations for a language
   * Typically called from Apex service with mock data
   */
  static loadTranslations(language: LanguageCode, translations: Record<string, string>): void {
    if (!this.translations[language]) {
      this.translations[language] = {};
    }
    this.translations[language] = { ...this.translations[language], ...translations };
  }

  /**
   * Get a translated label
   * Falls back to key if translation not found
   */
  static translate(key: string, defaultValue?: string): string {
    if (this.currentLanguage === 'api') {
      return defaultValue || key;
    }

    const translationMap = this.translations[this.currentLanguage];
    if (!translationMap) {
      return defaultValue || key;
    }

    return translationMap[key] || defaultValue || key;
  }

  /**
   * Get translated field label
   */
  static getFieldLabel(fieldId: string): string {
    return this.translate(fieldId, fieldId);
  }

  /**
   * Get all translations for current language
   */
  static getTranslations(): Record<string, string> {
    if (this.currentLanguage === 'api') {
      return {};
    }
    return this.translations[this.currentLanguage] || {};
  }

  /**
   * Clear translations
   */
  static clearTranslations(language?: LanguageCode): void {
    if (language) {
      delete this.translations[language];
    } else {
      this.translations = {};
    }
  }

  /**
   * Subscribe to language changes
   */
  static onLanguageChange(listener: (lang: LanguageCode) => void): () => void {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  }

  /**
   * Notify listeners of language change
   */
  private static notifyListeners(): void {
    this.listeners.forEach((listener) => {
      try {
        listener(this.currentLanguage);
      } catch (error) {
        console.error('Error in language change listener:', error);
      }
    });
  }
}

export default TranslationService;
