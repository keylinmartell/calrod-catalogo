<script setup lang="ts">
import { RouterLink } from 'vue-router'
</script>

<template>
  <footer class="footer">
    <div class="container footer__inner">
      <div class="footer__brand">
        <img class="footer__logo" src="/logo-new.png" alt="Repuestos CalRod" />
      </div>
      <p class="footer__note">
        Repuestos CalRod — catálogo de piezas de auto.
      </p>
      <nav class="footer__links">
        <RouterLink to="/terminos" class="footer__link">Términos y Condiciones</RouterLink>
        <span class="footer__sep" aria-hidden="true">·</span>
        <RouterLink to="/privacidad" class="footer__link">Política de Privacidad</RouterLink>
      </nav>
      <p class="footer__legal mono">
        © {{ new Date().getFullYear() }} CalRod
        <span class="footer__sep" aria-hidden="true">·</span>
        Desarrollado por
        <a
          class="footer__dev"
          href="https://wa.me/5359324394"
          target="_blank"
          rel="noopener"
        >
          KMartell
        </a>
      </p>
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
  gap: var(--space-3);
  padding-block: var(--space-6);
}

.footer__brand {
  display: flex;
  align-items: center;
  overflow: visible;
}

/* Logo más grande; márgenes negativos no alteran el padding del footer. */
.footer__logo {
  height: 220px;
  width: auto;
  margin-block: -72px;
}

@media (max-width: 520px) {
  .footer__logo {
    height: 190px;
    margin-block: -60px;
  }
}

.footer__note {
  color: var(--charcoal);
  max-width: 52ch;
  font-size: 0.9rem;
}

.footer__links {
  display: flex;
  align-items: center;
  gap: var(--space-1);
  flex-wrap: wrap;
  font-size: 0.85rem;
}

.footer__link {
  color: var(--blue-2);
  text-decoration: none;
  transition: color 0.15s ease;
}

.footer__link:hover {
  text-decoration: underline;
}

.footer__legal {
  color: var(--charcoal);
  font-size: 0.8rem;
}

.footer__sep {
  margin-inline: var(--space-2);
  color: var(--border-strong);
}

.footer__dev {
  color: var(--blue-2);
  text-decoration: none;
  transition: color 0.15s ease;
}

.footer__dev:hover {
  text-decoration: underline;
}
</style>
