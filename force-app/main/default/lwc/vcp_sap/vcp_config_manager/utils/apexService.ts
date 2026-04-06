/**
 * Apex Service Wrapper
 *
 * Provides a type-safe interface for calling Apex methods from the Salesforce org.
 * Handles both @wire and imperative calls with caching support.
 */

interface ApexCallConfig {
  params?: Record<string, any>;
  timeout?: number;
  cacheable?: boolean;
}

interface ApexResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export class ApexService {
  private static readonly DEFAULT_TIMEOUT = 30000; // 30 seconds
  private static cache = new Map<string, { data: any; timestamp: number }>();
  private static readonly CACHE_TTL = 5 * 60 * 1000; // 5 minutes

  /**
   * Execute an Apex method imperatively
   * @param controller Apex class name
   * @param method Apex method name
   * @param config Configuration with params and options
   */
  static async executeApex<T = any>(
    controller: string,
    method: string,
    config: ApexCallConfig = {}
  ): Promise<ApexResponse<T>> {
    const cacheKey = `${controller}.${method}:${JSON.stringify(config.params)}`;

    // Check cache
    if (config.cacheable) {
      const cached = this.getFromCache<T>(cacheKey);
      if (cached) {
        return { success: true, data: cached };
      }
    }

    return new Promise((resolve) => {
      const timeout = setTimeout(() => {
        clearTimeout(timeout);
        resolve({
          success: false,
          error: `Apex call timeout: ${controller}.${method}`
        });
      }, config.timeout || this.DEFAULT_TIMEOUT);

      try {
        // Use Visualforce sforce.apex.execute pattern
        // This works in Visualforce context; in LWC, we'd use @wire(apex) or wire adapters
        if (typeof (window as any).sforce !== 'undefined') {
          const result = (window as any).sforce.apex.execute(
            controller,
            method,
            config.params || {}
          );

          clearTimeout(timeout);

          if (result) {
            const response: ApexResponse<T> = {
              success: true,
              data: result
            };

            if (config.cacheable) {
              this.setInCache(cacheKey, result);
            }

            resolve(response);
          } else {
            resolve({
              success: false,
              error: `No response from ${controller}.${method}`
            });
          }
        } else {
          clearTimeout(timeout);
          resolve({
            success: false,
            error: 'Apex execution context not available'
          });
        }
      } catch (error: any) {
        clearTimeout(timeout);
        resolve({
          success: false,
          error: error?.message || String(error)
        });
      }
    });
  }

  /**
   * Get a value from cache if valid
   */
  private static getFromCache<T>(key: string): T | null {
    const cached = this.cache.get(key);
    if (!cached) return null;

    const isExpired = Date.now() - cached.timestamp > this.CACHE_TTL;
    if (isExpired) {
      this.cache.delete(key);
      return null;
    }

    return cached.data as T;
  }

  /**
   * Store a value in cache
   */
  private static setInCache(key: string, data: any): void {
    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
  }

  /**
   * Clear all cached entries
   */
  static clearCache(): void {
    this.cache.clear();
  }

  /**
   * Clear a specific cache entry
   */
  static clearCacheKey(key: string): void {
    this.cache.delete(key);
  }
}

export default ApexService;
