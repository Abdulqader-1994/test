<template>
  <div class="flex flex-col items-center justify-center overflow-hidden" :dir="textDirection" ref="mainContainer">
    <!-- Main Content -->
    <HeaderNav class="w-full px-5" v-if="route.path != '/chat'" />
    <RouterView class="max-w-[1200px] px-5" />
    <AppFooter v-if="route.path != '/chat'" />

    <!-- Footer Links -->
    <div class="w-full">
      <div class="flex flex-row justify-between items-center max-w-[1200px] px-2 mx-auto gap-2 text-xs">
        <div class="whitespace-nowrap">Ailence Team@2025</div>
        <div class="flex flex-row">
          <RouterLink to="/terms" class="whitespace-nowrap">Terms of Service</RouterLink>
          <span class="mx-1">|</span>
          <RouterLink to="/privacy" class="whitespace-nowrap">Privacy Policy</RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { RouterView, RouterLink, useRoute } from 'vue-router';
import HeaderNav from './components/headerNav.vue';
import AppFooter from './components/appFooter.vue';
import { useI18n } from 'vue-i18n';
import { computed } from 'vue';

const route = useRoute()

const { locale } = useI18n();
const textDirection = computed(() => (locale.value === 'ar' ? 'rtl' : 'ltr'));
</script>
