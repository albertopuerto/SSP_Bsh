import { LightningElement, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import clearConfigIdFromQuote from '@salesforce/apex/VcpConfigManagerController.clearConfigIdFromQuote';
import countriesIcons from '@salesforce/resourceUrl/countriesIcons';
import createConfigurationV2 from '@salesforce/apex/VcpConfigManagerController.createConfigurationV2';
import determineKnowledgebase from '@salesforce/apex/VcpConfigManagerController.determineKnowledgebase';
import getConfigIdFromQuote from '@salesforce/apex/VcpConfigManagerController.getConfigIdFromQuote';
import getConfigurationV2 from '@salesforce/apex/VcpConfigManagerController.getConfigurationV2';
import getKnowledgebaseCharacteristicTranslations from '@salesforce/apex/VcpConfigManagerController.getKnowledgebaseCharacteristicTranslations';
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
    @api showBack = false;

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
    groupOrderCache = null; // persisted after first KB translation load; used in API mode for tab grouping
    eTag = '';
    lastKnownETag = '';
    eTagVersion = 0;
    autoPatchEnabled = true;
    pendingPatchOperationsByChar = {};
    activityLogEntries = [];
    isBusy = false;
    debugMode = false;
    modalStyleApplied = false;

    handleBack() {
        this.dispatchEvent(new CustomEvent('back'));
    }

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
        return !this.runtimeVisible;
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

    get autoPatchToggleLabel() {
        return this.autoPatchEnabled ? 'Auto PATCH: ON' : 'Auto PATCH: OFF';
    }

    get autoPatchToggleVariant() {
        return this.autoPatchEnabled ? 'brand' : 'neutral';
    }

    get showSendPendingButton() {
        return !this.autoPatchEnabled;
    }

    get isSendPendingDisabled() {
        return this.pendingPatchCount === 0;
    }

    get pendingPatchCount() {
        return Object.keys(this.pendingPatchOperationsByChar || {}).length;
    }

    get sendPendingLabel() {
        return this.pendingPatchCount > 0 ? `Send Pending (${this.pendingPatchCount})` : 'Send Pending';
    }

    get totalCharacteristicCount() {
        return (this.loadedCharacteristics || []).length;
    }

    get visibleCharacteristicCount() {
        return (this.loadedCharacteristics || []).filter((c) => c.visible).length;
    }

    get hiddenCharacteristicCount() {
        return (this.loadedCharacteristics || []).filter((c) => c.badgeHidden).length;
    }

    get readonlyCharacteristicCount() {
        return (this.loadedCharacteristics || []).filter((c) => c.badgeReadonly).length;
    }

    get pendingCharacteristicCount() {
        return (this.loadedCharacteristics || []).filter((c) => c.hasPendingChange).length;
    }

    get patchPreviewText() {
        const operations = Object.values(this.pendingPatchOperationsByChar || {});
        const preview = {
            configId: this.storedConfigId || null,
            mode: this.autoPatchEnabled ? 'auto' : 'manual-batch',
            pendingCount: operations.length,
            etag: this.resolveCurrentETag() || null,
            patchOperations: operations
        };
        return JSON.stringify(preview, null, 2);
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
        this.lastKnownETag = '';
        this.eTagVersion = 0;
        this.pendingPatchOperationsByChar = {};
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
            this.lastKnownETag = '';
            this.eTagVersion = 0;
            this.pendingPatchOperationsByChar = {};
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
        const nextETag = (event.detail.value || '').trim();
        this.eTag = nextETag;
        this.eTagVersion = this.parseETagVersion(nextETag);
    }

    get eTagVersionStr() {
        return this.eTagVersion > 0 ? String(this.eTagVersion) : '0';
    }

    get eTagVersionOptions() {
        const opts = [{ label: '— (manual)', value: '0' }];
        for (let i = 1; i <= 20; i++) {
            opts.push({ label: String(i), value: String(i) });
        }
        return opts;
    }

    handleETagVersionChange(event) {
        this.eTagVersion = Number(event.detail.value) || 0;
        this.eTag = this.eTagVersion > 0 ? this.buildWeakETag(this.eTagVersion) : '';
    }

    handleToggleAutoPatch() {
        this.autoPatchEnabled = !this.autoPatchEnabled;
        if (this.autoPatchEnabled && this.pendingPatchCount > 0) {
            this.logActivity('Patch', `Auto mode enabled with ${this.pendingPatchCount} pending change(s)`);
        } else {
            this.logActivity('Patch', this.autoPatchEnabled ? 'Auto PATCH enabled' : 'Auto PATCH disabled (manual batch mode)');
        }
    }

    async handleCharacteristicChange(event) {
        const charId = event.detail.charId;
        const newValue = event.detail.newValue;
        if (!this.storedConfigId || !charId) {
            return;
        }

        const operation = this.buildCharacteristicPatchOperation(charId, newValue);

        if (this.autoPatchEnabled) {
            await this.sendPatchOperations([operation], `Patch ${charId}`, { reloadAfterSuccess: true });
            return;
        }

        this.pendingPatchOperationsByChar = {
            ...this.pendingPatchOperationsByChar,
            [charId]: operation
        };
        this.applyCharacteristicValueLocally(charId, newValue);
        this.syncPendingFlagsInLoadedCharacteristics();
        this.logActivity('Patch Queue', `Queued ${charId} = ${newValue || '(cleared)'} (${this.pendingPatchCount} pending)`);
    }

    async handleSendPendingPatches() {
        const operations = Object.values(this.pendingPatchOperationsByChar || {});
        if (operations.length === 0) {
            this.showInfo('No pending changes', 'There are no queued characteristic changes to send.');
            return;
        }

        await this.sendPatchOperations(operations, 'Patch Batch', { reloadAfterSuccess: true, clearQueueAfterSuccess: true });
    }

    buildCharacteristicPatchOperation(charId, newValue) {
        const values = Array.isArray(newValue)
            ? newValue
                  .filter((value) => value !== null && value !== undefined && String(value).trim() !== '')
                  .map((value) => ({ value: String(value), selected: true }))
            : newValue
              ? [{ value: newValue, selected: true }]
              : [];

        return {
            characteristicId: charId,
            itemId: Number(this.loadedItemId) || 1,
            input: {
                characteristicId: charId,
                values
            }
        };
    }

    applyCharacteristicValueLocally(charId, newValue) {
        const asArray = Array.isArray(newValue)
            ? [...newValue]
            : newValue
              ? [String(newValue)]
              : [];

        this.loadedCharacteristics = (this.loadedCharacteristics || []).map((ch) => {
            if (ch.id !== charId) {
                return ch;
            }
            return {
                ...ch,
                currentValues: asArray,
                currentValue: asArray[0] || ''
            };
        });
    }

    syncPendingFlagsInLoadedCharacteristics() {
        this.loadedCharacteristics = (this.loadedCharacteristics || []).map((ch) => {
            const hasPendingChange = Boolean(ch.id && this.pendingPatchOperationsByChar[ch.id]);
            const baseFieldClass = String(ch.fieldClass || '')
                .replace(/\schar-pending/g, '')
                .trim();
            return {
                ...ch,
                hasPendingChange,
                badgePending: hasPendingChange,
                fieldClass: hasPendingChange ? `${baseFieldClass} char-pending` : baseFieldClass
            };
        });
    }

    async sendPatchOperations(operations, actionLabel, options = {}) {
        const { reloadAfterSuccess = true, clearQueueAfterSuccess = false } = options;
        const resolvedETag = this.resolveCurrentETag();
        const patchSummary = operations
            .map((op) => {
                const values = Array.isArray(op?.input?.values) ? op.input.values.map((v) => v.value) : [];
                return `${op.characteristicId}=${values.length > 0 ? values.join('|') : '(cleared)'}`;
            })
            .join(', ');

        this.isBusy = true;
        try {
            this.logSapRequest(
                `PATCH /api/v2/configurations/${this.storedConfigId}/…/characteristics`,
                `count="${operations.length}", etag="${resolvedETag || ''}", values="${patchSummary}"`
            );
            const rawPatch = await patchConfigurationCharacteristics({
                configId: this.storedConfigId,
                etag: resolvedETag,
                patchOperations: JSON.stringify(operations)
            });
            this.logSapResponse('PATCH /characteristics', rawPatch);
            const patchResult = this.safeParseJson(rawPatch);

            this.throwIfPatchBatchFailed(patchResult, operations);

            if (patchResult?.latestETag) {
                this.applyResolvedETag(patchResult.latestETag);
            } else {
                this.captureETag(patchResult);
            }
            this.createResponse = this.prettyJson(rawPatch);
            this.logActivity('Patch', `${actionLabel} applied (${operations.length} change(s))`);

            if (clearQueueAfterSuccess) {
                this.pendingPatchOperationsByChar = {};
                this.syncPendingFlagsInLoadedCharacteristics();
            }

            if (reloadAfterSuccess) {
                await this.loadConfiguration(this.storedConfigId, 'Refresh', { showSuccessToast: false });
            }
        } catch (error) {
            this.logAndToastError(actionLabel, error);
        } finally {
            this.isBusy = false;
        }
    }

    /**
     * Discards all pending characteristic changes by resetting the SAP configuration
     * session to its default values, then reloads it.
     *
     * The current ETag is sent as the If-Match header to satisfy SAP's optimistic
     * concurrency check on the /reset endpoint (HTTP 428 otherwise).
     */
    async handleResetConfigurationInSap() {
        if (!this.storedConfigId) {
            this.showInfo('No config', 'Create or load a configuration first.');
            return;
        }

        const resolvedETag = this.resolveCurrentETag();

        this.isBusy = true;
        try {
            this.logSapRequest(`POST /api/v2/configurations/${this.storedConfigId}/reset`, `etag="${resolvedETag || ''}"`);
            const raw = await resetConfigurationV2({ configId: this.storedConfigId, etag: resolvedETag });
            this.logSapResponse(`POST /reset`, raw);
            this.eTag = '';
            this.lastKnownETag = '';
            this.eTagVersion = 0;
            this.pendingPatchOperationsByChar = {};
            this.syncPendingFlagsInLoadedCharacteristics();
            this.createResponse = this.prettyJson(raw);
            this.logActivity('Reset', `Configuration ${this.storedConfigId} reset and reloaded`);
            await this.loadConfiguration(this.storedConfigId, 'Refresh', { showSuccessToast: false });
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
        this.pendingPatchOperationsByChar = {};
        this.syncPendingFlagsInLoadedCharacteristics();
        this.logActivity('Reset', 'Returned to configuration setup');
    }

    handleDebugModeToggle() {
        this.debugMode = !this.debugMode;
    }

    async loadConfiguration(configId, actionLabel, options = {}) {
        const { showSuccessToast = true } = options;
        this.isBusy = true;
        try {
            this.logSapRequest(`GET /api/v2/configurations/${configId}`, '');
            const raw = await getConfigurationV2({ configId });
            this.logSapResponse(`GET /configurations/${configId}`, raw);
            const parsed = this.safeParseJson(raw);
            this.createResponse = this.prettyJson(raw);
            this.runtimeVisible = true;
            this.loadedConfigRaw = parsed;
            this.recoverETagAfterRead(parsed);
            this.pendingPatchOperationsByChar = {};
            this.translationIndex = null;
            this.captureConfigurationMeta(parsed);
            this.processCharacteristics(parsed);
            const loadedProductCode = this.loadedProductKey || this.effectiveProductCode;
            this.logActivity(actionLabel, `Configuration loaded for product ${loadedProductCode}`);
            if (showSuccessToast) {
                this.showSuccess('Configuration loaded', `Product ${loadedProductCode}`);
            }
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
            const currentValues = this.extractCharValues(ch);
            const currentValue = currentValues[0] || '';

            const rawPossible = Array.isArray(ch.possibleValues) ? ch.possibleValues : [];
            const fixedValues = rawPossible.filter((pv) => this.isSelectableFixedValue(pv));
            const hasFixedValues = fixedValues.length > 0;
            const isReadonly = ch.readOnly === true;
            const hasPossibleValues = rawPossible.length > 0;
            const hasConstrainedButUnavailableValues = hasPossibleValues && !hasFixedValues;
            const isDisplayOnly = isReadonly || hasConstrainedButUnavailableValues;
            const displayLabel = this.resolveCharacteristicLabel(ch);
            const hasPendingChange = Boolean(ch.id && this.pendingPatchOperationsByChar[ch.id]);
            const isCheckboxGroup = !isDisplayOnly && hasFixedValues && this.isMultiSelectCharacteristic(ch, currentValues);
            const isDropdown = !isDisplayOnly && hasFixedValues && !isCheckboxGroup;

            const isRequired = this.isCharacteristicRequired(ch);

            return {
                key: ch.id || String(Math.random()),
                id: ch.id || '',
                label: displayLabel,
                visible: ch.visible !== false,
                readOnly: isReadonly,
                required: isRequired,
                complete: ch.complete !== false,
                consistent: ch.consistent !== false,
                currentValues,
                currentValue,
                isCheckboxGroup,
                isDropdown,
                isTextInput: !isDisplayOnly && !hasPossibleValues,
                isReadonlyDisplay: isDisplayOnly,
                hasPendingChange,
                options: hasFixedValues
                    ? fixedValues.map((pv) => ({
                              label: this.resolvePossibleValueLabel(ch.id || '', pv),
                              value: this.normalizePossibleValue(pv)
                          }))
                    : [],
                badgeHidden: ch.visible === false,
                badgeReadonly: isDisplayOnly,
                badgePending: hasPendingChange,
                badgeRequired: isRequired,
                badgeInconsistent: ch.consistent === false,
                badgeIncomplete: ch.complete === false,
                fieldClass:
                    'char-field' +
                    (isDisplayOnly ? ' char-readonly' : '') +
                    (hasPendingChange ? ' char-pending' : '') +
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
            this._refreshGroupOrderCache(this.translationIndex);
            this.logActivity('Language', `Translations from cache (${language.toUpperCase()})`);
            return true;
        }

        try {
            this.logSapRequest(`GET /api/v2/knowledgebases/${kbId}/translations`, `language="${language}"`);
            const [raw, rawChar] = await Promise.all([
                getKnowledgebaseTranslations({ kbId, language }),
                getKnowledgebaseCharacteristicTranslations({ kbId, language }).catch((e) => {
                    this.logActivity('Language', `Char translations non-critical error: ${this.extractErrorMessage(e)}`);
                    return null;
                })
            ]);
            this.logSapResponse(`GET /knowledgebases/${kbId}/translations`, raw);
            this.logSapResponse(`GET /knowledgebases/${kbId}/translations?$select=characteristics`, rawChar ?? '(skipped)');
            const parsed = this.safeParseJson(raw);
            const parsedChar = this.safeParseJson(rawChar);
            const index = this.buildTranslationIndex(parsed, language, productKey);
            this.mergeCharacteristicValueTranslations(index, parsedChar, language);
            this.translationCache = {
                ...this.translationCache,
                [cacheKey]: index
            };
            if (this.hasUsableTranslations(index)) {
                this.translationIndex = index;
                this._refreshGroupOrderCache(index);
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
        if (translated) {
            return `${translated} (${apiValue})`;
        }
        return apiValue;
    }

    /** Merges possibleValues translations from a $select=characteristics response into an existing translation index. */
    mergeCharacteristicValueTranslations(index, payload, language) {
        if (!payload || !Array.isArray(payload.characteristics)) {
            return;
        }
        payload.characteristics.forEach((item) => {
            if (!item || !item.id) {
                return;
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
            groups: {},
            groupOrder: [],
            groupCharacteristics: {}
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
                    index.groupOrder.push(group.id);
                    if (Array.isArray(group.characteristicIDs)) {
                        index.groupCharacteristics[group.id] = [...group.characteristicIDs];
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

    extractCharValues(ch) {
        if (!Array.isArray(ch?.values) || ch.values.length === 0) {
            return [];
        }

        return ch.values
            .map((valueItem) => valueItem?.valueLow ?? valueItem?.value)
            .filter((value) => value !== null && value !== undefined && String(value).trim() !== '')
            .map((value) => String(value));
    }

    isMultiSelectCharacteristic(ch, currentValues) {
        if (Array.isArray(currentValues) && currentValues.length > 1) {
            return true;
        }

        const candidates = [
            ch?.multipleValues,
            ch?.multiValued,
            ch?.isMultiValued,
            ch?.allowMultipleValues,
            ch?.allowsMultipleValues,
            ch?.maxEntries,
            ch?.maximumNumberOfValues,
            ch?.maxNumberOfValues
        ];

        return candidates.some((candidate) => {
            if (candidate === true) {
                return true;
            }
            if (candidate === false || candidate === null || candidate === undefined) {
                return false;
            }
            const numericCandidate = Number(candidate);
            return Number.isFinite(numericCandidate) && numericCandidate > 1;
        });
    }

    isCharacteristicRequired(ch) {
        const candidates = [
            ch?.required,
            ch?.isRequired,
            ch?.requiredInput,
            ch?.input?.required,
            ch?.inputRequired,
            ch?.mandatory
        ];

        return candidates.some((candidate) => {
            if (candidate === true) {
                return true;
            }

            if (candidate === false || candidate === null || candidate === undefined) {
                return false;
            }

            if (typeof candidate === 'string') {
                const normalized = candidate.trim().toLowerCase();
                return normalized === 'true' || normalized === 'x' || normalized === 'required' || normalized === '1';
            }

            if (typeof candidate === 'number') {
                return candidate === 1;
            }

            return false;
        });
    }

    normalizePossibleValue(pv) {
        if (!pv) {
            return '';
        }

        const rawValue = pv.valueLow ?? pv.value;
        return rawValue === null || rawValue === undefined ? '' : String(rawValue).trim();
    }

    isSelectableFixedValue(pv) {
        if (!pv || pv.selectable === false) {
            return false;
        }

        const normalizedValue = this.normalizePossibleValue(pv);
        if (!normalizedValue) {
            return false;
        }

        return pv.intervalType === '1' || pv.intervalType == null;
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

    /**
     * Aligns LWC behavior with VF after each GET:
     * 1) prefer response _eTag/etag
     * 2) reuse last known good ETag from previous PATCH/GET
     * 3) fallback to weak default W/"1" so next PATCH has a valid If-Match shape
     */
    recoverETagAfterRead(payload) {
        const payloadETag = this.extractPayloadETag(payload);
        if (payloadETag) {
            this.applyResolvedETag(payloadETag);
            return;
        }

        const reusedETag = this.lastKnownETag || (this.eTagVersion > 0 ? this.buildWeakETag(this.eTagVersion) : '');
        if (reusedETag) {
            this.applyResolvedETag(reusedETag);
            this.logActivity('ETag', `GET returned no _eTag; reusing ${reusedETag}`);
            return;
        }

        const inferredDefault = this.buildWeakETag(1);
        this.applyResolvedETag(inferredDefault);
        this.logActivity('ETag', `GET returned no _eTag; inferred default ${inferredDefault}`);
    }

    captureETag(payload) {
        const found = this.findFirstValueByKey(payload, 'etag');
        if (found && typeof found === 'string') {
            this.applyResolvedETag(found);
        }
    }

    throwIfPatchFailed(patchResult, charId) {
        if (!patchResult || patchResult.success !== false) {
            return;
        }

        const result = patchResult.results?.[charId];
        const statusCode = result?.statusCode || 'unknown';
        const rawError = result?.error || patchResult.message || 'PATCH failed';
        let message = rawError;

        if (typeof rawError === 'string') {
            const parsedError = this.safeParseJson(rawError);
            if (parsedError?.message) {
                message = parsedError.message;
            }
        }

        throw new Error(`SAP PATCH failed (${statusCode}): ${message}`);
    }

    throwIfPatchBatchFailed(patchResult, operations) {
        if (!patchResult || patchResult.success !== false) {
            return;
        }

        const failedOperation = operations.find((op) => patchResult?.results?.[op.characteristicId]?.status === 'error') || operations[0];
        this.throwIfPatchFailed(patchResult, failedOperation.characteristicId);
    }

    applyResolvedETag(etag) {
        const normalizedETag = typeof etag === 'string' ? etag.trim() : '';
        if (!normalizedETag) {
            return;
        }

        this.eTag = normalizedETag;
        this.lastKnownETag = normalizedETag;
        this.eTagVersion = this.parseETagVersion(normalizedETag);
    }

    resolveCurrentETag() {
        const manualETag = typeof this.eTag === 'string' ? this.eTag.trim() : '';
        if (manualETag) {
            return manualETag;
        }

        const configETag = this.extractPayloadETag(this.loadedConfigRaw);
        if (configETag) {
            return configETag;
        }

        if (this.lastKnownETag) {
            return this.lastKnownETag;
        }

        if (this.eTagVersion > 0) {
            return this.buildWeakETag(this.eTagVersion);
        }

        return this.buildWeakETag(1);
    }

    extractPayloadETag(payload) {
        const found = this.findFirstValueByKey(payload, 'etag');
        return typeof found === 'string' ? found.trim() : '';
    }

    buildWeakETag(version) {
        const numericVersion = Number(version) || 0;
        return numericVersion > 0 ? `W/"${numericVersion}"` : '';
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

        // Exact top-level 'id' check first — SAP v2 POST returns the config UUID here.
        // findFirstValueByKey uses partial key matching which picks up 'kbId' before 'id'.
        if (payload?.id && typeof payload.id === 'string' && payload.id.length > 10) {
            return payload.id;
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

    logActivity(action, detail, options = {}) {
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
            type,
            summary: `[${time}] ${action}: ${detail}`,
            bodyDetail: options.bodyDetail || null,
            statusCode: options.statusCode || null,
            isExpanded: false
        };
        this.activityLogEntries = [...this.activityLogEntries, next].slice(-100);
    }

    logSapRequest(operation, params) {
        let bodyDetail = null;
        let summaryParams = '';
        if (params) {
            try {
                bodyDetail = JSON.stringify(JSON.parse(params), null, 2);
                summaryParams = ' | {…}';
            } catch (e) {
                summaryParams = params.length > 60 ? ` | ${params.substring(0, 60)}…` : ` | ${params}`;
            }
        }
        this.logActivity('→ SAP', `${operation}${summaryParams}`, { bodyDetail });
    }

    logSapResponse(operation, raw) {
        const body = typeof raw === 'string' ? raw : JSON.stringify(raw ?? '');
        let statusCode = null;
        let bodyDetail = null;
        let summaryStatus = '';
        try {
            const parsed = JSON.parse(body);
            statusCode = parsed?._httpStatus ?? parsed?.status ?? parsed?.statusCode ?? null;
            bodyDetail = JSON.stringify(parsed, null, 2);
            summaryStatus = statusCode ? ` [${statusCode}]` : '';
        } catch (e) {
            bodyDetail = body || null;
        }
        this.logActivity('← SAP', `${operation}${summaryStatus}`, { bodyDetail, statusCode });
    }

    get isFormMode() {
        return this.displayMode === 'form';
    }

    get isWizardMode() {
        return this.displayMode === 'wizard';
    }

    get isTabsMode() {
        return this.displayMode === 'tabs';
    }

    get formModeClass() {
        return `lang-btn ${this.isFormMode ? 'active' : ''}`;
    }

    get wizardModeClass() {
        return `lang-btn ${this.isWizardMode ? 'active' : ''}`;
    }

    get tabsModeClass() {
        return `lang-btn ${this.isTabsMode ? 'active' : ''}`;
    }

    get characteristicsByGroup() {
        const chars = this.loadedCharacteristics || [];
        const charMap = {};
        chars.forEach((c) => {
            charMap[c.id] = c;
        });

        // Use live translation index when available (non-API modes);
        // fall back to groupOrderCache (populated on first KB load) so Tabs
        // mode still shows groups even after switching back to API mode.
        const source = this.translationIndex?.groupOrder?.length
            ? this.translationIndex
            : this.groupOrderCache;

        if (!source?.groupOrder?.length) {
            return [{ key: '$general', groupId: '$general', groupLabel: 'All', characteristics: chars }];
        }

        const result = [];
        const placedIds = new Set();

        for (const groupId of source.groupOrder) {
            const charIds = source.groupCharacteristics?.[groupId] || [];
            const groupChars = charIds.map((id) => charMap[id]).filter(Boolean);
            if (groupChars.length === 0) {
                continue;
            }
            groupChars.forEach((c) => placedIds.add(c.id));
            // Labels: prefer live translation index; cache has ids only in API mode
            const groupLabel =
                this.translationIndex?.groups?.[groupId] ||
                this.groupOrderCache?.groups?.[groupId] ||
                groupId;
            result.push({
                key: groupId,
                groupId,
                groupLabel,
                characteristics: groupChars
            });
        }

        const unplaced = chars.filter((c) => !placedIds.has(c.id));
        if (unplaced.length > 0) {
            result.push({
                key: '$general',
                groupId: '$general',
                groupLabel: 'General',
                characteristics: unplaced
            });
        }

        return result;
    }

    handleDisplayModeForm() {
        this.displayMode = 'form';
        this.logActivity('Display', 'Switched to Form view');
    }

    handleDisplayModeWizard() {
        this.displayMode = 'wizard';
        this.logActivity('Display', 'Switched to Wizard view');
    }

    handleDisplayModeTabs() {
        this.displayMode = 'tabs';
        this.logActivity('Display', 'Switched to Tabs view');
    }

    handleWizardFinish() {
        this.displayMode = 'form';
        this.logActivity('Wizard', 'Configuration complete — returned to Form view');
        this.showSuccess('Configuration complete', 'All fields saved. Switched to Form view.');
    }

    /**
     * Persists group structure from a translation index into groupOrderCache so
     * that the Tabs view can show groups even when the user switches back to API
     * mode (which clears translationIndex but does not lose the KB group layout).
     * Only updates the cache when the incoming index actually contains group data.
     */
    _refreshGroupOrderCache(index) {
        if (!index?.groupOrder?.length) {
            return;
        }
        this.groupOrderCache = {
            groupOrder: [...index.groupOrder],
            groupCharacteristics: { ...index.groupCharacteristics },
            groups: { ...index.groups }
        };
    }
}
