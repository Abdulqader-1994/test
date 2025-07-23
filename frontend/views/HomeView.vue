<template>
  <div id="home" class="flex flex-col px-5 relative overflow-hidden">
    <!-- image -->
    <div class="relative flex flex-col items-center justify-center min-h-[25vw]">
      <div class="radial-gradient absolute top-[45%] left-[50%] -translate-x-[50%] -translate-y-[50%]"></div>
      <div class="radial-gradient-tiny absolute top-[10%] left-[10%]"></div>
      <div class="radial-gradient-tiny absolute bottom-[12%] right-[10%]"></div>
      <img src="@/assets/main.png" alt="main image" class="z-10 xs:w-11/12 h-full">
    </div>

    <div class="relative">
      <Particles />
    </div>

    <!-- title description -->
    <Description />

    <!-- buttons -->
    <RouterLink to="/chat" id="account" class="flex flex-row justify-center items-center gap-x-10 xs:gap-x-3 text-2xl xs:text-sm my-7 xs:mt-0">
      <div
        class="flex items-center gap-x-2 bg-gradient-to-r from-[#F8398D] to-[#2F75F8] py-1 rounded-3xl cursor-pointer px-7 xs:px-3">
        <SvgIcon type="mdi" :path="mdiAccountCircle" />
        <p>{{ $t('account') }}</p>
      </div>
      <div class="border-gradient py-1 rounded-3xl cursor-pointer px-7">{{ $t('more') }}</div>
    </RouterLink>

    <!-- objective -->
    <div class="flex items-center justify-center text-xl xs:text-xs sm:text-sm md:text-base py-0.5">
      <div class="tracking-widest animate-color-sequence-right" :dir="locale == 'ar' ? 'rtl' : 'ltr'">
        <span class="pipe" v-for="n in 15">|</span>
      </div>
      <div class="mx-2 text-center xs:flex xs:flex-col">
        <span class="whitespace-nowrap">{{ $t('gools') }}</span>
        <span class="font-bold text-yellow-500 mx-1">{{ $t('earn2') }}</span>
      </div>
      <div class="tracking-widest animate-color-sequence-left" :dir="locale == 'ar' ? 'ltr' : 'rtl'">
        <span class="pipe" v-for="n in 15">|</span>
      </div>
    </div>

    <!-- learning section -->
    <div id="learn" class="text-3xl xs:text-xl flex items-center justify-center gap-2 mb-6 title-gradient py-1 mt-12 xs:mt-8">
      <SvgIcon size="33px" type="mdi" :path="mdiBookOpenPageVariantOutline" />
      <div>{{ $t('learning') }}</div>
    </div>
    <div class="text-justify xl:text-center xs:text-sm xs:leading-7 mx-5">{{ $t('learningDesc') }}</div>
    <div class="flex flex-col sm:flex-row md:flex-row lg:flex-row xl:flex-row justify-around items-center">
      <div class="w-72 sm:w-60 h-72 sm:h-60">
        <img src="@/assets/view.png" alt="">
      </div>

      <div class="w-72 sm:w-60 h-72 sm:h-60 flex flex-col justify-center items-center px-2 rounded-3xl">
        <h2 class="text-xl font-bold mb-2 text-yellow-500">{{ $t('smartView') }}</h2>
        <p class="text-justify leading-7 text-sm sm:text-xs sm:leading-5">{{ $t('smartViewDesc') }}</p>
      </div>
    </div>

    <div
      class="flex flex-col sm:flex-row-reverse md:flex-row-reverse lg:flex-row-reverse xl:flex-row-reverse justify-around items-center">
      <div class="w-72 sm:w-60 h-72 sm:h-60">
        <img src="@/assets/review.png" alt="">
      </div>

      <div class="w-72 sm:w-60 h-72 sm:h-60 flex flex-col justify-center items-center px-2 rounded-3xl">
        <h2 class="text-xl font-bold mb-2 text-yellow-500">{{ $t('smartReview') }}</h2>
        <p class=" text-justify leading-7 text-sm sm:text-xs sm:leading-5">{{ $t('smartReviewDesc') }}</p>
      </div>
    </div>

    <Learnfeatures />

    <!-- earn section -->
    <div id="earn" class="text-3xl xs:text-xl flex items-center justify-center gap-2 mb-6 title-gradient py-1 mt-20">
      <SvgIcon size="33px" type="mdi" :path="mdiCashMultiple" />
      <div>{{ $t('earn') }}</div>
    </div>
    <div class="text-justify xl:text-center xs:text-sm xs:leading-7 mx-5">{{ $t('earnDesc') }}</div>
    <div class="flex flex-col sm:flex-row md:flex-row lg:flex-row xl:flex-row justify-around items-center">
      <div class="w-72 h-72 mt-5">
        <img src="@/assets/work.png" alt="">
      </div>

      <div class="w-72 h-72 flex flex-col justify-center items-center px-2 rounded-3xl">
        <h2 class="text-xl font-bold mb-2 text-yellow-500">{{ $t('work') }}</h2>
        <p class="text-justify leading-7 text-sm ">{{ $t('workDesc') }}</p>
      </div>
    </div>

    <div
      class="flex flex-col sm:flex-row-reverse md:flex-row-reverse lg:flex-row-reverse xl:flex-row-reverse justify-around items-center">
      <div class="w-72 h-72">
        <img src="@/assets/pay.png" alt="">
      </div>

      <div class="w-72 h-72 flex flex-col justify-center items-center px-2 rounded-3xl mt-10">
        <h2 class="text-xl font-bold mb-2 text-yellow-500">{{ $t('pay') }}</h2>
        <p class=" text-justify leading-7 text-sm">{{ $t('payDesc') }}</p>
      </div>
    </div>

    <Workfeatures />

    <Calculator />

    <!-- download section -->
    <div id="download" class="text-3xl xs:text-xl flex items-center justify-center gap-2 mb-6 title-gradient py-1 mt-20">
      <SvgIcon size="33px" type="mdi" :path="mdiDownloadCircle" />
      <div>{{ $t('download') }}</div>
    </div>
    <div class="flex flex-col-reverse md:flex-row lg:flex-row xl:flex-row justify-center items-center mb-10">
      <div
        class="flex flex-col justify-center items-center w-full gap-y-10 md:gap-y-5 lg:gap-y-10 xl:gap-y-10 text-xl md:text-lg sm:text-base xs:text-sm mt-10">
        <RouterLink to="" v-for="app in apps"
          class="flex justify-center items-center gap-x-2 radial-gradient-curved-3 w-80">
          <SvgIcon :class="{ 'bg-white text-[#2F75F8] ml-3 rounded-md': app.name == 'mac' }" type="mdi"
            :path="app.icon" />
          <p>{{ $t(app.name) }}</p>
        </RouterLink>
      </div>

      <div class="w-5/6 h-fit flex justify-center">
        <img src="@/assets/download.png" alt="">
      </div>
    </div>
  </div>
