<template>
  <div class="flex flex-col p-2 w-full">
    <Login v-if="!isAuthed && !signing" />

    <Signing v-if="signing" />

    <div class="flex flex-col flex-1" v-if="isAuthed">
      <!-- icons header -->
      <div class="flex justify-between">
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
            الرصيد : 300.00
          </div>
          <SvgIcon size="33px" type="mdi" :path="mdiHistory" />
          <SvgIcon size="33px" type="mdi" :path="mdiCog" />
        </div>
      </div>

      <!-- step one: choose material -->
      <div class="flex flex-col flex-1 items-center justify-center" v-if="material == null">
        <div class="flex flex-col">
          <div class="text-3xl mb-5">اختر المادة التي ترغب باختبار معلوماتك بها</div>
          <div class="flex flex-col gap-4 test-item">
            <div class="flex flex-col gap-2 text-lg border-2 rounded-xl px-3 py-2 cursor-pointer slide-text"
              @click="material = 'islamic'">
              <p>التربية الدينية الإسلامية</p>
              <p>السنة الدراسية: بكلوريا علمي / أدبي</p>
            </div>
          </div>
        </div>

        <div class="flex flex-col mt-20">
          <div class="text-2xl mb-5">مواد يتم حالياً إضافتها للذكاء الاصطناعي</div>
          <div class="flex flex-col gap-5 text-sm">
            <div class="flex justify-between gap-10">
              <div>العلوم (بكلوريا علمي)</div>
              <div>نسبة الإكمال: 90 %</div>
            </div>
            <div class="flex justify-between gap-10">
              <div>الانكليزي (بكلوريا علمي / أدبي)</div>
              <div>نسبة الإكمال: 10 %</div>
            </div>
          </div>
        </div>
      </div>

      <!-- step two: choose exam type -->
      <div class="flex flex-col flex-1 items-center justify-center" v-if="material != null && examType == null">
        <div class="flex flex-col">
          <div class="text-3xl mb-5">اختر طريقة عرض الاختبار</div>
          <div class="flex flex-col gap-4 test-item" @v-if="material == islamic">
            <div class="flex justify-between text-lg border-2 rounded-xl px-3 py-2 cursor-pointer slide-text"
              @click="examType = 'easy'">
              <div>اختبار بسيط</div>
              <div>(سؤال واحد)</div>
            </div>
            <div class="flex justify-between text-lg border-2 rounded-xl px-3 py-2 cursor-pointer slide-text"
              @click="examType = 'hard'">
              <div>اختبار شامل</div>
              <div>(أربع أسئلة)</div>
            </div>
          </div>

          <div>العودة للخلف</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import SvgIcon from '@jamescoyle/vue-icon'
import Signing from '@/components/signing.vue';
import Login from '@/components/login.vue';
import { mdiCog, mdiHistory, mdiCheckboxMarkedCirclePlusOutline, mdiHomeOutline } from '@mdi/js';
import { ref, onMounted } from 'vue';
import { storageStore } from '@/utils/store';
import { storeToRefs } from 'pinia'
import { useRoute } from 'vue-router';

const route = useRoute()
const store = storageStore()

const { signing, isAuthed } = storeToRefs(store)

let material = ref(null)
let examType = ref(null)

onMounted(() => {
  if (route.query.state == "pass-through value") {
    signing.value = true
  } else {
    signing.value = false
  }
  
})
</script>

<style scoped>
.slide-text {
  @apply relative overflow-hidden transition-colors duration-200;
}

.slide-text:hover {
  @apply bg-white text-black shadow-lg;
}

.slide-text:hover p {
  animation: slide-out-in 0.4s ease forwards;
}

@keyframes slide-out-in {
  0% {
    transform: translateX(0);
  }

  40% {
    transform: translateX(-100%);
  }

  41% {
    transform: translateX(100%);
  }

  100% {
    transform: translateX(0);
  }
}
</style>
