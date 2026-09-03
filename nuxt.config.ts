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
                                'album',
                                'arrow_back',
                                'arrow_forward',
                                'arrow_left',
                                'arrow_right',
                                'check_circle',
                                'close',
                                'collapse_all',
                                'content_copy',
                                'dark_mode',
                                'delete',
                                'drag_pan',
                                'edit',
                                'error',
                                'history',
                                'keyboard_arrow_down',
                                'keyboard_arrow_right',
                                'light_mode',
                                'list_arrow',
                                'menu',
                                'more_horiz',
                                'pin_drop',
                                'person',
                                'play_arrow',
                                'play_circle',
                                'repeat',
                                'replay',
                                'search',
                                'settings',
                                'skip_next',
                                'skip_previous',
                                'star',
                                'visibility',
                                'visibility_off',
                                'volume_off',
                                'volume_up',
                            ],
                        },
                    },
                },
            },
        ],
    },
    supabase: {
        redirectOptions: {
            login: '/login',
            callback: '/confirm',
            exclude: ['/signup'],
            saveRedirectToCookie: true,
        },
    },
})
