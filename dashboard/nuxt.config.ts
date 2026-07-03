// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: [
    '@nuxt/eslint',
    '@nuxt/ui',
    '@vueuse/nuxt',
  ],

  devtools: {
    enabled: true,
  },

  css: ['~/assets/css/main.css'],


  security: {
    headers: {
      strictTransportSecurity: false,
      contentSecurityPolicy: {
        'default-src': ["'self'"],
        'script-src': ["'self'", "'unsafe-inline'", "'unsafe-eval'", 'blob:'],
        'style-src': ["'self'", "'unsafe-inline'"],
        'img-src': ["'self'", 'https:', 'data:', 'http://localhost:8000', 'https://picsum.photos'],
        'connect-src': ["'self'", 'http://localhost:8000', 'https://world.openfoodfacts.org'],
        'worker-src': ["'self'", 'blob:'],
      },
      xXSSProtection: '1; mode=block',
    },
    requestSizeLimiter: {
      maxRequestSizeInBytes: 5 * 1024 * 1024, // 5MB
    },
    rateLimiter: {
      tokensPerInterval: 100,
      interval: 60000,
    },
  },

  routeRules: {
    '/api/**': {
      cors: true,
      headers: {
        'Cross-Origin-Resource-Policy': 'same-origin',
      },
    },
  },

  runtimeConfig: {
    apiBase: 'http://localhost:8000',
  },

  compatibilityDate: '2024-07-11',

  eslint: {
    config: {
      stylistic: {
        commaDangle: 'never',
        braceStyle: '1tbs',
      },
    },
  },
})
