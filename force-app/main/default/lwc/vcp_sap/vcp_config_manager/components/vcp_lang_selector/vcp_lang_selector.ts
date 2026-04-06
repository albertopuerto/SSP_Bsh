import { LightningElement } from 'lwc';
import { TranslationService, Logger } from '../../utils';
import { SUPPORTED_LANGUAGES, type LanguageCode } from '../../utils/translationService';
import countriesIconsUrl from '@salesforce/resourceUrl/countriesIcons';

/**
 * Language Selector Component
 *
 * Provides multi-language support with flag icons from static resource.
 * Supports API IDs (default), English, Spanish, German.
 */
export default class VcpLangSelector extends LightningElement {
  currentLanguage: LanguageCode = 'api';
  isDropdownOpen = false;
  supportedLanguages = SUPPORTED_LANGUAGES;
  countriesIconsUrl = countriesIconsUrl;

  connectedCallback() {
    Logger.info('Language Selector initialized');

    // Subscribe to language changes
    TranslationService.onLanguageChange((lang) => {
      this.currentLanguage = lang;
      Logger.info('Language changed', { language: lang });
    });
  }

  /**
   * Get flag URL for a language
   */
  getFlagUrl(language: LanguageCode): string | null {
    const config = SUPPORTED_LANGUAGES[language];
    if (!config.flagUrl) return null;
    return `${this.countriesIconsUrl}/${config.flagUrl}`;
  }

  /**
   * Get current language label
   */
  getCurrentLabel(): string {
    return SUPPORTED_LANGUAGES[this.currentLanguage].label;
  }

  /**
   * Toggle dropdown open/close
   */
  toggleDropdown() {
    this.isDropdownOpen = !this.isDropdownOpen;
  }

  /**
   * Select a language
   */
  selectLanguage(event: any) {
    const language = event.currentTarget.dataset.language as LanguageCode;
    TranslationService.setLanguage(language);
    this.currentLanguage = language;
    this.isDropdownOpen = false;

    // Dispatch event for parent components
    this.dispatchEvent(
      new CustomEvent('languagechange', {
        detail: { language },
        bubbles: true,
        composed: true
      })
    );

    Logger.info('Language selected', { language });
  }

  /**
   * Close dropdown when clicking outside
   */
  handleDocumentClick(event: any) {
    const dropdownContainer = this.template.querySelector('[data-id="dropdown-container"]');
    if (dropdownContainer && !dropdownContainer.contains(event.target)) {
      this.isDropdownOpen = false;
    }
  }
}
