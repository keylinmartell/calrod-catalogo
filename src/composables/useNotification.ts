import { ref } from 'vue'

export type NotificationType = 'info' | 'warning' | 'error' | 'success' | 'auth'

export interface NotificationAction {
  label: string
  onClick: () => void
}

export interface NotificationItem {
  id: string
  type: NotificationType
  title: string
  message: string
  action?: NotificationAction
  duration?: number
}

const notifications = ref<NotificationItem[]>([])

export function useNotification() {
  function showNotification(item: Omit<NotificationItem, 'id'>) {
    // Evitar spam de notificaciones idénticas
    notifications.value = notifications.value.filter((n) => n.title !== item.title)

    const id = Math.random().toString(36).slice(2, 9)
    const notif: NotificationItem = {
      ...item,
      id,
      duration: item.duration ?? 5000,
    }
    notifications.value.push(notif)

    if (notif.duration && notif.duration > 0) {
      setTimeout(() => {
        removeNotification(id)
      }, notif.duration)
    }
    return id
  }

  function removeNotification(id: string) {
    notifications.value = notifications.value.filter((n) => n.id !== id)
  }

  function showAuthAlert(
    message = 'Debes iniciar sesión para agregar vehículos a tus favoritos.',
    onActionClick?: () => void,
  ) {
    return showNotification({
      type: 'auth',
      title: 'Acceso requerido',
      message,
      duration: 6000,
      action: {
        label: 'Iniciar sesión',
        onClick: () => {
          if (onActionClick) {
            onActionClick()
          }
        },
      },
    })
  }

  return {
    notifications,
    showNotification,
    removeNotification,
    showAuthAlert,
  }
}
