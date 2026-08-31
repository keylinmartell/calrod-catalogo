<script setup lang="ts">
// Botón flotante de WhatsApp, estilo webs modernas: fijo abajo a la derecha,
// abre el chat del número del negocio en una pestaña nueva.
const PHONE = '5356269303'
const href = `https://wa.me/${PHONE}`
</script>

<template>
  <a
    :href="href"
    class="wa-fab"
    target="_blank"
    rel="noopener noreferrer"
    aria-label="Escríbenos por WhatsApp"
  >
    <svg
      class="wa-fab__icon"
      viewBox="0 0 32 32"
      fill="currentColor"
      aria-hidden="true"
    >
      <path
        d="M16.004 3.2c-7.06 0-12.8 5.74-12.8 12.8 0 2.258.594 4.462 1.72 6.4L3.2 28.8l6.56-1.72a12.74 12.74 0 0 0 6.244 1.62h.006c7.06 0 12.8-5.74 12.8-12.8 0-3.42-1.332-6.634-3.75-9.052A12.72 12.72 0 0 0 16.004 3.2Zm0 23.36h-.004a10.56 10.56 0 0 1-5.384-1.474l-.386-.23-3.894 1.02 1.04-3.796-.252-.39a10.55 10.55 0 0 1-1.616-5.62c0-5.868 4.776-10.64 10.648-10.64a10.57 10.57 0 0 1 7.524 3.12 10.56 10.56 0 0 1 3.116 7.526c0 5.868-4.776 10.64-10.642 10.64Zm5.834-7.964c-.32-.16-1.892-.934-2.184-1.04-.293-.107-.507-.16-.72.16-.213.32-.826 1.04-1.013 1.253-.187.213-.373.24-.693.08-.32-.16-1.35-.498-2.57-1.586-.95-.847-1.592-1.894-1.778-2.214-.187-.32-.02-.493.14-.652.144-.143.32-.373.48-.56.16-.187.213-.32.32-.533.107-.213.053-.4-.027-.56-.08-.16-.72-1.734-.986-2.374-.26-.624-.523-.54-.72-.55l-.613-.01c-.213 0-.56.08-.853.4-.293.32-1.12 1.094-1.12 2.667 0 1.574 1.146 3.094 1.306 3.307.16.213 2.253 3.44 5.46 4.826.763.33 1.358.527 1.822.674.766.244 1.463.21 2.014.127.615-.092 1.892-.774 2.158-1.52.267-.747.267-1.387.187-1.52-.08-.134-.293-.214-.613-.374Z"
      />
    </svg>
  </a>
</template>

<style scoped>
.wa-fab {
  position: fixed;
  right: var(--space-5);
  bottom: var(--space-5);
  z-index: 90;
  width: 56px;
  height: 56px;
  display: grid;
  place-items: center;
  border-radius: 50%;
  background: #25d366;
  color: #fff;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.35);
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

.wa-fab:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 10px 24px rgba(37, 211, 102, 0.45);
}

.wa-fab:active {
  transform: translateY(0) scale(0.98);
}

.wa-fab__icon {
  width: 32px;
  height: 32px;
}

@media (max-width: 520px) {
  .wa-fab {
    right: var(--space-4);
    bottom: var(--space-4);
    width: 52px;
    height: 52px;
  }
  .wa-fab__icon {
    width: 29px;
    height: 29px;
  }
}
</style>
