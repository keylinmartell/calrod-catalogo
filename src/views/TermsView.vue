<script setup lang="ts">
import { onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useAppLoading } from '@/composables/useAppLoading'

// Página estática sin datos: quitamos el overlay de arranque al montar.
onMounted(() => useAppLoading().finishBoot())

const updated = '31 de agosto de 2026'
const CONTACT = 'https://wa.me/5356269303'
</script>

<template>
  <div class="container legal">
    <RouterLink to="/" class="legal__back mono">← Volver al catálogo</RouterLink>
    <h1 class="legal__title">Términos y Condiciones</h1>
    <p class="legal__updated mono">Última actualización: {{ updated }}</p>

    <section class="legal__section">
      <h2>1. Objeto</h2>
      <p>
        Repuestos CalRod (en adelante, «el Sitio») es un catálogo en línea de
        piezas y refacciones de automóvil. El Sitio ofrece información sobre
        productos, su compatibilidad con distintos vehículos y datos de
        contacto. El uso del Sitio implica la aceptación de estos Términos.
      </p>
    </section>

    <section class="legal__section">
      <h2>2. Información del catálogo</h2>
      <p>
        Procuramos que la información de piezas, precios, disponibilidad y
        compatibilidad sea correcta y esté actualizada. Sin embargo, los datos
        pueden contener errores u omisiones y están sujetos a cambios sin previo
        aviso. La compatibilidad mostrada es orientativa: confirma siempre con
        nosotros antes de comprar.
      </p>
    </section>

    <section class="legal__section">
      <h2>3. Precios y disponibilidad</h2>
      <p>
        Los precios se muestran a título informativo y pueden variar. La
        disponibilidad indicada no constituye una garantía de existencias. La
        compra, el pago y la entrega se acuerdan directamente por los canales de
        contacto del negocio.
      </p>
    </section>

    <section class="legal__section">
      <h2>4. Cuentas y acceso</h2>
      <p>
        El acceso al panel de administración está restringido al personal
        autorizado. El inicio de sesión puede realizarse mediante correo y
        contraseña o mediante autenticación con Google. Eres responsable de
        mantener la confidencialidad de tus credenciales.
      </p>
    </section>

    <section class="legal__section">
      <h2>5. Propiedad intelectual</h2>
      <p>
        Las marcas, logotipos y contenidos del Sitio pertenecen a sus
        respectivos titulares. Las marcas de vehículos y fabricantes se citan
        únicamente con fines de identificación de compatibilidad.
      </p>
    </section>

    <section class="legal__section">
      <h2>6. Limitación de responsabilidad</h2>
      <p>
        El Sitio se ofrece «tal cual». No nos hacemos responsables de daños
        derivados de la instalación o el uso incorrecto de las piezas, ni de
        decisiones tomadas con base en información del catálogo sin confirmación
        previa.
      </p>
    </section>

    <section class="legal__section">
      <h2>7. Contacto</h2>
      <p>
        Para cualquier duda sobre estos Términos, escríbenos por
        <a :href="CONTACT" target="_blank" rel="noopener noreferrer">WhatsApp</a>.
      </p>
    </section>
  </div>
</template>

<style scoped>
.legal {
  max-width: 72ch;
  padding-block: var(--space-7);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.legal__back {
  color: var(--blue-2);
  text-decoration: none;
  font-size: 0.85rem;
}
.legal__back:hover { text-decoration: underline; }

.legal__title {
  font-family: var(--font-display);
  font-size: 2rem;
  color: var(--cream);
}

.legal__updated {
  color: var(--charcoal);
  font-size: 0.8rem;
  margin-top: calc(var(--space-3) * -1);
}

.legal__section h2 {
  font-size: 1.1rem;
  color: var(--cream);
  margin-bottom: var(--space-2);
}

.legal__section p {
  color: var(--charcoal);
  line-height: 1.7;
}

.legal__section a {
  color: var(--blue-2);
}
</style>
