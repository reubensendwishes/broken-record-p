export default function useDarkMode() {
    const supabase = useSupabaseClient()
    const user = useSupabaseUser()

    const isDarkMode = useState('is-dark-mode', () => false)
    const fetchDarkMode = async () => {
        const { data } = await supabase
            .from('user_settings')
            .select('dark_mode')
            .eq('id', user.value!.sub)
            .single()

        isDarkMode.value = data?.dark_mode ?? false
    }

    const setDarkMode = async (value: boolean) => {
        isDarkMode.value = value
        const { data: newSettings } = await supabase
            .from('user_settings')
            .update({ dark_mode: value })
            .eq('id', user.value!.sub)
            .select()
            .single()
        if (newSettings) {
            isDarkMode.value = newSettings.dark_mode
        }
    }
    return { isDarkMode, fetchDarkMode, setDarkMode }
}
