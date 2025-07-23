<template>
  <div class="flex flex-wrap gap-10 md:gap-6 justify-center mt-16">
    <div class="relative flex flex-col items-center w-48 md:w-36" v-for="f in features" :key="f.title">
      <div class="radial-gradient absolute transform -translate-y-9 md:-translate-y-7 z-0 w-48 md:w-36 h-48 md:h-36">
      </div>
      <div class="z-10 w-36 md:w-28 h-36 md:h-28 rounded-full border border-blue-500 flex items-center justify-center">
        <img :src="f.img" class="w-full h-full object-contain" :class="{
          'ml-6 rotate-[33deg]': f.title === 'chat', ' mb-12 ml-2': 'competition' == f.title,
          'mr-3': f.title == 'competition', 'ml-4': f.title == 'test'
        }">
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
    img: new URL('@/assets/online.png', import.meta.url).href,
    title: 'study',
  },
  {
    img: new URL('@/assets/ai.png', import.meta.url).href,
    title: 'ai',
  },
  {
    img: new URL('@/assets/test.png', import.meta.url).href,
    title: 'test',
  },
  {
    img: new URL('@/assets/community.png', import.meta.url).href,
    title: 'community',
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
