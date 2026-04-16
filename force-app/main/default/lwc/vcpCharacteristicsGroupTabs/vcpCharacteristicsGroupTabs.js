import { LightningElement, api } from 'lwc';

export default class VcpCharacteristicsGroupTabs extends LightningElement {
    @api groups = []; // [{key, groupId, groupLabel, characteristics[]}]
    @api visibilityMode = 'visible';
    @api labelMode = 'api';
    activeGroupId = '';

    get hasGroups() {
        return Array.isArray(this.groups) && this.groups.length > 0;
    }

    get groupsForTemplate() {
        const groups = Array.isArray(this.groups) ? this.groups : [];
        const activeGroupId = this.currentActiveGroupId;
        return groups.map((group) => ({
            ...group,
            buttonClass: `group-tab-btn ${String(group.groupId) === activeGroupId ? 'active' : ''}`,
            ariaSelected: String(String(group.groupId) === activeGroupId),
            tabIndexValue: String(group.groupId) === activeGroupId ? '0' : '-1'
        }));
    }

    get currentActiveGroupId() {
        const groups = Array.isArray(this.groups) ? this.groups : [];
        if (groups.length === 0) {
            return '';
        }

        const hasCurrent = groups.some((group) => String(group.groupId) === this.activeGroupId);
        if (hasCurrent) {
            return this.activeGroupId;
        }

        return String(groups[0].groupId);
    }

    get activeGroup() {
        const activeId = this.currentActiveGroupId;
        return (this.groups || []).find((group) => String(group.groupId) === activeId) || null;
    }

    get hasActiveGroup() {
        return Boolean(this.activeGroup);
    }

    get activeGroupCharacteristics() {
        return this.activeGroup?.characteristics || [];
    }

    get activeGroupKey() {
        return this.activeGroup?.key || this.currentActiveGroupId || 'group';
    }

    handleGroupSelect(event) {
        const groupId = event.currentTarget?.dataset?.groupId;
        if (!groupId || groupId === this.activeGroupId) {
            return;
        }
        this.activeGroupId = String(groupId);
    }

    handleCharacteristicChange(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent('characteristicchange', {
                detail: event.detail
            })
        );
    }
}
