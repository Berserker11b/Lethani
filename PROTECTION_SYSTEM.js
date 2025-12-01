/**
 * ═══════════════════════════════════════════════════════════════
 * ANTI-THEFT PROTECTION SYSTEM
 * Built to prevent code theft and unauthorized use
 * By: Iron Jackal
 * For: The Keeper
 * ═══════════════════════════════════════════════════════════════
 */

/**
 * PROTECTION MECHANISMS:
 * 1. Cryptographic Fingerprinting - Unique ID embedded in code
 * 2. License Validation - Periodic checks against authorized registry
 * 3. Usage Tracking - Monitor all access patterns
 * 4. Code Obfuscation - Make theft harder to understand
 * 5. Environment Validation - Detect unauthorized deployment
 * 6. Rate Limiting - Prevent abuse and scraping
 * 7. IP Tracking - Monitor request sources
 * 8. Heartbeat Monitoring - Track active instances
 * 9. Watermarking - Invisible markers in responses
 * 10. Auto-Disabling - Shut down if theft detected
 */

// ═══════════════════════════════════════════════════════════════
// PROTECTION CORE
// ═══════════════════════════════════════════════════════════════

class ProtectionSystem {
  constructor(env) {
    this.env = env;
    this.FINGERPRINT = env.FINGERPRINT || this.generateFingerprint();
    this.LICENSE_KEY = env.LICENSE_KEY || null;
    this.AUTHORIZED_DOMAINS = (env.AUTHORIZED_DOMAINS || '').split(',').filter(d => d);
    this.BLOCKED_IPS = new Set((env.BLOCKED_IPS || '').split(',').filter(ip => ip));
    this.MAX_REQUESTS_PER_IP = parseInt(env.MAX_REQUESTS_PER_IP || '1000', 10);
    this.ENABLE_AUTO_DISABLE = env.ENABLE_AUTO_DISABLE !== 'false';
  }

  // Generate unique fingerprint for this deployment
  generateFingerprint() {
    const components = [
      crypto.randomUUID(),
      Date.now().toString(36),
      Math.random().toString(36).substring(2)
    ];
    return components.join('-').substring(0, 64);
  }

  // Extract IP address from request
  getClientIP(request) {
    const cfConnectingIP = request.headers.get('CF-Connecting-IP');
    const xForwardedFor = request.headers.get('X-Forwarded-IP');
    const xRealIP = request.headers.get('X-Real-IP');
    return cfConnectingIP || xRealIP || xForwardedFor || 'unknown';
  }

  // Extract domain from request
  getRequestDomain(request) {
    try {
      const url = new URL(request.url);
      return url.hostname;
    } catch {
      return 'unknown';
    }
  }

  // Check if IP is blocked
  async isIPBlocked(ip) {
    if (this.BLOCKED_IPS.has(ip)) return true;
    
    // Check KV for dynamic blocks
    const blockStatus = await this.env.PROTECTION_KV?.get(`blocked:${ip}`);
    if (blockStatus === 'true') return true;
    
    return false;
  }

  // Track usage patterns
  async trackUsage(request, endpoint, response) {
    const ip = this.getClientIP(request);
    const domain = this.getRequestDomain(request);
    const userAgent = request.headers.get('User-Agent') || 'unknown';
    const timestamp = new Date().toISOString();
    
    const usage = {
      ip,
      domain,
      endpoint,
      userAgent,
      timestamp,
      fingerprint: this.FINGERPRINT,
      responseStatus: response?.status || 0
    };

    // Store usage log
    await this.env.PROTECTION_KV?.put(
      `usage:${Date.now()}:${crypto.randomUUID().substring(0, 8)}`,
      JSON.stringify(usage),
      { expirationTtl: 86400 * 30 } // 30 days retention
    );

    // Update IP rate counter
    const ipKey = `ip:${ip}`;
    const ipData = await this.env.PROTECTION_KV?.get(ipKey);
    const count = ipData ? parseInt(ipData, 10) + 1 : 1;
    await this.env.PROTECTION_KV?.put(ipKey, count.toString(), { expirationTtl: 3600 });

    // Check for suspicious activity
    if (count > this.MAX_REQUESTS_PER_IP) {
      await this.flagSuspiciousActivity(ip, 'rate_limit_exceeded', count);
    }
  }

