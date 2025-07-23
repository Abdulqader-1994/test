<template>
  <div class="flex justify-between mb-10 w-[750px] mx-auto">
    <div class="flex items-center gap-2 w-full">
      <RouterLink to="/">
        <SvgIcon size="33px" type="mdi" :path="mdiHomeOutline" />
      </RouterLink>
      <div class="flex items-center py-0.5 px-2 font-bold bg-white text-[#01091D] rounded-full">
        <SvgIcon size="25px" type="mdi" :path="mdiCheckboxMarkedCirclePlusOutline" class="white" />
        <div class="mx-1 text-lg">اختبار جديد</div>
      </div>
    </div>

    <div class="flex flex-row items-center justify-end w-full gap-2">
      <div class="flex flex-row items-center text-lg border-2 rounded-full px-2 py-0.5">
       {{ user.balance }} ل.س
      </div>
      <SvgIcon size="33px" type="mdi" :path="mdiHistory" />
      <SvgIcon size="33px" type="mdi" :path="mdiCog" />
    </div>
  </div>
</template>

<script setup>
import SvgIcon from '@jamescoyle/vue-icon'
import { mdiCog, mdiHistory, mdiCheckboxMarkedCirclePlusOutline, mdiHomeOutline } from '@mdi/js';
import { storageStore } from '@/utils/store';
import { storeToRefs } from 'pinia'

const store = storageStore()
const { user } = storeToRefs(store)
</script>