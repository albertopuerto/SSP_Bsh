import { LightningElement, api, track } from 'lwc';

export default class UtilActivityLog extends LightningElement {
    /**
     * Array of entry objects produced by the parent's logActivity helpers.
     * Shape: { key, type, summary, bodyDetail, statusCode }
     * isExpanded is managed locally here, not by the parent.
     */
    @api
    get entries() {
        return this._entries;
    }
    set entries(value) {
        // Merge incoming entries preserving local isExpanded state
        const prev = new Map((this._entries || []).map((e) => [e.key, e]));
        this._entries = (value || []).map((e) => ({
            ...e,
            isExpanded: prev.get(e.key)?.isExpanded ?? false
        }));
    }

    @track _entries = [];

    get enriched() {
        return this._entries.map((e) => ({
            ...e,
            hasDetail: Boolean(e.bodyDetail),
            rowClass: `log-entry${e.hasDetail || Boolean(e.bodyDetail) ? ' expandable' : ''}`,
            chevronClass: `log-chevron${e.isExpanded ? ' expanded' : ''}`,
            statusBadgeClass: this._statusBadgeClass(e.statusCode)
        }));
    }

    get isEmpty() {
        return !this._entries || this._entries.length === 0;
    }

    // ── header click → toggle expand ───────────────────────────────────────
    handleHeaderClick(event) {
        const key = event.currentTarget.dataset.key;
        this._toggleEntry(key);
    }

    // ── copy button click ───────────────────────────────────────────────────
    handleCopyClick(event) {
        // Stop propagation so the parent header-click handler doesn't fire
        event.stopPropagation();
        // Capture button reference synchronously — event.currentTarget is nullified
        // by LWC as soon as this handler returns (before the clipboard promise resolves)
        const btn = event.currentTarget;
        const key = btn.dataset.key;
        const entry = this._entries.find((e) => e.key === key);
        if (!entry?.bodyDetail) return;
        navigator.clipboard.writeText(entry.bodyDetail).then(() => {
            btn.dataset.copied = 'true';
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                btn.dataset.copied = '';
            }, 1500);
        });
    }

    // ── detail area click → allow text selection, don't expand/collapse ─────
    handleDetailClick(event) {
        event.stopPropagation();
    }

    // ── private ─────────────────────────────────────────────────────────────
    _toggleEntry(key) {
        const entry = this._entries.find((e) => e.key === key);
        if (!entry?.bodyDetail) return;
        this._entries = this._entries.map((e) =>
            e.key === key ? { ...e, isExpanded: !e.isExpanded } : e
        );
    }

    _statusBadgeClass(code) {
        if (!code) return 'status-badge';
        const n = Number(code);
        if (n >= 200 && n < 300) return 'status-badge status-2xx';
        if (n >= 300 && n < 400) return 'status-badge status-3xx';
        if (n >= 400 && n < 500) return 'status-badge status-4xx';
        if (n >= 500) return 'status-badge status-5xx';
        return 'status-badge';
    }
}
