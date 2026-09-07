<script setup lang="ts">
import { useNotification, type NotificationItem } from '@/composables/useNotification'
import { useAuthPanel } from '@/composables/useAuthPanel'

const { notifications, removeNotification } = useNotification()
const { openPanel } = useAuthPanel()

function handleAction(notif: NotificationItem) {
  if (notif.type === 'auth') {
    openPanel('login')
  }
  if (notif.action?.onClick) {
    notif.action.onClick()
  }
  removeNotification(notif.id)
}
</script>

<template>
  <Teleport to="body">
    <div class="toast-container" aria-live="polite" aria-atomic="true">
      <TransitionGroup name="toast-anim" tag="div" class="toast-list">
        <div
          v-for="notif in notifications"
          :key="notif.id"
          class="toast-item"
          :class="`toast-item--${notif.type}`"
          role="alert"
        >
          <!-- Icono visual -->
          <div class="toast-item__icon-wrap">
            <!-- Auth / Lock icon -->
            <svg v-if="notif.type === 'auth'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
              <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
            </svg>
            <!-- Warning -->
            <svg v-else-if="notif.type === 'warning'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>
              <line x1="12" y1="9" x2="12" y2="13"/>
              <line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
            <!-- Error -->
            <svg v-else-if="notif.type === 'error'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"/>
              <line x1="15" y1="9" x2="9" y2="15"/>
              <line x1="9" y1="9" x2="15" y2="15"/>
            </svg>
            <!-- Success -->
            <svg v-else-if="notif.type === 'success'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
              <polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
            <!-- Info -->
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="16" x2="12" y2="12"/>
              <line x1="12" y1="8" x2="12.01" y2="8"/>
            </svg>
          </div>

          <!-- Contenido del texto -->
          <div class="toast-item__content">
            <div class="toast-item__header">
              <span class="toast-item__title">{{ notif.title }}</span>
              <button
                type="button"
                class="toast-item__close"
                aria-label="Cerrar notificación"
                @click="removeNotification(notif.id)"
              >
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                  <line x1="18" y1="6" x2="6" y2="18"/>
                  <line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
              </button>
            </div>
            <p class="toast-item__message">{{ notif.message }}</p>

            <!-- Botón de acción opcional -->
            <div v-if="notif.action" class="toast-item__actions">
              <button
                type="button"
                class="toast-item__btn-action"
                @click="handleAction(notif)"
              >
                {{ notif.action.label }}
              </button>
            </div>
          </div>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<style scoped>
.toast-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 100020;
  display: flex;
  flex-direction: column;
  pointer-events: none;
  max-width: 420px;
  width: calc(100% - 40px);
}

.toast-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.toast-item {
  pointer-events: auto;
  position: relative;
  background: rgba(15, 20, 29, 0.96);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 14px;
  padding: 14px 16px;
  box-shadow:
    0 16px 36px rgba(0, 0, 0, 0.55),
    0 0 0 1px rgba(255, 255, 255, 0.05);
  display: flex;
  align-items: flex-start;
  gap: 14px;
  color: #f8fafc;
  overflow: hidden;
  transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}

/* Tipos de toasts con sutiles acentos */
.toast-item--auth,
.toast-item--warning {
  border-color: rgba(245, 158, 11, 0.4);
  box-shadow:
    0 16px 36px rgba(0, 0, 0, 0.55),
    0 0 20px rgba(245, 158, 11, 0.15);
}

.toast-item--auth .toast-item__icon-wrap,
.toast-item--warning .toast-item__icon-wrap {
  background: rgba(245, 158, 11, 0.15);
  color: #f59e0b;
  border: 1px solid rgba(245, 158, 11, 0.3);
}

.toast-item--error {
  border-color: rgba(239, 68, 68, 0.4);
  box-shadow:
    0 16px 36px rgba(0, 0, 0, 0.55),
    0 0 20px rgba(239, 68, 68, 0.15);
}

.toast-item--error .toast-item__icon-wrap {
  background: rgba(239, 68, 68, 0.15);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.toast-item--success {
  border-color: rgba(34, 197, 94, 0.4);
  box-shadow:
    0 16px 36px rgba(0, 0, 0, 0.55),
    0 0 20px rgba(34, 197, 94, 0.15);
}

.toast-item--success .toast-item__icon-wrap {
  background: rgba(34, 197, 94, 0.15);
  color: #22c55e;
  border: 1px solid rgba(34, 197, 94, 0.3);
}

.toast-item--info {
  border-color: rgba(74, 123, 184, 0.4);
  box-shadow:
    0 16px 36px rgba(0, 0, 0, 0.55),
    0 0 20px rgba(74, 123, 184, 0.15);
}

.toast-item--info .toast-item__icon-wrap {
  background: rgba(74, 123, 184, 0.15);
  color: #4a7bb8;
  border: 1px solid rgba(74, 123, 184, 0.3);
}

.toast-item__icon-wrap {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: grid;
  place-items: center;
  flex-shrink: 0;
}

.toast-item__icon-wrap svg {
  width: 20px;
  height: 20px;
}

.toast-item__content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.toast-item__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.toast-item__title {
  font-size: 0.92rem;
  font-weight: 700;
  color: #ffffff;
  letter-spacing: -0.01em;
}

.toast-item__close {
  width: 22px;
  height: 22px;
  border-radius: 6px;
  background: transparent;
  border: none;
  color: #94a3b8;
  cursor: pointer;
  display: grid;
  place-items: center;
  padding: 0;
  transition: all 0.15s ease;
}

.toast-item__close:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #ffffff;
}

.toast-item__close svg {
  width: 14px;
  height: 14px;
}

.toast-item__message {
  font-size: 0.84rem;
  color: #cbd5e1;
  line-height: 1.4;
  margin-top: 3px;
}

.toast-item__actions {
  margin-top: 10px;
  display: flex;
  gap: 8px;
}

.toast-item__btn-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 6px 14px;
  border-radius: 8px;
  background: linear-gradient(135deg, var(--blue), var(--blue-2));
  border: 1px solid var(--blue-2);
  color: #ffffff;
  font-size: 0.8rem;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(26, 61, 110, 0.35);
  transition: all 0.15s ease;
}

.toast-item__btn-action:hover {
  filter: brightness(1.1);
  transform: translateY(-1px);
  box-shadow: 0 4px 14px rgba(26, 61, 110, 0.5);
}

/* ── Animaciones ─────────────────────────────────────────────────────────── */
.toast-anim-enter-active,
.toast-anim-leave-active {
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.toast-anim-enter-from {
  opacity: 0;
  transform: translateY(-16px) scale(0.95);
}

.toast-anim-leave-to {
  opacity: 0;
  transform: translateX(30px) scale(0.95);
}

@media (max-width: 600px) {
  .toast-container {
    top: 12px;
    left: 12px;
    right: 12px;
    width: auto;
    max-width: 100%;
  }
}
</style>
