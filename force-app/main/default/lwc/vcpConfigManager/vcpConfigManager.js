import { LightningElement, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import clearConfigIdFromQuote from '@salesforce/apex/VcpConfigManagerController.clearConfigIdFromQuote';
import countriesIcons from '@salesforce/resourceUrl/countriesIcons';
import createConfigurationV2 from '@salesforce/apex/VcpConfigManagerController.createConfigurationV2';
import determineKnowledgebase from '@salesforce/apex/VcpConfigManagerController.determineKnowledgebase';
import getConfigIdFromQuote from '@salesforce/apex/VcpConfigManagerController.getConfigIdFromQuote';
import getConfigurationV2 from '@salesforce/apex/VcpConfigManagerController.getConfigurationV2';
import getKnowledgebaseTranslations from '@salesforce/apex/VcpConfigManagerController.getKnowledgebaseTranslations';
import patchConfigurationCharacteristics from '@salesforce/apex/VcpConfigManagerController.patchConfigurationCharacteristics';
import resetConfigurationV2 from '@salesforce/apex/VcpConfigManagerController.resetConfigurationV2';
import resolveProductCodeFromContext from '@salesforce/apex/VcpConfigManagerController.resolveProductCodeFromContext';
import saveConfigIdToQuote from '@salesforce/apex/VcpConfigManagerController.saveConfigIdToQuote';

const DEMO_DEFAULTS = {
    productCode: 'F-00K-115-059',
    productId: '01tbY000006KA6MQAW',
    quoteId: 'a3vbY000007ZezRQAS',
    quoteLineId: '-'
};

export default class VcpConfigManager extends LightningElement {
    @api recordId;
    @api quoteId;
    @api productCode;
    @api productId;
    @api quoteLineId;

    storedConfigId = '';
    step1Collapsed = true;
    runtimeVisible = false;

    kbId = '-3';
    productKeyMode = 'context';
    productKey = '';
    productKeyReadonly = true;
    autoCleanup = true;
    selectedDate = '';

    requestPreview = '';
    createResponse = '';

    labelMode = 'api';
    visibilityMode = 'visible';
    groupingMode = 'flat';
    displayMode = 'form';
    loadedCharacteristics = [];
    loadedItemId = '1';
    loadedConfigRaw = null;
    loadedProductKey = '';
    loadedKbId = '';
    loadedKbName = '';
    loadedKbVersion = '';
    loadedKbLogsys = '';
    translationIndex = null;
    translationCache = {};
    eTag = '';
    eTagVersion = 0;
    activityLogEntries = [];
    isBusy = false;
    debugMode = false;
    modalStyleApplied = false;

    connectedCallback() {
        if (!this.quoteId) {
            this.quoteId = this.recordId || DEMO_DEFAULTS.quoteId;
        }

        if (!this.productId) {
            this.productId = DEMO_DEFAULTS.productId;
        }

        if (!this.quoteLineId) {
            this.quoteLineId = DEMO_DEFAULTS.quoteLineId;
        }

        this.productCode = this.productCode || DEMO_DEFAULTS.productCode;
        this.applyProductKeyMode();
        this.buildRequestPreview();
        this.logActivity('Ready', 'E2E modal initialized');
        this.initializeContext();
    }

    renderedCallback() {
        if (this.modalStyleApplied) {
            return;
        }

        // Walk up the DOM from the component host to find the Quick Action
        // modal container and size it directly via inline styles — more
        // reliable than global CSS injection which can be overridden by
        // Salesforce's own SLDS inline styles.
        let el = this.template.host;
        while (el) {
            if (el.classList && el.classList.contains('slds-modal__container')) {
                el.style.setProperty('width', 'min(96vw, 1400px)', 'important');
                el.style.setProperty('max-width', 'min(96vw, 1400px)', 'important');
                this.modalStyleApplied = true;
                break;
            }
            // Cross shadow-root boundaries when traversing (LWC nesting)
            el = el.parentElement || (el.getRootNode && el.getRootNode() !== document ? el.getRootNode().host : null);
        }

        // Fallback: also inject a global <style> so the resize applies even
        // when the modal container sits outside the traversable subtree.
        const styleId = 'vcp-config-manager-modal-style';
        if (!document.getElementById(styleId)) {
            const style = document.createElement('style');
            style.id = styleId;
            style.textContent = [
                'section[role="dialog"] .slds-modal__container,',
                'div[role="dialog"] .slds-modal__container {',
                '  width: min(96vw, 1400px) !important;',
                '  max-width: min(96vw, 1400px) !important;',
                '}',
                'section[role="dialog"] .slds-modal__content,',
                'div[role="dialog"] .slds-modal__content {',
                '  max-height: 80vh !important;',
                '}'
            ].join('\n');
            document.head.appendChild(style);
        }

        this.modalStyleApplied = true;
    }

    get effectiveQuoteId() {
        return this.quoteId || DEMO_DEFAULTS.quoteId;
    }

    get effectiveProductCode() {
        return this.productCode || DEMO_DEFAULTS.productCode;
    }

    get effectiveProductId() {
        return this.productId || DEMO_DEFAULTS.productId;
    }

    get effectiveQuoteLineId() {
        return this.quoteLineId || DEMO_DEFAULTS.quoteLineId;
    }

    get launchSource() {
        return this.recordId ? 'quick-action' : 'demo-fallback';
    }

    get step1SectionClass() {
        return this.step1Collapsed ? 'section-body hidden' : 'section-body';
    }

    get showSetupSections() {
        return !this.runtimeVisible || this.debugMode;
    }

    get apiModeClass() {
        return this.labelMode === 'api' ? 'lang-btn active' : 'lang-btn';
    }

    get enModeClass() {
        return this.labelMode === 'en' ? 'lang-btn active' : 'lang-btn';
    }

    get esModeClass() {
        return this.labelMode === 'es' ? 'lang-btn active' : 'lang-btn';
    }

    get deModeClass() {
        return this.labelMode === 'de' ? 'lang-btn active' : 'lang-btn';
    }

    get usFlagUrl() {
        return `${countriesIcons}/united-states.png`;
    }

    get esFlagUrl() {
        return `${countriesIcons}/spain.png`;
    }

    get deFlagUrl() {
        return `${countriesIcons}/germany.png`;
    }

    get headerProductCode() {
        return this.loadedProductKey || this.effectiveProductCode;
    }

    get headerProductName() {
        return this.translationIndex?.products?.[this.loadedProductKey] || this.headerProductCode;
    }

    get showActivityLog() {
        return this.debugMode || !this.runtimeVisible;
    }

    get debugToggleClass() {
        return this.debugMode ? 'lang-btn active' : 'lang-btn';
    }

    get activityLogForTemplate() {
        return this.activityLogEntries;
    }

    get productKeyModeOptions() {
        return [
            { label: 'Use ProductCode from Quote context', value: 'context' },
            { label: 'Use working key F00K001001', value: 'working' },
            { label: 'Use custom value', value: 'custom' }
        ];
    }

    get visibilityOptions() {
        return [
            { label: 'Visible fields only', value: 'visible' },
            { label: 'All (incl. hidden/dependent)', value: 'all' }
        ];
    }

    get groupingOptions() {
        return [
            { label: 'Flat', value: 'flat' },
            { label: 'By Group', value: 'group' }
        ];
    }

    async initializeContext() {
        this.isBusy = true;
        try {
            if ((!this.productCode || this.productCode === DEMO_DEFAULTS.productCode) && (this.quoteLineId || this.productId)) {
                const resolvedCode = await resolveProductCodeFromContext({
                    quoteLineId: this.quoteLineId,
                    productId: this.productId
                });
                if (resolvedCode) {
                    this.productCode = resolvedCode;
                    this.applyProductKeyMode();
                    this.logActivity('Context', `Resolved product code ${resolvedCode}`);
                }
            }

            if (this.effectiveQuoteId) {
                const raw = await getConfigIdFromQuote({ quoteId: this.effectiveQuoteId });
                const parsed = this.safeParseJson(raw);
                if (parsed?.success && parsed?.configId) {
                    this.storedConfigId = parsed.configId;
                    this.logActivity('Context', `Recovered stored config ${this.storedConfigId}`);
                }
            }

            this.buildRequestPreview();
        } catch (error) {
            this.logAndToastError('Init', error);
        } finally {
            this.isBusy = false;
        }
    }

    toggleStep1() {
        this.step1Collapsed = !this.step1Collapsed;
    }

    async handleLoadStored() {
        if (!this.storedConfigId) {
            this.showInfo('No stored config', 'There is no stored configuration id to load.');
            this.logActivity('Warn', 'Load requested without stored config id');
            return;
        }

        await this.loadConfiguration(this.storedConfigId, 'Loaded');
    }

    async handleSimulateLoading() {
        if (this.storedConfigId) {
            await this.loadConfiguration(this.storedConfigId, 'Simulate/Load');
            return;
        }

        await this.handleCreateConfiguration();
    }

    handleRestartCreate() {
        this.runtimeVisible = false;
        this.step1Collapsed = false;
        this.createResponse = '';
        this.eTag = '';
        this.patchOperationsText = '[]';
        this.showInfo('Restarted', 'Step 1 is active again.');
        this.logActivity('Restart', 'Flow restarted and prepared for new configuration');
    }

    async handleRemoveStored() {
        this.isBusy = true;
        try {
            if (this.effectiveQuoteId) {
                await clearConfigIdFromQuote({ quoteId: this.effectiveQuoteId });
            }
            this.storedConfigId = '';
            this.eTag = '';
            this.showInfo('Removed', 'Stored configuration id cleared.');
            this.logActivity('Remove', 'Stored configuration id removed');
        } catch (error) {
            this.logAndToastError('Remove', error);
        } finally {
            this.isBusy = false;
        }
    }

    handleStoredConfigChange(event) {
        this.storedConfigId = event.target.value;
    }

    handleKbIdChange(event) {
        this.kbId = event.detail.value;
        this.buildRequestPreview();
    }

    handleProductKeyModeChange(event) {
        this.productKeyMode = event.detail.value;
        this.applyProductKeyMode();
        this.buildRequestPreview();
    }

    handleProductKeyChange(event) {
        this.productKey = event.detail.value;
        this.buildRequestPreview();
    }

    handleDateChange(event) {
        this.selectedDate = event.detail.value || '';
        this.buildRequestPreview();
    }

    handleClearDate() {
        this.selectedDate = '';
        this.buildRequestPreview();
    }

    handleAutoCleanupChange(event) {
        this.autoCleanup = event.target.checked;
        this.buildRequestPreview();
    }

    async handleCreateConfiguration() {
        this.isBusy = true;
        try {
            const createPayload = this.removeEmpty({
                kbId: this.kbId || '-3',
                productKey: this.productKey || this.effectiveProductCode,
                date: this.selectedDate || null,
                autoCleanup: this.autoCleanup
            });

            this.logSapRequest('POST /api/v2/configurations', JSON.stringify(createPayload));
            const rawCreate = await createConfigurationV2({ configData: JSON.stringify(createPayload) });
            this.logSapResponse('POST /api/v2/configurations', rawCreate);
            const parsedCreate = this.safeParseJson(rawCreate);
            this.createResponse = this.prettyJson(rawCreate);

            const extractedConfigId = this.extractConfigId(parsedCreate);
            if (extractedConfigId) {
                this.storedConfigId = extractedConfigId;
                await this.persistConfigIdToQuote(extractedConfigId);
                await this.loadConfiguration(extractedConfigId, 'Create');
            } else {
                this.runtimeVisible = true;
                this.showInfo('Create sent', 'Configuration creation request sent, but no config id was detected in response.');
                this.logActivity('Create', 'Create response received without configurationId');
            }
        } catch (error) {
            this.logAndToastError('Create', error);
        } finally {
            this.isBusy = false;
        }
    }

    handleVisibilityChange(event) {
        this.visibilityMode = event.detail.value;
    }

    handleGroupingChange(event) {
        this.groupingMode = event.detail.value;
    }

    handleETagChange(event) {
        this.eTag = event.detail.value;
    }

    handleETagVersionChange(event) {
        this.eTagVersion = Number(event.detail.value) || 0;
    }

    async handleCharacteristicChange(event) {
        const charId = event.detail.charId;
        const newValue = event.detail.newValue;
        if (!this.storedConfigId || !charId) {
            return;
        }

        const operation = {
            characteristicId: charId,
            itemId: Number(this.loadedItemId) || 1,
            input: {
                characteristicId: charId,
                values: newValue ? [{ value: newValue, selected: true }] : []
            }
        };

        this.isBusy = true;
        try {
            this.logSapRequest(`PATCH /api/v2/configurations/${this.storedConfigId}/…/characteristics/${charId}`, `value="${newValue || ''}", etag="${this.eTag || ''}"`);
            const rawPatch = await patchConfigurationCharacteristics({
                configId: this.storedConfigId,
                etag: this.eTag || '*',
                patchOperations: JSON.stringify([operation])
            });
            this.logSapResponse(`PATCH /characteristics/${charId}`, rawPatch);
            const patchResult = this.safeParseJson(rawPatch);
            if (patchResult?.latestETag) {
                this.eTag = patchResult.latestETag;
                this.eTagVersion = this.parseETagVersion(patchResult.latestETag);
            } else {
                this.captureETag(patchResult);
            }
            this.createResponse = this.prettyJson(rawPatch);
            this.logActivity('Patch', `Set ${charId} = ${newValue || '(cleared)'}`);
            await this.loadConfiguration(this.storedConfigId, 'Refresh');
        } catch (error) {
            this.logAndToastError(`Patch ${charId}`, error);
        } finally {
            this.isBusy = false;
        }
    }

    /**
     * Discards all pending characteristic changes by resetting the SAP configuration
     * session to its default values, then reloads it.
     *
     * The current ETag is sent as the If-Match header to satisfy SAP's optimistic
     * concurrency check on the /reset endpoint (HTTP 428 otherwise). Falls back to
     * wildcard '*' when no ETag is held (e.g. before the first GET).
     */
    async handleResetConfigurationInSap() {
        if (!this.storedConfigId) {
            this.showInfo('No config', 'Create or load a configuration first.');
            return;
        }

        this.isBusy = true;
        try {
            this.logSapRequest(`POST /api/v2/configurations/${this.storedConfigId}/reset`, `etag="${this.eTag || ''}"`);
            const raw = await resetConfigurationV2({ configId: this.storedConfigId, etag: this.eTag });
            this.logSapResponse(`POST /reset`, raw);
            this.eTag = '';
            this.eTagVersion = 0;
            this.createResponse = this.prettyJson(raw);
            this.logActivity('Reset', `Configuration ${this.storedConfigId} reset and reloaded`);
            await this.loadConfiguration(this.storedConfigId, 'Refresh');
        } catch (error) {
            this.logAndToastError('Discard & Reload', error);
        } finally {
            this.isBusy = false;
        }
    }

    async handleLabelModeApi() {
        await this.applyLabelMode('api');
    }

    async handleLabelModeEn() {
        await this.applyLabelMode('en');
    }

    async handleLabelModeEs() {
        await this.applyLabelMode('es');
    }

    async handleLabelModeDe() {
        await this.applyLabelMode('de');
    }

    handleStep2Reset() {
        this.runtimeVisible = false;
        this.step1Collapsed = false;
        this.logActivity('Reset', 'Returned from Step 2 to Step 1');
    }

    handleDebugModeToggle() {
        this.debugMode = !this.debugMode;
    }

    async loadConfiguration(configId, actionLabel) {
        this.isBusy = true;
        try {
            this.logSapRequest(`GET /api/v2/configurations/${configId}`, '');
            const raw = await getConfigurationV2({ configId });
            this.logSapResponse(`GET /configurations/${configId}`, raw);
            const parsed = this.safeParseJson(raw);
            this.createResponse = this.prettyJson(raw);
            this.runtimeVisible = true;
            this.captureETag(parsed);
            this.loadedConfigRaw = parsed;
            this.translationIndex = null;
            this.captureConfigurationMeta(parsed);
            this.processCharacteristics(parsed);
            const loadedProductCode = this.loadedProductKey || this.effectiveProductCode;
            this.logActivity(actionLabel, `Configuration loaded for product ${loadedProductCode}`);
            this.showSuccess('Configuration loaded', `Product ${loadedProductCode}`);
        } catch (error) {
            const msg = this.extractErrorMessage(error);
            const is404 = msg.includes('404') || msg.includes('non_existing');
            if (is404) {
                this.logActivity(actionLabel, `Config ${configId} not found in SAP (404) — clearing stored ID`);
                this.storedConfigId = '';
                if (this.effectiveQuoteId) {
                    clearConfigIdFromQuote({ quoteId: this.effectiveQuoteId }).catch(() => {});
                }
                this.showError('Config not found', `Configuration ${configId} no longer exists in SAP. Stored ID cleared — use "Restart & Create New" to start fresh.`);
            } else {
                this.logAndToastError(actionLabel, error);
            }
        } finally {
            this.isBusy = false;
        }
    }

    async persistConfigIdToQuote(configId) {
        if (!this.effectiveQuoteId || !configId) {
            return;
        }

        await saveConfigIdToQuote({
            quoteId: this.effectiveQuoteId,
            configId
        });
        this.logActivity('Persist', `Config ${configId} saved on quote ${this.effectiveQuoteId}`);
    }

    processCharacteristics(config) {
        if (!config?.rootItem || !Array.isArray(config.rootItem.characteristics)) {
            this.loadedCharacteristics = [];
            return;
        }
        this.loadedItemId = String(config.rootItem.id || config.rootItem.itemId || '1');
        this.loadedCharacteristics = config.rootItem.characteristics.map((ch) => {
            const currentValue = this.extractCharValue(ch);

            // Detect fixed-value options: possibleValues with intervalType '1' OR plain enumerated possibleValues
            const rawPossible = Array.isArray(ch.possibleValues) ? ch.possibleValues : [];
            const fixedValues = rawPossible.filter(
                (pv) =>
                    pv.selectable !== false &&
                    ((pv.intervalType === '1' && (pv.valueLow != null || pv.value != null)) ||
                        (pv.intervalType == null && (pv.valueLow != null || pv.value != null)))
            );
            const hasFixedValues = fixedValues.length > 0;
            const isReadonly = ch.readOnly === true;
            const displayLabel = this.resolveCharacteristicLabel(ch);

            const isRequired = ch.required === true;

            return {
                key: ch.id || String(Math.random()),
                id: ch.id || '',
                label: displayLabel,
                visible: ch.visible !== false,
                readOnly: isReadonly,
                required: isRequired,
                complete: ch.complete !== false,
                consistent: ch.consistent !== false,
                currentValue,
                isRadioGroup: !isReadonly && hasFixedValues,
                isTextInput: !isReadonly && !hasFixedValues,
                isReadonlyDisplay: isReadonly,
                options: hasFixedValues
                    ? [
                          ...(isRequired ? [] : [{ label: '— (none)', value: '' }]),
                          ...fixedValues.map((pv) => ({
                              label: this.resolvePossibleValueLabel(ch.id || '', pv),
                              value: pv.valueLow ?? pv.value
                          }))
                      ]
                    : [],
                badgeHidden: ch.visible === false,
                badgeReadonly: isReadonly,
                badgeRequired: isRequired,
                badgeInconsistent: ch.consistent === false,
                badgeIncomplete: ch.complete === false,
                fieldClass:
                    'char-field' +
                    (isReadonly ? ' char-readonly' : '') +
                    (ch.visible === false ? ' char-hidden' : '')
            };
        });
    }

    captureConfigurationMeta(config) {
        this.loadedProductKey = config?.productKey || config?.rootItem?.key || '';
        this.loadedKbId = config?.kbId !== undefined && config?.kbId !== null ? String(config.kbId) : '';
        this.loadedKbName = config?.kbKey?.name || '';
        this.loadedKbVersion = config?.kbKey?.version || '';
        this.loadedKbLogsys = config?.kbKey?.logsys || '';
    }

    /**
     * Centralized label-mode switch.
     * 1) API mode clears external translation index.
     * 2) Non-API mode prefers inline descriptions when available.
     * 3) If inline descriptions are missing, fetches KB translations and applies them.
     */
    async applyLabelMode(mode) {
        this.labelMode = mode;

        if (!this.loadedConfigRaw) {
            this.logActivity('Language', `Switched to ${mode.toUpperCase()} (no configuration loaded)`);
            return;
        }

        if (mode === 'api') {
            this.translationIndex = null;
            this.processCharacteristics(this.loadedConfigRaw);
            this.logActivity('Language', 'Switched to API');
            return;
        }

        const inlineAvailable = this.hasInlineDescriptions(this.loadedConfigRaw, mode);
        let translationState = 'inline descriptions';

        if (!inlineAvailable) {
            const loaded = await this.ensureKnowledgebaseTranslations(mode);
            translationState = loaded ? 'KB translations' : 'API fallback (no translations)';
        }

        if (translationState === 'API fallback (no translations)') {
            this.labelMode = 'api';
            this.showWarning(
                `No ${mode.toUpperCase()} translations`,
                `No translations found for ${mode.toUpperCase()} — showing API identifiers.`
            );
        }

        this.processCharacteristics(this.loadedConfigRaw);
        this.logActivity('Language', `Switched to ${mode.toUpperCase()} (${translationState})`);
    }

    /**
     * Loads translations from SAP using knowledge base id + language.
     * Results are cached by kbId/productKey/language to avoid repeated callouts.
     */
    async ensureKnowledgebaseTranslations(language) {
        const kbId = await this.resolveKbIdForTranslations();
        const productKey = this.loadedProductKey || '';
        if (!kbId) {
            this.translationIndex = null;
            this.logActivity('Language', `No usable kbId for ${language.toUpperCase()} translations`);
            return false;
        }

        const cacheKey = `${kbId}::${productKey}::${language}`;
        if (this.translationCache[cacheKey]) {
            this.translationIndex = this.translationCache[cacheKey];
            this.logActivity('Language', `Translations from cache (${language.toUpperCase()})`);
            return true;
        }

        try {
            this.logSapRequest(`GET /api/v2/knowledgebases/${kbId}/translations`, `language="${language}"`);
            const raw = await getKnowledgebaseTranslations({ kbId, language });
            this.logSapResponse(`GET /knowledgebases/${kbId}/translations`, raw);
            const parsed = this.safeParseJson(raw);
            const index = this.buildTranslationIndex(parsed, language, productKey);
            this.translationCache = {
                ...this.translationCache,
                [cacheKey]: index
            };
            if (this.hasUsableTranslations(index)) {
                this.translationIndex = index;
                this.logActivity('Language', `Translations fetched (${language.toUpperCase()}) for kbId ${kbId}`);
                return true;
            }

            this.translationIndex = null;
            this.logActivity('Language', `No translations returned for ${language.toUpperCase()} (kbId ${kbId})`);
            return false;
        } catch (error) {
            this.translationIndex = null;
            this.logActivity('Language ERROR', this.extractErrorMessage(error));
            return false;
        }
    }

    /**
     * Picks a numeric KB id for translation lookup.
     * Priority: loaded config kbId -> UI kbId -> determineKnowledgebase(productKey).
     */
    async resolveKbIdForTranslations() {
        if (this.isUsableKbId(this.loadedKbId)) {
            return this.loadedKbId;
        }
        if (this.isUsableKbId(this.kbId)) {
            return String(this.kbId);
        }

        const productKey = this.loadedProductKey || this.effectiveProductCode;
        if (!productKey) {
            return '';
        }

        this.logActivity('Language', `kbId not in config (loaded="${this.loadedKbId}", ui="${this.kbId || ''}") — calling kbdetermination for ${productKey}`);

        try {
            this.logSapRequest(`GET /api/v2/kbdetermination`, `productId="${productKey}"`);
            const raw = await determineKnowledgebase({
                productId: productKey,
                validityDate: null,
                type: null,
                plant: null
            });
            this.logSapResponse('GET /kbdetermination', raw);
            const parsed = this.safeParseJson(raw);
            const determinedKbId = this.extractKbIdFromDetermineResponse(parsed);
            if (this.isUsableKbId(determinedKbId)) {
                this.loadedKbId = String(determinedKbId);
                this.logActivity('Language', `Determined kbId ${this.loadedKbId} for product ${productKey}`);
                return this.loadedKbId;
            }
            this.logActivity(
                'Language WARN',
                `kbdetermination returned no usable kbId — raw: ${JSON.stringify(parsed).substring(0, 200)}`
            );
            return '';
        } catch (error) {
            this.logActivity('Language WARN', `KB determine failed: ${this.extractErrorMessage(error)}`);
            return '';
        }
    }

    isUsableKbId(value) {
        if (value === null || value === undefined) {
            return false;
        }
        const text = String(value).trim();
        // Accept any integer (including negative values like -3 used by SAP for AVC knowledge bases).
        return text !== '' && /^-?\d+$/.test(text);
    }

    extractKbIdFromDetermineResponse(payload) {
        if (!payload) {
            return null;
        }

        if (Array.isArray(payload)) {
            return payload[0]?.id ?? null;
        }

        if (Array.isArray(payload.items)) {
            return payload.items[0]?.id ?? null;
        }

        if (payload.id !== undefined && payload.id !== null) {
            return payload.id;
        }

        return null;
    }

    /** Returns true when translation index contains at least one translated label/value. */
    hasUsableTranslations(index) {
        if (!index || typeof index !== 'object') {
            return false;
        }

        if (Object.keys(index.characteristics || {}).length > 0) {
            return true;
        }

        const valuesMap = index.values || {};
        return Object.keys(valuesMap).some((characteristicId) => Object.keys(valuesMap[characteristicId] || {}).length > 0);
    }

    /** Detects whether loaded configuration already contains inline descriptions for a language. */
    hasInlineDescriptions(config, language) {
        const chars = config?.rootItem?.characteristics;
        if (!Array.isArray(chars)) {
            return false;
        }
        return chars.some((ch) => {
            if (!ch?.descriptions || typeof ch.descriptions !== 'object') {
                return false;
            }
            const direct = ch.descriptions[language];
            if (typeof direct === 'string' && direct.trim()) {
                return true;
            }
            const normalized = Object.keys(ch.descriptions).find((key) => key?.toLowerCase?.() === language);
            const value = normalized ? ch.descriptions[normalized] : null;
            return typeof value === 'string' && value.trim();
        });
    }

    /** Resolves characteristic label with fallback chain: API id <- inline description <- KB translation. */
    resolveCharacteristicLabel(ch) {
        const apiId = ch?.id || '';
        if (this.labelMode === 'api') {
            return apiId;
        }

        const inlineLabel = this.resolveInlineDescription(ch, this.labelMode);
        if (inlineLabel) {
            return inlineLabel;
        }

        const kbLabel = this.translationIndex?.characteristics?.[apiId];
        if (kbLabel) {
            return kbLabel;
        }

        return apiId;
    }

    /** Resolves option label translation for a possible value, falling back to API value when missing. */
    resolvePossibleValueLabel(characteristicId, pv) {
        const apiValue = String(pv?.valueLow ?? pv?.value ?? '');
        if (this.labelMode === 'api') {
            return apiValue;
        }
        const translated = this.translationIndex?.values?.[characteristicId]?.[apiValue];
        return translated || apiValue;
    }

    /** Reads inline descriptions from configuration payload, supporting case-insensitive language keys. */
    resolveInlineDescription(ch, language) {
        if (!ch?.descriptions || typeof ch.descriptions !== 'object') {
            return null;
        }

        const direct = ch.descriptions[language];
        if (typeof direct === 'string' && direct.trim()) {
            return direct;
        }

        const normalized = Object.keys(ch.descriptions).find((key) => key?.toLowerCase?.() === language);
        const value = normalized ? ch.descriptions[normalized] : null;
        return typeof value === 'string' && value.trim() ? value : null;
    }

    /**
     * Builds an index compatible with VF translation behavior:
     * - characteristics[id] => label
     * - values[characteristicId][valueId] => label
     * - products / groups for future UI use
     */
    buildTranslationIndex(payload, language, productKey) {
        const index = {
            language,
            productKey: productKey || '',
            products: {},
            characteristics: {},
            values: {},
            groups: {}
        };

        if (!payload || typeof payload !== 'object') {
            return index;
        }

        if (Array.isArray(payload.characteristics)) {
            payload.characteristics.forEach((item) => {
                if (!item || !item.id) {
                    return;
                }

                const characteristicName = this.getBestTranslationName(item.translation, language);
                if (characteristicName) {
                    index.characteristics[item.id] = characteristicName;
                }

                if (Array.isArray(item.possibleValues) && item.possibleValues.length > 0) {
                    index.values[item.id] = index.values[item.id] || {};
                    item.possibleValues.forEach((valueItem) => {
                        if (!valueItem || valueItem.id === undefined || valueItem.id === null) {
                            return;
                        }
                        const valueName = this.getBestTranslationName(valueItem.translation, language);
                        if (valueName) {
                            index.values[item.id][String(valueItem.id)] = valueName;
                        }
                    });
                }
            });
        }

        if (Array.isArray(payload.products)) {
            const bestProduct =
                payload.products.find((product) => product && product.id && productKey && product.id === productKey) ||
                payload.products[0];

            if (bestProduct && bestProduct.id) {
                const productName = this.getBestTranslationName(bestProduct.translation, language);
                if (productName) {
                    index.products[bestProduct.id] = productName;
                }
            }

            if (bestProduct && Array.isArray(bestProduct.characteristicGroups)) {
                bestProduct.characteristicGroups.forEach((group) => {
                    if (!group || !group.id) {
                        return;
                    }
                    const groupName = this.getBestTranslationName(group.translation, language);
                    if (groupName) {
                        index.groups[group.id] = groupName;
                    }
                });
            }
        }

        return index;
    }

    /** Returns the translation.name matching a specific language code. */
    getBestTranslationName(translations, language) {
        if (!Array.isArray(translations) || translations.length === 0) {
            return null;
        }

        const exact = translations.find((item) => item && item.language === language && item.name);
        if (exact) {
            return exact.name;
        }

        return null;
    }

    extractCharValue(ch) {
        if (!Array.isArray(ch.values) || ch.values.length === 0) {
            return '';
        }
        const first = ch.values[0];
        return first.valueLow || first.value || '';
    }

    applyProductKeyMode() {
        if (this.productKeyMode === 'context') {
            this.productKey = this.productCode || DEMO_DEFAULTS.productCode;
            this.productKeyReadonly = true;
        } else if (this.productKeyMode === 'working') {
            this.productKey = 'F00K001001';
            this.productKeyReadonly = true;
        } else {
            if (this.productKey === (this.productCode || DEMO_DEFAULTS.productCode) || this.productKey === 'F00K001001') {
                this.productKey = '';
            }
            this.productKeyReadonly = false;
        }
    }

    removeEmpty(obj) {
        return Object.keys(obj).reduce((result, key) => {
            const val = obj[key];
            if (val !== '' && val !== null && val !== undefined) {
                result[key] = val;
            }
            return result;
        }, {});
    }

    buildRequestPreview() {
        this.requestPreview = JSON.stringify(
            this.removeEmpty({
                kbId: this.kbId || '-3',
                productKey: this.productKey || this.effectiveProductCode,
                date: this.selectedDate || null,
                autoCleanup: this.autoCleanup
            }),
            null,
            2
        );
    }

    captureETag(payload) {
        const found = this.findFirstValueByKey(payload, 'etag');
        if (found && typeof found === 'string') {
            this.eTag = found;
            this.eTagVersion = this.parseETagVersion(found);
        }
    }

    /** Extracts the numeric version from a weak ETag such as W/"6" → 6. Returns 0 if not parseable. */
    parseETagVersion(etag) {
        if (!etag) return 0;
        const match = etag.match(/^W\/"(\d+)"$/);
        return match ? Number(match[1]) : 0;
    }

    extractConfigId(payload) {
        const direct = this.findFirstValueByKey(payload, 'configurationId') || this.findFirstValueByKey(payload, 'configId');
        if (direct && typeof direct === 'string') {
            return direct;
        }

        const genericId = this.findFirstValueByKey(payload, 'id');
        if (genericId && typeof genericId === 'string' && genericId.length > 10) {
            return genericId;
        }

        return null;
    }

    findFirstValueByKey(obj, targetKey) {
        if (!obj || typeof obj !== 'object') {
            return null;
        }

        if (Array.isArray(obj)) {
            for (const item of obj) {
                const nested = this.findFirstValueByKey(item, targetKey);
                if (nested !== null && nested !== undefined) {
                    return nested;
                }
            }
            return null;
        }

        const normalizedTarget = targetKey.toLowerCase();
        for (const key of Object.keys(obj)) {
            if (key.toLowerCase().includes(normalizedTarget)) {
                return obj[key];
            }
        }

        for (const key of Object.keys(obj)) {
            const nested = this.findFirstValueByKey(obj[key], targetKey);
            if (nested !== null && nested !== undefined) {
                return nested;
            }
        }

        return null;
    }

    safeParseJson(rawValue) {
        if (rawValue === null || rawValue === undefined) {
            return null;
        }

        if (typeof rawValue === 'object') {
            return rawValue;
        }

        if (typeof rawValue === 'string') {
            try {
                return JSON.parse(rawValue);
            } catch (e) {
                return null;
            }
        }

        return null;
    }

    prettyJson(rawValue) {
        const parsed = this.safeParseJson(rawValue);
        if (parsed) {
            return JSON.stringify(parsed, null, 2);
        }

        if (typeof rawValue === 'string') {
            return rawValue;
        }

        return JSON.stringify(rawValue, null, 2);
    }

    showInfo(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant: 'info',
                mode: 'dismissible',
                duration: 3000
            })
        );
    }

    showSuccess(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant: 'success',
                mode: 'dismissible',
                duration: 3000
            })
        );
    }

    showWarning(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant: 'warning',
                mode: 'dismissible',
                duration: 5000
            })
        );
    }

    showError(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    logAndToastError(action, error) {
        const message = this.extractErrorMessage(error);
        this.logActivity(`${action} ERROR`, message);
        this.showError(action, message);
    }

    extractErrorMessage(error) {
        if (error?.body?.message) {
            return error.body.message;
        }

        if (error?.message) {
            return error.message;
        }

        return 'Unknown error';
    }

    logActivity(action, detail) {
        const time = new Date().toLocaleTimeString();
        let type = 'info';
        const a = action.toUpperCase();
        if (a.includes('ERROR')) type = 'error';
        else if (a.includes('WARN')) type = 'warn';
        else if (a.startsWith('\u2190 SAP')) type = 'response';
        else if (a.startsWith('\u2192 SAP')) type = 'request';
        else if (a === 'PATCH' || a === 'CREATE' || a === 'RESET' || a === 'REFRESH') type = 'action';
        const next = {
            key: `${Date.now()}-${Math.random()}`,
            message: `[${time}] ${action}: ${detail}`,
            type
        };
        this.activityLogEntries = [...this.activityLogEntries, next].slice(-100);
    }

    logSapRequest(operation, params) {
        const detail = params ? `${operation} | ${params}` : operation;
        this.logActivity('→ SAP', detail);
    }

    logSapResponse(operation, raw) {
        const body = typeof raw === 'string' ? raw : JSON.stringify(raw ?? '');
        const truncated = body.length > 500 ? `${body.substring(0, 500)} …` : body;
        this.logActivity('← SAP', `${operation} | ${truncated}`);
    }

    get isFormMode() {
        return this.displayMode === 'form';
    }

    get isWizardMode() {
        return this.displayMode === 'wizard';
    }

    get formModeClass() {
        return `lang-btn ${this.isFormMode ? 'active' : ''}`;
    }

    get wizardModeClass() {
        return `lang-btn ${this.isWizardMode ? 'active' : ''}`;
    }

    handleDisplayModeForm() {
        this.displayMode = 'form';
        this.logActivity('Display', 'Switched to Form view');
    }

    handleDisplayModeWizard() {
        this.displayMode = 'wizard';
        this.logActivity('Display', 'Switched to Wizard view');
    }

    handleWizardFinish() {
        this.displayMode = 'form';
        this.logActivity('Wizard', 'Configuration complete — returned to Form view');
        this.showSuccess('Configuration complete', 'All fields saved. Switched to Form view.');
    }
}
