<template>
  <div class="w-full mt-7 md:mt-0 lg:mt-0 xl:mt-0 radial-gradient-curved-4 pt-16 pb-3 bg-white">
    <div
      class="flex flex-col sm:flex-row md:flex-row lg:flex-row xl:flex-row justify-center items-center sm:items-end md:items-end max-w-[1200px] mx-auto md:gap-10 lg:gap-10 xl:gap-10">
      <!-- social part -->
      <div class="flex flex-col gap-y-3 w-40 lg:w-48 xl:w-52 mb-5 xs:hidden">
        <div class="text-sm lg:text-base xl:text-lg font-bold">{{ $t('follow') }}</div>
        <div class="flex flex-row justify-center lg:flex-col xl:flex-col gap-3">
          <div class="flex gap-x-3">
            <SvgIcon type="mdi" :path="mdiFacebook" />
            <p class="hidden lg:block xl:block">{{ $t('facebook') }}</p>
          </div>
          <div class="flex gap-x-3">
            <SvgIcon type="mdi" :path="mdiInstagram" />
            <p class="hidden lg:block xl:block">{{ $t('instegram') }}</p>
          </div>
          <div class="flex gap-x-3">
            <SvgIcon type="mdi" :path="mdiTwitter" />
            <p class="hidden lg:block xl:block">{{ $t('twitter') }}</p>
          </div>
        </div>
      </div>

      <!-- name part -->
      <div class="flex flex-col xs:flex-row w-40 xs:gap-2 lg:w-48 xl:w-52 items-center mb-3">
        <div class="text-3xl mb-1">AILENCE</div>
        <img src="@/assets/logo.png" class="w-24 h-24 xs:w-12 xs:h-12" alt="">
      </div>

      <!-- contact us -->
      <div
        class="flex flex-row sm:flex-col md:flex-col lg:flex-col xl:flex-col justify-center items-center gap-3 w-52 sm:w-40 md:w-40 lg:w-48 xl:w-52 mb-3">
        <div class="text-sm font-bold">{{ $t('contact') }}</div>
        <div class="flex flex-row justify-around lg:flex-col xl:flex-col gap-3">
          <div class="flex gap-x-3">
            <SvgIcon type="mdi" :path="mdiAt" />
            <p class="hidden lg:block xl:block">support@ailence.com</p>
          </div>
          <div class="flex gap-x-3">
            <SvgIcon type="mdi" :path="mdiWhatsapp" />
            <p class="hidden lg:block xl:block" dir="ltr">+ 20 101 369 8921</p>
          </div>
          <div class="flex gap-x-3">
            <svg fill="white" width="20px" height="20px" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"
              class="mx-0.5">
              <path
                d="m12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12c0-6.627-5.373-12-12-12zm5.894 8.221-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.18-.357.295-.6.295-.002 0-.003 0-.005 0l.213-3.054 5.56-5.022c.24-.213-.054-.334-.373-.121l-6.869 4.326-2.96-.924c-.64-.203-.658-.64.135-.954l11.566-4.458c.538-.196 1.006.128.832.941z" />
            </svg>
            <p class="hidden lg:block xl:block" dir="ltr">+ 20 101 369 8921</p>
          </div>
        </div>
      </div>

      <!-- social part -->
      <div class="flex flex-row justify-center items-center gap-3 w-72 sm:hidden md:hidden lg:hidden xl:hidden">
        <div class="text-sm lg:text-base xl:text-lg font-bold">{{ $t('follow') }}</div>
        <div class="flex flex-row justify-center md:flex-col lg:flex-col xl:flex-col gap-3">
          <div class="flex gap-x-3">
            <SvgIcon type="mdi" :path="mdiFacebook" />
            <p class="hidden md:block lg:block xl:block">{{ $t('facebook') }}</p>
          </div>
          <div class="flex gap-x-3">
            <SvgIcon type="mdi" :path="mdiInstagram" />
            <p class="hidden md:block lg:block xl:block">{{ $t('instegram') }}</p>
          </div>
          <div class="flex gap-x-3">
            <SvgIcon type="mdi" :path="mdiTwitter" />
            <p class="hidden md:block lg:block xl:block">{{ $t('twitter') }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import SvgIcon from '@jamescoyle/vue-icon'
import { mdiFacebook, mdiInstagram, mdiTwitter, mdiAt, mdiWhatsapp } from '@mdi/js';
</script>

<style scoped>
.radial-gradient-curved-4 {
  background: radial-gradient(ellipse at center bottom, #2F75F8 0%, #01091D 70%);
}
</style>