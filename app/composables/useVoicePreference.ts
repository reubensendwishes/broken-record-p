export async function useVoicePreference() {
    // types
    type Voice = {
        en_us_voice_candidates: string[]
        zh_tw_voice_candidates: string[]
    }

    const enUsVoice = useState<SpeechSynthesisVoice | null>(
        'en-us-voice',
        () => null,
    )
    const zhTwVoice = useState<SpeechSynthesisVoice | null>(
        'en-tw-voice',
        () => null,
    )
    const voices = useState<SpeechSynthesisVoice[]>('speech-voices', () => [])
    const isVoicesLoading = useState('is-voices-loading', () => true)

    const supabase = useSupabaseClient()
    const user = useSupabaseUser()

    const { data: settings } = await useAsyncData(
        'voice-preference-candidates',
        async () => {
            const { data } = await supabase
                .from('user_settings')
                .select('en_us_voice_candidates, zh_tw_voice_candidates')
                .eq('id', user.value!.sub)
                .single()
            return (
                data ?? {
                    en_us_voice_candidates: [],
                    zh_tw_voice_candidates: [],
                }
            )
        },
        {
            default: (): Voice => ({
                en_us_voice_candidates: [],
                zh_tw_voice_candidates: [],
            }),
        },
    )

    const enUsVoices = computed(() =>
        voices.value.filter(
            (voice) => voice.lang === 'en-US' || voice.lang === 'en_US',
        ),
    )
    const zhTwVoices = computed(() =>
        voices.value.filter(
            (voice) => voice.lang === 'zh-TW' || voice.lang === 'zh_TW_#Hant',
        ),
    )
    const selectVoice = async (
        voice: SpeechSynthesisVoice,
        lang: 'zh-TW' | 'en-US',
    ) => {
        if (lang === 'zh-TW') {
            zhTwVoice.value = voice
            const newCandidates = settings.value.zh_tw_voice_candidates
                .filter((candidate) => candidate !== voice.name)
                .slice(0, 2)
            newCandidates.unshift(voice.name)
            const { data: newSettings } = await supabase
                .from('user_settings')
                .update({ zh_tw_voice_candidates: newCandidates })
                .eq('id', user.value!.sub)
                .select()
                .single()
            if (newSettings) {
                settings.value = newSettings
            }
        } else if (lang === 'en-US') {
            enUsVoice.value = voice
            const newCandidates = settings.value.en_us_voice_candidates
                .filter((candidate) => candidate !== voice.name)
                .slice(0, 2)
            newCandidates.unshift(voice.name)

            const { data: newSettings } = await supabase
                .from('user_settings')
                .update({ en_us_voice_candidates: newCandidates })
                .eq('id', user.value!.sub)
                .select()
                .single()
            if (newSettings) {
                settings.value = newSettings
            }
        }
    }

    watch(voices, (newVoices) => {
        if (newVoices.length === 0) return
        if (!enUsVoice.value && enUsVoices.value.length > 0) {
            let defaultVoice
            if (settings.value) {
                for (const candidate of settings.value.en_us_voice_candidates) {
                    const voice =
                        enUsVoices.value.find(
                            (voice) => voice.name === candidate,
                        ) ?? null
                    if (voice) {
                        defaultVoice = voice
                        break
                    }
                }
            }
            if (!defaultVoice) {
                defaultVoice =
                    enUsVoices.value.find((voice) =>
                        voice.name.includes('Google'),
                    ) ?? enUsVoices.value[0]!
            }
            enUsVoice.value = defaultVoice
        }
        if (!zhTwVoice.value && zhTwVoices.value.length > 0) {
            let defaultVoice
            if (settings.value) {
                for (const candidate of settings.value.zh_tw_voice_candidates) {
                    const voice =
                        zhTwVoices.value.find(
                            (voice) => voice.name === candidate,
                        ) ?? null
                    if (voice) {
                        defaultVoice = voice
                        break
                    }
                }
            }
            if (!defaultVoice) {
                defaultVoice =
                    zhTwVoices.value.find((voice) =>
                        voice.name.includes('Google'),
                    ) ?? zhTwVoices.value[0]!
            }
            zhTwVoice.value = defaultVoice
        }
    })
    return {
        enUsVoice,
        enUsVoices,
        zhTwVoice,
        zhTwVoices,
        selectVoice,
        isVoicesLoading,
    }
}
