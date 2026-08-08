<template>
  <footer class="footer">
    <div class="container footer__inner">
      <div class="footer__brand">
        <img class="footer__logo" src="/logo.png" alt="Respuestos CalRod" />
      </div>
      <p class="footer__note">
        Respuestos CalRod — catálogo de piezas de auto.
      </p>
      <p class="footer__legal mono">© {{ new Date().getFullYear() }} CalRod</p>
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
}

.footer__logo {
  height: 250px;
  width: auto;
  margin-top: -75px;
  margin-bottom: -75px;
  margin-left: -24px;
}

.footer__note {
  color: var(--charcoal);
  max-width: 52ch;
  font-size: 0.9rem;
}

.footer__legal {
  color: var(--charcoal);
  font-size: 0.8rem;
}
</style>
