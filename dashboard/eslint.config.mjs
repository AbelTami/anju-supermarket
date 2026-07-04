// @ts-check
import withNuxt from './.nuxt/eslint.config.mjs'

export default withNuxt({
  rules: {
    'vue/no-multiple-template-root': 'off',
    'vue/max-attributes-per-line': ['error', { singleline: 3 }],
    // antfu conventions
    'style/semi': ['error', 'never'],
    'style/quotes': ['error', 'single', { avoidEscape: true }],
    'style/comma-dangle': ['error', 'always-multiline'],
    'style/indent': ['error', 2],
    'style/arrow-parens': ['error', 'always'],
    'style/brace-style': ['error', '1tbs', { allowSingleLine: true }],
    'import/order': ['warn', {
      groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
      'newlines-between': 'ignore',
    }],
    'no-console': 'warn',
    'prefer-const': 'error',
    'unused-imports/no-unused-imports': 'warn',
  },
})
