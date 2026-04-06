import type { ActivityEntry } from '../../utils';
import { LightningElement } from 'lwc';
import { Logger } from '../../utils';

/**
 * Activity Log Component
 *
 * Displays all logged activities and operations in the VCP configuration flow.
 * Supports filtering by status and real-time updates.
 */
export default class VcpActivityLog extends LightningElement {
  activities: ActivityEntry[] = [];
  filteredActivities: ActivityEntry[] = [];
  filterStatus: 'all' | 'success' | 'error' | 'pending' = 'all';
  isAutoScroll = true;

  connectedCallback() {
    Logger.info('Activity Log initialized');

    // Load initial activities
    this.updateActivities();

    // Poll for new activities every 500ms
    this.activityPollInterval = setInterval(() => {
      this.updateActivities();
    }, 500);
  }

  disconnectedCallback() {
    if (this.activityPollInterval) {
      clearInterval(this.activityPollInterval);
    }
  }

  private activityPollInterval?: number;

  /**
   * Update activities from logger
   */
  updateActivities() {
    this.activities = Logger.getActivities();
    this.applyFilter();

    // Auto-scroll to bottom if enabled
    if (this.isAutoScroll) {
      setTimeout(() => {
        const container = this.template.querySelector('[data-id="log-container"]');
        if (container) {
          container.scrollTop = container.scrollHeight;
        }
      });
    }
  }

  /**
   * Apply current filter to activities
   */
  applyFilter() {
    if (this.filterStatus === 'all') {
      this.filteredActivities = [...this.activities];
    } else {
      this.filteredActivities = this.activities.filter((a) => a.status === this.filterStatus);
    }
  }

  /**
   * Handle filter change
   */
  handleFilterChange(event: any) {
    this.filterStatus = event.target.value;
    this.applyFilter();
  }

  /**
   * Clear all logs
   */
  clearLogs() {
    Logger.clearActivities();
    this.updateActivities();
  }

  /**
   * Get CSS class for activity status
   */
  getStatusClass(status: string): string {
    switch (status) {
      case 'success':
        return 'slds-text-color_success';
      case 'error':
        return 'slds-text-color_error';
      case 'pending':
        return 'slds-text-color_default';
      default:
        return '';
    }
  }

  /**
   * Format timestamp
   */
  formatTime(date: Date): string {
    return new Date(date).toLocaleTimeString();
  }

  /**
   * Format duration in ms to readable format
   */
  formatDuration(ms?: number): string {
    if (!ms) return '-';
    if (ms < 1000) return `${ms}ms`;
    return `${(ms / 1000).toFixed(2)}s`;
  }
}
