<script setup lang="ts">
import { RouterLink } from 'vue-router'

const PHONE = '5356269303'
const waHref = `https://wa.me/${PHONE}`
</script>

<template>
  <footer class="footer">
    <div class="container footer__inner">
      <!-- Fila superior: Logo/Marca y Enlaces principales -->
      <div class="footer__main">
        <div class="footer__brand">
          <RouterLink to="/" class="footer__brand-link" aria-label="CalRod Inicio">
            <img class="footer__logo" src="/logo-new.png" alt="Repuestos CalRod" />
          </RouterLink>
          <p class="footer__tagline">
            Catálogo de repuestos y piezas automotrices con compatibilidad garantizada.
          </p>
        </div>

        <nav class="footer__nav" aria-label="Enlaces del pie de página">
          <RouterLink to="/" class="footer__link">Catálogo</RouterLink>
          <RouterLink to="/terminos" class="footer__link">Términos</RouterLink>
          <RouterLink to="/privacidad" class="footer__link">Privacidad</RouterLink>
          <a :href="waHref" target="_blank" rel="noopener noreferrer" class="footer__link footer__link--wa">
            <svg viewBox="0 0 24 24" fill="currentColor" class="footer__wa-icon">
              <path d="M12.04 2c-5.46 0-9.91 4.45-9.91 9.91 0 1.75.46 3.45 1.32 4.95L2.05 22l5.25-1.38c1.45.79 3.08 1.21 4.74 1.21 5.46 0 9.91-4.45 9.91-9.91 0-2.65-1.03-5.14-2.9-7.01A9.816 9.816 0 0 0 12.04 2z"/>
            </svg>
            Contacto WhatsApp
          </a>
        </nav>
      </div>

      <!-- Fila inferior: Copyright y Autoría -->
      <div class="footer__bottom">
        <p class="footer__copyright mono">
          © {{ new Date().getFullYear() }} CalRod. Todos los derechos reservados.
        </p>

        <div class="footer__credit">
          <a
            href="https://wa.me/5359324394?text=Hola%20KMartell,%20vi%20la%20web%20de%20CalRod%20y%20me%20gustar%C3%ADa%20cotizar%20un%20proyecto"
            target="_blank"
            rel="noopener noreferrer"
            class="dev-badge"
            title="¿Deseas una página web o sistema para tu negocio? Escríbeme por WhatsApp"
          >
            <span class="dev-badge__status" aria-hidden="true">
              <span class="dev-badge__dot"></span>
            </span>
            <span class="dev-badge__label">
              Desarrollado por <strong class="dev-badge__author">KMartell</strong>
            </span>
            <span class="dev-badge__cta">Cotizar web →</span>
          </a>
        </div>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.footer {
  border-top: 1px solid var(--border);
  background: var(--surface);
  margin-top: var(--space-8);
}

.footer__inner {
  display: flex;
  flex-direction: column;
  padding-block: var(--space-6) var(--space-5);
  gap: var(--space-5);
}

/* Fila principal */
.footer__main {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-5);
  flex-wrap: wrap;
}

.footer__brand {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  max-width: 420px;
}

.footer__brand-link {
  display: inline-flex;
  align-items: center;
  overflow: visible;
  height: 52px;
}

.footer__logo {
  height: 210px;
  width: auto;
  object-fit: contain;
  margin-block: -78px;
  margin-left: -28px;
  display: block;
}

.footer__tagline {
  color: var(--charcoal);
  font-size: 0.85rem;
  line-height: 1.45;
}

/* Navegación */
.footer__nav {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.footer__link {
  color: var(--charcoal);
  font-size: 0.88rem;
  font-weight: 500;
  text-decoration: none;
  transition: color 0.15s ease;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.footer__link:hover {
  color: var(--blue-2);
}

.footer__link--wa {
  color: #25d366;
}

.footer__link--wa:hover {
  color: #34e77b;
}

.footer__wa-icon {
  width: 15px;
  height: 15px;
}

/* Fila inferior */
.footer__bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: var(--space-4);
  border-top: 1px solid var(--border);
  flex-wrap: wrap;
  gap: var(--space-3);
  font-size: 0.78rem;
  color: var(--text-faint);
}

.footer__copyright {
  margin: 0;
}

.footer__credit {
  margin: 0;
  display: flex;
  align-items: center;
}

/* Badge de autoría interactivo */
.dev-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 4px 10px 4px 8px;
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  border-radius: 999px;
  text-decoration: none;
  color: var(--cream);
  font-size: 0.76rem;
  transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
}

.dev-badge:hover {
  background: linear-gradient(135deg, rgba(26, 61, 110, 0.35), rgba(74, 123, 184, 0.2));
  border-color: var(--blue-2);
  box-shadow: 0 0 14px rgba(74, 123, 184, 0.3);
  transform: translateY(-1px);
}

.dev-badge__status {
  display: flex;
  align-items: center;
  justify-content: center;
}

.dev-badge__dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--ok);
  box-shadow: 0 0 6px var(--ok);
}

.dev-badge__label {
  color: var(--charcoal);
  font-family: var(--font-body);
}

.dev-badge:hover .dev-badge__label {
  color: var(--cream);
}

.dev-badge__author {
  color: var(--cream);
  font-weight: 700;
}

.dev-badge__cta {
  font-family: var(--font-mono);
  font-size: 0.7rem;
  font-weight: 600;
  color: var(--blue-2);
  background: rgba(74, 123, 184, 0.12);
  padding: 2px 7px;
  border-radius: 999px;
  transition: background 0.15s ease, color 0.15s ease;
}

.dev-badge:hover .dev-badge__cta {
  background: var(--blue);
  color: #ffffff;
}

:root[data-theme='light'] .dev-badge {
  background: var(--surface);
  border-color: var(--border-strong);
}

:root[data-theme='light'] .dev-badge:hover {
  background: rgba(26, 61, 110, 0.06);
  border-color: var(--blue);
}

/* Responsive */
@media (max-width: 768px) {
  .footer__logo {
    height: 170px;
    margin-block: -60px;
    margin-left: -22px;
  }

  .footer__main {
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-4);
  }

  .footer__nav {
    gap: var(--space-3);
  }

  .footer__bottom {
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-2);
  }
}
</style>
