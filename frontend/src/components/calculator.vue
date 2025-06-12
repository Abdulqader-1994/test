<template>
  <div class="w-5/6 mx-auto flex flex-wrap items-center justify-center mt-10 border-white rounded-[20%] border-gradient-2">
    <div class="flex flex-col w-52">
      <div class="text-2xl py-1 my-5 flex items-center justify-center title-gradient-2">{{ $t('cal') }}</div>
      <div class="py-3 flex flex-col items-center justify-center gap-y-2 text-lg">
        <div>{{ $t('earnings') }}:</div>
        <div class="text-green-500">{{ formatter.format(earn) }} {{ $t('pounds') }}</div>
      </div>
    </div>

    <div class="w-80 flex flex-col p-6 text-xs">
      <div class="relative">
        <div class="absolute bg-[#01091D] px-1 right-2 -top-2">{{ $t('hourWork') }}</div>
        <input v-model="allHours" type="number"
          class="bg-[#01091D] border border-[#2F75F8] hover:border-white p-3 w-full text-base" />
      </div>
      <div class="relative mt-7">
        <div class="absolute bg-[#01091D] px-1 right-2 -top-2">{{ $t('subscription') }}</div>
        <input v-model="allStudent" type="number"
          class="bg-[#01091D] border border-[#2F75F8] hover:border-white p-3 w-full text-base" />
      </div>
      <div class="relative mt-7">
        <div class="absolute bg-[#01091D] px-1 right-2 -top-2">{{ $t('yourWork') }}</div>
        <input v-model="yourHour" type="number"
          class="bg-[#01091D] border border-[#2F75F8] hover:border-white p-3 w-full text-base" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue';

const allHours = ref(10000)
const allStudent = ref(2000)
const yourHour = ref(10)

const earn = computed(() => ((allStudent.value * 100000 / allHours.value) * yourHour.value * 0.25))

watch(allHours, (newVal) => {
  if (newVal < yourHour.value) yourHour.value = newVal
})

watch(yourHour, (newVal) => {
  if (newVal > allHours.value) yourHour.value = allHours.value
})

const formatter = new Intl.NumberFormat('en-US', {
  minimumFractionDigits: 0,
  maximumFractionDigits: 2
});
</script>

<style scoped>
.title-gradient {
  background: radial-gradient(ellipse, #F8398D 0%, #01091D 70%);
  border-radius: 50%;
}

.title-gradient-2 {
  background: radial-gradient(ellipse, #2F75F8 0%, #01091D 70%);
  border-radius: 50%;
}

.border-gradient-2 {
  border: 6px solid transparent;
  background: linear-gradient(to right, #01091D, #01091D), linear-gradient(to right, #F8398D, #2F75F8);
  background-clip: padding-box, border-box;
  background-origin: padding-box, border-box;
}
</style>