</template>

<script setup>
import SvgIcon from '@jamescoyle/vue-icon'
import {
  mdiAccountCircle,
  mdiAndroid,
  mdiApple,
  mdiMicrosoftWindows,
  mdiPenguin,
  mdiBookOpenPageVariantOutline,
  mdiCashMultiple,
  mdiDownloadCircle
} from '@mdi/js';
import Description from '@/components/description.vue';
import Learnfeatures from '@/components/Learnfeatures.vue';
import Calculator from '@/components/calculator.vue';
import Workfeatures from '@/components/workfeatures.vue';
import { useI18n } from 'vue-i18n'
import Particles from '@/components/particles.vue';
import { RouterLink } from 'vue-router';

const { locale } = useI18n()

const apps = [
  { name: 'android', icon: mdiAndroid },
  { name: 'apple', icon: mdiApple },
  { name: 'windoes', icon: mdiMicrosoftWindows },
  { name: 'mac', icon: mdiApple },
  { name: 'linux', icon: mdiPenguin },
]
</script>

<style scoped>
.radial-gradient {
  background: radial-gradient(circle, #2F75F8 0%, #01091D 65%);
  border-radius: 50%;
  width: min(26vw, 399px);
  height: min(26vw, 399px);
}

.radial-gradient-tiny {
  background: radial-gradient(circle, #2F75F8 0%, #01091D 65%);
  border-radius: 50%;
  width: min(15vw, 165px);
  height: min(15vw, 165px);
}

.botton-full-gradient {
  background-image: linear-gradient(to right, #F8398D, #2F75F8);
  border-radius: 10px;
}

.border-gradient {
  border: 3px solid transparent;
  background: linear-gradient(to right, #01091D, #01091D), linear-gradient(to right, #F8398D, #2F75F8);
  background-clip: padding-box, border-box;
  background-origin: padding-box, border-box;
}

.title-gradient {
  background: radial-gradient(circle, #F8398D 0%, #01091D 85%);
  border-radius: 50%;
}

.radial-gradient-curved-2 {
  background: radial-gradient(circle, #2F75F8 0%, #01091D 35%);
  border-radius: 50%;
}

.radial-gradient-curved-3 {
  background: radial-gradient(circle, #2F75F8 0%, #01091D 80%);
  border-radius: 50%;
}

.pipe {
  display: inline-block;
}

/* Keyframes for left-to-right animation */
@keyframes colorSequenceLeft {
  0% {
    color: #132861;
  }

  10% {
    color: white;
  }

  20% {
    color: #132861;
  }

  100% {
    color: #132861;
  }
}

@keyframes colorSequenceRight {
  0% {
    color: #132861;
  }

  10% {
    color: white;
  }

  20% {
    color: #132861;
  }

  100% {
    color: #132861;
  }
}

.animate-color-sequence-left .pipe {
  animation: colorSequenceLeft 1.5s infinite;
}

.animate-color-sequence-right .pipe {
  animation: colorSequenceRight 1.5s infinite;
}

/* Apply staggered delays for left-to-right */
.animate-color-sequence-right .pipe:nth-child(1) {
  animation-delay: 0s;
}

.animate-color-sequence-right .pipe:nth-child(2) {
  animation-delay: 0.1s;
}

.animate-color-sequence-right .pipe:nth-child(3) {
  animation-delay: 0.2s;
}

.animate-color-sequence-right .pipe:nth-child(4) {
  animation-delay: 0.3s;
}

.animate-color-sequence-right .pipe:nth-child(5) {
  animation-delay: 0.4s;
}

.animate-color-sequence-right .pipe:nth-child(6) {
  animation-delay: 0.5s;
}

.animate-color-sequence-right .pipe:nth-child(7) {
  animation-delay: 0.6s;
}

.animate-color-sequence-right .pipe:nth-child(8) {
  animation-delay: 0.7s;
}

.animate-color-sequence-right .pipe:nth-child(9) {
  animation-delay: 0.8s;
}

.animate-color-sequence-right .pipe:nth-child(10) {
  animation-delay: 0.9s;
}

.animate-color-sequence-right .pipe:nth-child(11) {
  animation-delay: 1.0s;
}

.animate-color-sequence-right .pipe:nth-child(12) {
  animation-delay: 1.1s;
}

.animate-color-sequence-right .pipe:nth-child(13) {
  animation-delay: 1.2s;
}

.animate-color-sequence-right .pipe:nth-child(14) {
  animation-delay: 1.3s;
}

.animate-color-sequence-right .pipe:nth-child(15) {
  animation-delay: 1.4s;
}

/* Apply staggered delays for right-to-left (reverse order) */
.animate-color-sequence-left .pipe:nth-child(15) {
  animation-delay: 1.4s;
}

.animate-color-sequence-left .pipe:nth-child(14) {
  animation-delay: 1.3s;
}

.animate-color-sequence-left .pipe:nth-child(13) {
  animation-delay: 1.2s;
}

.animate-color-sequence-left .pipe:nth-child(12) {
  animation-delay: 1.1s;
}

.animate-color-sequence-left .pipe:nth-child(11) {
  animation-delay: 1.0s;
}

.animate-color-sequence-left .pipe:nth-child(10) {
  animation-delay: 0.9s;
}

.animate-color-sequence-left .pipe:nth-child(9) {
  animation-delay: 0.8s;
}

.animate-color-sequence-left .pipe:nth-child(8) {
  animation-delay: 0.7s;
}

.animate-color-sequence-left .pipe:nth-child(7) {
  animation-delay: 0.6s;
}

.animate-color-sequence-left .pipe:nth-child(6) {
  animation-delay: 0.5s;
}

.animate-color-sequence-left .pipe:nth-child(5) {
  animation-delay: 0.4s;
}

.animate-color-sequence-left .pipe:nth-child(4) {
  animation-delay: 0.3s;
}

.animate-color-sequence-left .pipe:nth-child(3) {
  animation-delay: 0.2s;
}

.animate-color-sequence-left .pipe:nth-child(2) {
  animation-delay: 0.1s;
}

.animate-color-sequence-left .pipe:nth-child(1) {
  animation-delay: 0.0s;
}
</style>
