<template>
    <div class="bg-default text-primary">
        <NuxtRouteAnnouncer />
        <NuxtPage />
    </div>
</template>
<script lang="ts" setup>
    useHead({
        link: [
            {
                rel: 'stylesheet',
                href: 'https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,FILL@20..48,0..1&icon_names=add,arrow_back,arrow_left,arrow_right,close,content_copy,dark_mode,delete,drag_pan,edit,keyboard_arrow_down,keyboard_arrow_right,light_mode,menu,play_arrow,repeat,skip_next,skip_previous,volume_up',
            },
        ],
    })
</script>
