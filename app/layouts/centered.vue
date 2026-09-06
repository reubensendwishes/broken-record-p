<template>
    <div class="d-flex-row centered-layout">
        <slot />
    </div>
</template>

<style scoped>
    .centered-layout {
        width: 100%;
        min-height: 100dvh;
        justify-content: center;
        align-items: center;
    }
</style>
