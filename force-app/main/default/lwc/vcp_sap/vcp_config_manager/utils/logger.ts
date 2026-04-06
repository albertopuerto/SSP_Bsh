/**
 * Logger Service
 *
 * Centralized logging and activity tracking for VCP operations.
 * Supports multiple log levels and activity accumulation.
 */

export enum LogLevel {
  DEBUG = 'DEBUG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR'
}

export interface LogEntry {
  level: LogLevel;
  timestamp: Date;
  message: string;
  data?: Record<string, any>;
  source?: string;
}

export interface ActivityEntry {
  id: string;
  timestamp: Date;
  action: string;
  status: 'pending' | 'success' | 'error';
  details: Record<string, any>;
  duration?: number; // ms
}

export class Logger {
  private static logs: LogEntry[] = [];
  private static activities: ActivityEntry[] = [];
  private static readonly MAX_LOGS = 1000;
  private static readonly MAX_ACTIVITIES = 500;
  private static minLevel = LogLevel.INFO;
  private static activityTimers = new Map<string, number>();

  /**
   * Set minimum log level to display
   */
  static setMinLevel(level: LogLevel): void {
    this.minLevel = level;
  }

  /**
   * Log a message at given level
   */
  static log(
    level: LogLevel,
    message: string,
    data?: Record<string, any>,
    source?: string
  ): void {
    const entry: LogEntry = {
      level,
      timestamp: new Date(),
      message,
      data,
      source: source || 'vcp-config'
    };

    this.logs.push(entry);

    // Keep logs bounded
    if (this.logs.length > this.MAX_LOGS) {
      this.logs = this.logs.slice(-this.MAX_LOGS);
    }

    // Also log to console if level >= minLevel
    if (this.shouldLog(level)) {
      const prefix = `[${entry.source}] ${level}:`;
      if (data) {
        console.log(prefix, message, data);
      } else {
        console.log(prefix, message);
      }
    }
  }

  /**
   * Convenience methods
   */
  static debug(message: string, data?: Record<string, any>, source?: string): void {
    this.log(LogLevel.DEBUG, message, data, source);
  }

  static info(message: string, data?: Record<string, any>, source?: string): void {
    this.log(LogLevel.INFO, message, data, source);
  }

  static warn(message: string, data?: Record<string, any>, source?: string): void {
    this.log(LogLevel.WARN, message, data, source);
  }

  static error(message: string, data?: Record<string, any>, source?: string): void {
    this.log(LogLevel.ERROR, message, data, source);
  }

  /**
   * Check if log level should be displayed
   */
  private static shouldLog(level: LogLevel): boolean {
    const levelOrder = [LogLevel.DEBUG, LogLevel.INFO, LogLevel.WARN, LogLevel.ERROR];
    return levelOrder.indexOf(level) >= levelOrder.indexOf(this.minLevel);
  }

  /**
   * Get all logged entries
   */
  static getLogs(): LogEntry[] {
    return [...this.logs];
  }

  /**
   * Clear logs
   */
  static clearLogs(): void {
    this.logs = [];
  }

  /**
   * Start tracking an activity
   */
  static startActivity(id: string, action: string): void {
    this.activityTimers.set(id, Date.now());
    this.addActivity({
      id,
      action,
      status: 'pending',
      details: { startedAt: new Date().toISOString() }
    });
  }

  /**
   * Complete an activity with success
   */
  static completeActivity(id: string, details?: Record<string, any>): void {
    this.finishActivity(id, 'success', details);
  }

  /**
   * Fail an activity with error
   */
  static failActivity(id: string, error?: string, details?: Record<string, any>): void {
    this.finishActivity(id, 'error', { error, ...details });
  }

  /**
   * Internal method to finish an activity
   */
  private static finishActivity(
    id: string,
    status: 'success' | 'error',
    details?: Record<string, any>
  ): void {
    const startTime = this.activityTimers.get(id);
    const duration = startTime ? Date.now() - startTime : undefined;

    const activity = this.activities.find((a) => a.id === id);
    if (activity) {
      activity.status = status;
      activity.duration = duration;
      activity.details = { ...activity.details, ...details, completedAt: new Date().toISOString() };
    }

    this.activityTimers.delete(id);
  }

  /**
   * Add an activity entry
   */
  private static addActivity(activity: ActivityEntry): void {
    this.activities.push(activity);

    // Keep activities bounded
    if (this.activities.length > this.MAX_ACTIVITIES) {
      this.activities = this.activities.slice(-this.MAX_ACTIVITIES);
    }
  }

  /**
   * Get all activity entries
   */
  static getActivities(): ActivityEntry[] {
    return [...this.activities];
  }

  /**
   * Get activities filtered by status
   */
  static getActivitiesByStatus(status: 'pending' | 'success' | 'error'): ActivityEntry[] {
    return this.activities.filter((a) => a.status === status);
  }

  /**
   * Clear all activities
   */
  static clearActivities(): void {
    this.activities = [];
    this.activityTimers.clear();
  }

  /**
   * Export all data for debugging
   */
  static export(): { logs: LogEntry[]; activities: ActivityEntry[] } {
    return {
      logs: this.getLogs(),
      activities: this.getActivities()
    };
  }
}

export default Logger;
