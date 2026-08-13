<template>
    <div class="backdrop" />
</template>
<style scoped>
    .backdrop {
        width: 100%;
        height: 100%;
        background-color: rgba(var(--color-primary-subtle-rgb), 0.2);
        backdrop-filter: brightness(90%) blur(1px);
        pointer-events: auto;
    }
</style>