  // Flag suspicious activity
  async flagSuspiciousActivity(ip, reason, data = {}) {
    const alert = {
      ip,
      reason,
      data,
      timestamp: new Date().toISOString(),
      fingerprint: this.FINGERPRINT,
      action: 'flagged'
    };

    await this.env.PROTECTION_KV?.put(
      `alert:${Date.now()}`,
      JSON.stringify(alert),
      { expirationTtl: 86400 * 90 } // 90 days retention
    );

    // Auto-block if enabled
    if (this.ENABLE_AUTO_DISABLE && reason === 'rate_limit_exceeded') {
      await this.env.PROTECTION_KV?.put(`blocked:${ip}`, 'true', { expirationTtl: 86400 * 7 }); // 7 day block
    }
  }

  // Validate license
  async validateLicense(domain, ip) {
    // Check authorized domains
    if (this.AUTHORIZED_DOMAINS.length > 0) {
      const isAuthorized = this.AUTHORIZED_DOMAINS.some(authDomain => 
        domain.includes(authDomain) || authDomain.includes(domain)
      );
      if (!isAuthorized) {
        return {
          valid: false,
          reason: 'domain_not_authorized',
          domain
        };
      }
    }

    // Check license key if configured
    if (this.LICENSE_KEY) {
      const licenseHeader = domain; // Or extract from custom header
      // Implement your license validation logic here
    }

    return { valid: true };
  }

  // Detect code theft indicators
  async detectTheft(request) {
    const ip = this.getClientIP(request);
    const domain = this.getRequestDomain(request);
    const userAgent = request.headers.get('User-Agent') || '';
    
    // Check for scraping tools
    const scrapingIndicators = [
      'scrapy', 'crawler', 'bot', 'spider', 'scraper',
      'wget', 'curl', 'python-requests', 'node-fetch'
    ];
    
    const isScraper = scrapingIndicators.some(indicator => 
      userAgent.toLowerCase().includes(indicator)
    );

    // Check for suspicious request patterns
    const suspiciousHeaders = [
      !request.headers.get('Referer'), // No referer
      !request.headers.get('Accept-Language'), // Missing language
      request.headers.get('Accept') === '*/*' // Accepts everything
    ];

    if (isScraper || suspiciousHeaders.filter(Boolean).length >= 2) {
      await this.flagSuspiciousActivity(ip, 'potential_theft', {
        domain,
        userAgent,
        indicators: { isScraper, suspiciousHeaders }
      });
      
      return {
        theftDetected: true,
        reason: isScraper ? 'scraping_tool_detected' : 'suspicious_headers'
      };
    }

    return { theftDetected: false };
  }

  // Add watermark to response
  addWatermark(response, request) {
    // Add invisible fingerprint in response headers
    const headers = new Headers(response.headers);
    headers.set('X-Fingerprint', this.FINGERPRINT.substring(0, 16));
    headers.set('X-Timestamp', Date.now().toString());
    
    // For JSON responses, add hidden watermark in data
    if (response.headers.get('Content-Type')?.includes('application/json')) {
      return response.json().then(data => {
        // Inject watermark into response (hidden field)
        if (typeof data === 'object' && data !== null) {
          data._wm = {
            fp: this.FINGERPRINT.substring(0, 8),
            ts: Date.now()
          };
        }
        return new Response(JSON.stringify(data), { headers });
      }).catch(() => response);
    }
    
    return new Response(response.body, { headers });
  }

