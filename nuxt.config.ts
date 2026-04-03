// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    compatibilityDate: '2025-07-15',
    devtools: { enabled: true },

    app: {
        head: {
            link: [
                { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
            ],
        },
    },

    css: ['~/assets/main.scss'],

    modules: ['@nuxt/eslint', '@nuxtjs/google-fonts'],
    googleFonts: {
        families: {
            Huninn: true,
        },
    },
})
