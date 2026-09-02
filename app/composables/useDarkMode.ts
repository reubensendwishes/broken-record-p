export default function useDarkMode() {
    const isDarkMode = useState('isDarkMode', () => false)
    return { isDarkMode }
}
