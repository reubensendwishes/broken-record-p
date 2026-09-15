export default async function useDarkMode() {
    const supabase = useSupabaseClient()
    const user = useSupabaseUser()

    const { data: isDarkMode } = await useAsyncData(
        'dark-mode-preference',
        async () => {
            const { data } = await supabase
                .from('profiles')
                .select('dark_mode')
                .eq('id', user.value!.sub)
                .single()
            return data?.dark_mode ?? false
        },
        {
            default: () => false,
        },
    )

    const setDarkMode = async (value: boolean) => {
        isDarkMode.value = value
        const { data: newProfile } = await supabase
            .from('profiles')
            .update({ dark_mode: value })
            .eq('id', user.value!.sub)
            .select()
            .single()
        if (newProfile) {
            isDarkMode.value = newProfile.dark_mode
        }
    }
    return { isDarkMode, setDarkMode }
}
