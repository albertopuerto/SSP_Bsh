import { LightningElement, api } from 'lwc';

import getProductFamilyOptions from '@salesforce/apex/VcpProductSelectorController.getProductFamilyOptions';
import getProducts from '@salesforce/apex/VcpProductSelectorController.getProducts';

const COLUMNS = [
    {
        type: 'button-icon',
        fixedWidth: 52,
        typeAttributes: {
            iconName: { fieldName: '_btnIcon' },
            name: 'select',
            variant: { fieldName: '_btnVariant' },
            alternativeText: 'Select',
            title: { fieldName: '_btnTitle' }
        }
    },
    { label: 'Product Code', fieldName: 'productCode', type: 'text', sortable: true, initialWidth: 130 },
    { label: 'Name', fieldName: 'name', type: 'text', sortable: true, initialWidth: 200 },
    { label: 'Family', fieldName: 'family', type: 'text', sortable: true, initialWidth: 150 },
    { label: 'Description', fieldName: 'description', type: 'text', wrapText: true, initialWidth: 220 },
    {
        label: 'List Price',
        fieldName: 'listPrice',
        type: 'currency',
        typeAttributes: { currencyCode: 'EUR', minimumFractionDigits: 2 },
        sortable: true,
        initialWidth: 110
    },
    {
        label: 'Ext. Configurable',
        fieldName: 'externallyConfigurable',
        type: 'boolean',
        initialWidth: 130,
        cellAttributes: { alignment: 'center' }
    },
    { label: 'Config. Type', fieldName: 'configurationType', type: 'text', initialWidth: 120 },
    { label: 'Config. Event', fieldName: 'configurationEvent', type: 'text', initialWidth: 120 },
    { label: 'Division', fieldName: 'division', type: 'text', initialWidth: 120 },
    { label: 'Material Type', fieldName: 'materialType', type: 'text', initialWidth: 130 },
    { label: 'Cross Plant', fieldName: 'crossPlant', type: 'text', initialWidth: 110 }
];

export default class VcpProductSelector extends LightningElement {
    @api recordId;

    columns = COLUMNS;
    selectedFamily = '';
    externallyConfigurableOnly = false;
    familyOptions = [];
    products = [];
    isBusy = false;
    errorMessage = '';
    selectedProduct = null;
    selectedRowIds = [];
    sortField = 'productCode';
    sortDirection = 'asc';
    showConfigurator = false;
    modalStyleApplied = false;

    connectedCallback() {
        this._loadFamilyOptions();
        this._loadProducts();
    }

    renderedCallback() {
        if (this.modalStyleApplied) {
            return;
        }
        let el = this.template.host;
        while (el) {
            if (el.classList && el.classList.contains('slds-modal__container')) {
                el.style.setProperty('width', 'min(96vw, 1600px)', 'important');
                el.style.setProperty('max-width', 'min(96vw, 1600px)', 'important');
                this.modalStyleApplied = true;
                break;
            }
            el = el.parentElement || (el.getRootNode && el.getRootNode() !== document ? el.getRootNode().host : null);
        }
        const styleId = 'vcp-product-selector-modal-style';
        if (!document.getElementById(styleId)) {
            const style = document.createElement('style');
            style.id = styleId;
            style.textContent = [
                'section[role="dialog"] .slds-modal__container,',
                'div[role="dialog"] .slds-modal__container {',
                '  width: min(96vw, 1600px) !important;',
                '  max-width: min(96vw, 1600px) !important;',
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

    async _loadFamilyOptions() {
        try {
            this.familyOptions = await getProductFamilyOptions();
        } catch (e) {
            // family options are non-critical, silently ignore
        }
    }

    async _loadProducts() {
        this.isBusy = true;
        this.errorMessage = '';
        this.selectedProduct = null;
        this.selectedRowIds = [];
        try {
            const raw = await getProducts({
                family: this.selectedFamily || null,
                externallyConfigurableOnly: this.externallyConfigurableOnly
            });
            this.products = this._decorateRows(raw, null);
        } catch (e) {
            this.errorMessage = e?.body?.message || e?.message || 'Error loading products.';
            this.products = [];
        } finally {
            this.isBusy = false;
        }
    }

    _decorateRows(rows, selectedId) {
        return rows.map((r) => ({
            ...r,
            _btnIcon: r.id === selectedId ? 'utility:check' : 'utility:add',
            _btnVariant: r.id === selectedId ? 'brand' : 'border',
            _btnTitle: r.id === selectedId ? 'Selected' : 'Select'
        }));
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortField = fieldName;
        this.sortDirection = sortDirection;
        this.products = this._sortRows([...this.products], fieldName, sortDirection);
    }

    _sortRows(rows, field, direction) {
        const mul = direction === 'asc' ? 1 : -1;
        return rows.sort((a, b) => {
            const va = a[field] ?? '';
            const vb = b[field] ?? '';
            if (typeof va === 'number' && typeof vb === 'number') {
                return (va - vb) * mul;
            }
            return String(va).localeCompare(String(vb)) * mul;
        });
    }

    handleFamilyChange(event) {
        this.selectedFamily = event.detail.value;
        this._loadProducts();
    }

    handleExternallyConfigurableChange(event) {
        this.externallyConfigurableOnly = event.detail.checked;
        this._loadProducts();
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'select') {
            const row = event.detail.row;
            const newId = this.selectedRowIds[0] === row.id ? null : row.id;
            this.selectedProduct = newId ? row : null;
            this.selectedRowIds = newId ? [newId] : [];
            this.products = this._decorateRows(this.products, newId);
        }
    }

    handleContinue() {
        if (this.selectedProduct) {
            this.showConfigurator = true;
        }
    }

    handleBackToList() {
        this.showConfigurator = false;
        // Keep selectedProduct + selectedRowIds so the row stays highlighted
        // and the Continue button remains active.
    }

    get hasError() {
        return !!this.errorMessage;
    }

    get hasSelection() {
        return !!this.selectedProduct;
    }

    get continueDisabled() {
        return !this.selectedProduct;
    }

    get selectionLabel() {
        if (!this.selectedProduct) return '';
        return `${this.selectedProduct.productCode} — ${this.selectedProduct.name}`;
    }

    get productCount() {
        return this.products ? this.products.length : 0;
    }
}
