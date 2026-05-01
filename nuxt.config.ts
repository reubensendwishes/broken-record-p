// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    compatibilityDate: '2025-07-15',
    devtools: { enabled: true },

    app: {
        head: {
            meta: [
                {
                    name: 'viewport',
                    content:
                        'width=device-width, initial-scale=1, viewport-fit=cover',
                },
            ],
            link: [
                { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
            ],
        },
    },

    css: ['~/assets/main.scss'],

    modules: ['@nuxt/eslint', '@nuxtjs/supabase', '@nuxt/fonts'],
    fonts: {
        families: [
            {
                name: 'Chiron GoRound TC Variable',
                provider: 'fontsource',
            },
            {
                name: 'Material Symbols Rounded',
                provider: 'googleicons',
                providerOptions: {
                    googleicons: {
                        experimental: {
                            glyphs: [
                                'add',
                                'arrow_back',
                                'arrow_left',
                                'arrow_right',
                                'close',
                                'content_copy',
                                'dark_mode',
                                'delete',
                                'drag_pan',
                                'edit',
                                'keyboard_arrow_down',
                                'keyboard_arrow_right',
                                'light_mode',
                                'menu',
                                'play_arrow',
                                'play_circle',
                                'repeat',
                                'search',
                                'settings',
                                'skip_next',
                                'skip_previous',
                                'volume_up',
                            ],
                        },
                    },
                },
            },
        ],
    },
    supabase: {
        redirect: false,
    },
})
