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

  runtimeConfig: {
    apiBase: 'http://localhost:8000',
  },

  routeRules: {
    '/api/**': {
      cors: true,
      headers: {
        'Cross-Origin-Resource-Policy': 'same-origin',
      },
    },
  },

  compatibilityDate: '2025-07-11',

  eslint: {
    config: {
      stylistic: {
        commaDangle: 'always-multiline',
        braceStyle: '1tbs',
      },
    },
  },
})
