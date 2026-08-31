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
    <h1 class="legal__title">Política de Privacidad</h1>
    <p class="legal__updated mono">Última actualización: {{ updated }}</p>

    <section class="legal__section">
      <h2>1. Responsable</h2>
      <p>
        Esta Política describe cómo Repuestos CalRod (en adelante, «el Sitio»)
        trata los datos personales de quienes usan el catálogo y el panel de
        administración.
      </p>
    </section>

    <section class="legal__section">
      <h2>2. Datos que recopilamos</h2>
      <p>
        Para navegar el catálogo público no se requiere cuenta ni datos
        personales. Para el panel de administración recopilamos únicamente los
        datos necesarios para autenticar al personal autorizado:
      </p>
      <ul>
        <li>Dirección de correo electrónico.</li>
        <li>
          Si inicias sesión con Google: tu nombre, correo y foto de perfil que
          Google nos comparte a través del proceso de autenticación.
        </li>
      </ul>
    </section>

    <section class="legal__section">
      <h2>3. Cómo usamos los datos</h2>
      <p>
        Los datos de autenticación se usan exclusivamente para verificar la
        identidad del personal autorizado y dar acceso al panel de
        administración. No vendemos ni compartimos estos datos con terceros con
        fines comerciales.
      </p>
    </section>

    <section class="legal__section">
      <h2>4. Autenticación con Google</h2>
      <p>
        El inicio de sesión con Google se realiza mediante OAuth 2.0. Cuando
        eliges esta opción, Google verifica tu identidad y nos comparte la
        información básica de tu perfil. No accedemos a tu contraseña de Google
        ni a datos ajenos a la autenticación. Puedes revocar el acceso en
        cualquier momento desde la configuración de tu cuenta de Google.
      </p>
    </section>

    <section class="legal__section">
      <h2>5. Almacenamiento y proveedores</h2>
      <p>
        La autenticación y el almacenamiento de datos se gestionan mediante
        Supabase. Los datos se conservan mientras la cuenta del personal siga
        activa y se eliminan cuando deja de ser necesaria.
      </p>
    </section>

    <section class="legal__section">
      <h2>6. Cookies y almacenamiento local</h2>
      <p>
        El Sitio guarda la sesión de inicio en el almacenamiento local del
        navegador para mantenerte autenticado entre recargas. No usamos cookies
        de rastreo ni publicidad de terceros.
      </p>
    </section>

    <section class="legal__section">
      <h2>7. Tus derechos</h2>
      <p>
        Puedes solicitar el acceso, la corrección o la eliminación de tus datos
        personales escribiéndonos por los canales de contacto del negocio.
      </p>
    </section>

    <section class="legal__section">
      <h2>8. Contacto</h2>
      <p>
        Para ejercer tus derechos o resolver dudas sobre esta Política,
        escríbenos por
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

.legal__section p,
.legal__section li {
  color: var(--charcoal);
  line-height: 1.7;
}

.legal__section ul {
  padding-left: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.legal__section a {
  color: var(--blue-2);
}
</style>
