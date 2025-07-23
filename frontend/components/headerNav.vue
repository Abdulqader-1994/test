<template>
  <nav class="flex flex-row justify-between items-center py-2 text-lg md:text-sm max-w-[1200px]">
    <div class="flex flex-row">
      <RouterLink v-for="l in links" class="flex items-center gap-x-1.5 px-3 xs:px-2 md:px-2 hovering"
        :class="{ 'curved': l.name == 'home' }" :to="l.hash.startsWith('#') ? { path: '/', hash: l.hash } : l.hash">
        <SvgIcon type="mdi" :path="l.icon" />
        <div class="block xs:hidden" :class="{ 'sm:hidden xs:hidden': l.name != 'home' }">{{ $t(l.name) }}</div>
      </RouterLink>
    </div>

    <div class="flex flex-row items-center gap-x-2 xs:text-sm xs:gap-x-1 md:gap-x-1">
      <div class="cursor-pointer px-4 xs:px-2 md:px-2 hovering" :class="{ 'curved': isAr }" @click="locale = 'ar'">AR
      </div>
      <div>|</div>
      <div class="cursor-pointer px-4 xs:px-2 hovering" :class="{ 'curved': !isAr }" @click="locale = 'en'">EN</div>
    </div>
  </nav>
</template>

<script setup>
import SvgIcon from '@jamescoyle/vue-icon'
import { useI18n } from 'vue-i18n' // Import useI18n
import { RouterLink } from 'vue-router'
import { computed } from 'vue'
import { mdiHome, mdiBookOpenPageVariantOutline, mdiCashMultiple, mdiDownloadCircle, mdiAccountCircle } from '@mdi/js';

const { locale } = useI18n()
const isAr = computed(() => locale.value === 'ar' ? true : false)

const links = [
  {
    icon: mdiHome,
    name: 'home',
    hash: '#home',
  },
  {
    icon: mdiBookOpenPageVariantOutline,
    name: 'learn',
    hash: '#learn',
  },
  {
    icon: mdiCashMultiple,
    name: 'earn',
    hash: '#earn',
  },
  {
    icon: mdiDownloadCircle,
    name: 'download',
    hash: '#download',
  },
  {
    icon: mdiAccountCircle,
    name: 'account',
    hash: '/chat',
  },
];
</script>

<style scoped>
.curved {
  background-image: linear-gradient(to right, #F8398D, #2F75F8);
  border-radius: 30px 0px 30px 0px;
}

.hovering:hover {
  background-image: linear-gradient(to right, #F8398D, #2F75F8);
  border-radius: 30px 0px 30px 0px;
}
</style>