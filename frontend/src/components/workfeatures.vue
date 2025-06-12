<template>
  <div class="flex flex-wrap gap-10 md:gap-6 justify-center mt-16">
    <div class="relative flex flex-col items-center w-48 md:w-36" v-for="f in features" :key="f.title">
      <div class="radial-gradient absolute transform -translate-y-9 md:-translate-y-7 z-0 w-48 md:w-36 h-48 md:h-36">
      </div>
      <div class="z-10 w-36 md:w-28 h-36 md:h-28 rounded-full border border-blue-500 flex items-center justify-center">
        <img :src="f.img" class="w-full h-full object-contain" :class="{ 'rotate-12 mt-1 ml-3': f.title == 'do' }">
      </div>

      <div class="relative w-full flex flex-col justify-center items-center mt-5 overflow-hidden text-center">
        <div class="radial-gradient-curved absolute bottom-1 h-6 z-0 w-[500px] md:w-[400px]"></div>
        <div class="text-lg md:text-xs md:py-0.5 z-10">{{ $t(f.title) }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
const features = [
  {
    img: new URL('@/assets/do.png', import.meta.url).href,
    title: 'browse',
  },
  {
    img: new URL('@/assets/verify.png', import.meta.url).href,
    title: 'do',
  },
  {
    img: new URL('@/assets/dollar.png', import.meta.url).href,
    title: 'pay',
  },
  {
    img: new URL('@/assets/get.png', import.meta.url).href,
    title: 'get',
  },
];
</script>

<style scoped>
.radial-gradient {
  background: radial-gradient(circle, #2F75F8 0%, #01091D 65%);
  border-radius: 50%;
}

.radial-gradient-curved {
  background: radial-gradient(circle, #2F75F8 0%, #01091D 35%);
  border-radius: 50%;
}
</style>