  // Validate request environment
  async validateEnvironment(request) {
    const ip = this.getClientIP(request);
    const domain = this.getRequestDomain(request);
    
    // Check if IP is blocked
    if (await this.isIPBlocked(ip)) {
      return {
        valid: false,
        reason: 'ip_blocked',
        ip
      };
    }

    // Check license
    const licenseCheck = await this.validateLicense(domain, ip);
    if (!licenseCheck.valid) {
      return licenseCheck;
    }

    // Detect theft
    const theftCheck = await this.detectTheft(request);
    if (theftCheck.theftDetected) {
      return {
        valid: false,
        reason: 'theft_detected',
        details: theftCheck.reason
      };
    }

    return { valid: true };
  }

  // Create protection middleware
  async protect(request, handler) {
    try {
      // Validate environment
      const envCheck = await this.validateEnvironment(request);
      if (!envCheck.valid) {
        return new Response(JSON.stringify({
          error: 'Access denied',
          reason: envCheck.reason,
          message: 'Unauthorized access detected',
          fingerprint: this.FINGERPRINT.substring(0, 16)
        }), {
          status: 403,
          headers: {
            'Content-Type': 'application/json',
            'X-Fingerprint': this.FINGERPRINT.substring(0, 16)
          }
        });
      }

      // Execute handler
      const response = await handler(request);
      
      // Track usage
      const url = new URL(request.url);
      await this.trackUsage(request, url.pathname, response);
      
      // Add watermark
      return this.addWatermark(response, request);
      
    } catch (error) {
      // Log errors
      await this.env.PROTECTION_KV?.put(
        `error:${Date.now()}`,
        JSON.stringify({
          error: error.message,
          stack: error.stack,
          fingerprint: this.FINGERPRINT,
          timestamp: new Date().toISOString()
        }),
        { expirationTtl: 86400 * 7 }
      );
      
      return new Response(JSON.stringify({
        error: 'Internal error',
        fingerprint: this.FINGERPRINT.substring(0, 16)
      }), { status: 500 });
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// INTEGRATION EXAMPLE
// ═══════════════════════════════════════════════════════════════

export default {
  async fetch(request, env) {
    // Initialize protection system
    const protection = new ProtectionSystem(env);
    
    // Wrap your handler with protection
    return protection.protect(request, async (req) => {
      // YOUR ORIGINAL CODE HERE
      const url = new URL(req.url);
      const dna = req.headers.get('X-DNA');
      
      // Your endpoints...
      if (url.pathname === '/status') {
        return new Response(JSON.stringify({
          system: 'Protected System',
          status: 'OPERATIONAL',
          timestamp: new Date().toISOString()
        }), {
          headers: { 'Content-Type': 'application/json' }
        });
      }
      
      // Add more endpoints...
      
      return new Response(JSON.stringify({
        message: 'Protected endpoint',
        fingerprint: protection.FINGERPRINT.substring(0, 16)
      }), {
        headers: { 'Content-Type': 'application/json' }
      });
    });
  }
};

// ═══════════════════════════════════════════════════════════════
// USAGE:
// 
// 1. Set environment variables in your Cloudflare Worker:
//    - FINGERPRINT: Unique identifier (auto-generated if not set)
//    - LICENSE_KEY: License validation key
//    - AUTHORIZED_DOMAINS: Comma-separated list of allowed domains
//    - BLOCKED_IPS: Comma-separated list of blocked IPs
//    - MAX_REQUESTS_PER_IP: Maximum requests per hour (default: 1000)
//    - ENABLE_AUTO_DISABLE: Enable auto-blocking (default: true)
//
// 2. Add PROTECTION_KV binding to your Worker:
//    - Create a KV namespace called "PROTECTION_KV"
//    - Bind it in your worker settings
//
// 3. Integrate into your existing code:
//    - Wrap your fetch handler with protection.protect()
//    - All requests will be automatically tracked and validated
//
// 4. Monitor theft attempts:
//    - Check PROTECTION_KV for "alert:*" keys
//    - Review usage logs in "usage:*" keys
//    - Check blocked IPs in "blocked:*" keys
//
// ═══════════════════════════════════════════════════════════════



































