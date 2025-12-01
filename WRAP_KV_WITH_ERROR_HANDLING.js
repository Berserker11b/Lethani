// Helper function to wrap KV operations with error handling
function safeKVOperation(operation, fallback = null) {
  return async function(...args) {
    try {
      return await operation(...args);
    } catch (error) {
      console.error('KV operation error:', error);
      return fallback;
    }
  };
}

// Wrap all KV operations
export function wrapKVWithErrorHandling(env) {
  if (!env.WARDOG_KV) {
    // Create mock KV if not available
    env.WARDOG_KV = {
      async get(key) { return null; },
      async put(key, value, options) { return; },
      async list(options) { return { keys: [] }; },
      async delete(key) { return; }
    };
    return env;
  }

  const originalKV = env.WARDOG_KV;
  
  // Wrap with error handling
  env.WARDOG_KV = {
    async get(key) {
      try {
        return await originalKV.get(key);
      } catch (error) {
        console.error(`KV get error for key ${key}:`, error);
        return null;
      }
    },
    
    async put(key, value, options) {
      try {
        return await originalKV.put(key, value, options);
      } catch (error) {
        console.error(`KV put error for key ${key}:`, error);
        // Continue without storing
      }
    },
    
    async list(options) {
      try {
        return await originalKV.list(options);
      } catch (error) {
        console.error('KV list error:', error);
        return { keys: [] };
      }
    },
    
    async delete(key) {
      try {
        return await originalKV.delete(key);
      } catch (error) {
        console.error(`KV delete error for key ${key}:`, error);
        // Continue without deleting
      }
    }
  };
  
  return env;
}


