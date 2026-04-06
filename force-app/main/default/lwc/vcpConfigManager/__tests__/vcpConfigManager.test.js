import { createElement } from 'lwc';
import VcpConfigManager from 'c/vcpConfigManager';

import clearConfigIdFromQuote from '@salesforce/apex/VcpConfigManagerController.clearConfigIdFromQuote';
import createConfigurationV2 from '@salesforce/apex/VcpConfigManagerController.createConfigurationV2';
import determineKnowledgebase from '@salesforce/apex/VcpConfigManagerController.determineKnowledgebase';
import getConfigIdFromQuote from '@salesforce/apex/VcpConfigManagerController.getConfigIdFromQuote';
import getConfigurationV2 from '@salesforce/apex/VcpConfigManagerController.getConfigurationV2';
import getKnowledgebaseTranslations from '@salesforce/apex/VcpConfigManagerController.getKnowledgebaseTranslations';
import patchConfigurationCharacteristics from '@salesforce/apex/VcpConfigManagerController.patchConfigurationCharacteristics';
import resetConfigurationV2 from '@salesforce/apex/VcpConfigManagerController.resetConfigurationV2';
import resolveProductCodeFromContext from '@salesforce/apex/VcpConfigManagerController.resolveProductCodeFromContext';
import saveConfigIdToQuote from '@salesforce/apex/VcpConfigManagerController.saveConfigIdToQuote';

jest.mock(
    '@salesforce/apex/VcpConfigManagerController.clearConfigIdFromQuote',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.createConfigurationV2',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.determineKnowledgebase',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.getConfigIdFromQuote',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.getConfigurationV2',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.getKnowledgebaseTranslations',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.patchConfigurationCharacteristics',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.resetConfigurationV2',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.resolveProductCodeFromContext',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/VcpConfigManagerController.saveConfigIdToQuote',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock('@salesforce/resourceUrl/countriesIcons', () => 'countriesIcons', {
    virtual: true
});

const flushPromises = () => Promise.resolve();

function mockApexDefaults() {
    resolveProductCodeFromContext.mockResolvedValue('F00K001001');
    getConfigIdFromQuote.mockResolvedValue('{"success":true,"configId":null}');
    createConfigurationV2.mockResolvedValue('{"id":"cfg-001"}');
    determineKnowledgebase.mockResolvedValue('{"id":-3}');
    getConfigurationV2.mockResolvedValue('{"id":"cfg-001"}');
    getKnowledgebaseTranslations.mockResolvedValue('{"language":"en","translations":[]}');
    patchConfigurationCharacteristics.mockResolvedValue('{"success":true}');
    resetConfigurationV2.mockResolvedValue('{"success":true}');
    saveConfigIdToQuote.mockResolvedValue('{"success":true}');
    clearConfigIdFromQuote.mockResolvedValue('{"success":true}');
}

describe('c-vcp-config-manager', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('shows robot icon in API language button', async () => {
        mockApexDefaults();

        const element = createElement('c-vcp-config-manager', {
            is: VcpConfigManager
        });
        element.runtimeVisible = true;

        document.body.appendChild(element);
        await flushPromises();

        const firstLangButton = element.shadowRoot.querySelector('.lang-group button');
        expect(firstLangButton).not.toBeNull();
        expect(firstLangButton.textContent).toContain('🤖 API');
    });

    it('logs full SAP response without 500-char truncation', () => {
        const element = createElement('c-vcp-config-manager', {
            is: VcpConfigManager
        });
        const longPayload = 'x'.repeat(900);

        element.logSapResponse('GET /api/v2/configurations/cfg-001', longPayload);

        expect(element.activityLogEntries).toHaveLength(1);
        expect(element.activityLogEntries[0].message).toContain(longPayload);
        expect(element.activityLogEntries[0].message).not.toContain('…');
    });
});
