import { serverSupabaseServiceRole } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const { username } = getQuery(event)

    if (!username || typeof username !== 'string') {
        throw createError({
            statusCode: 400,
            statusMessage: 'Bad Request',
            message: 'username格式錯誤',
        })
    }
    const client = serverSupabaseServiceRole(event)
    const { data, error } = await client
        .from('profiles')
        .select('username')
        .eq('username', username)
        .maybeSingle()

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: 'Internal Server Error',
            message: '伺服器發生錯誤',
        })
    }
    return { available: !data }
})
