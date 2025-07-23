<template>
  <div class="flex flex-col mx-auto text-lg w-[750px] gap-3 text-justify">
    <!-- system massage -->
    <div class="flex items-center gap-3">
      <img src="@/assets/logo.png" class="w-12 h-12 rounded-full p-1" />
      <p class="text-2xl">Ailence</p>
    </div>
    <div v-html="displayedHtml" class="flex flex-col gap-3" v-if="!stepOne"></div>
    <div class="flex flex-col gap-3" v-if="stepOne">
      <p>أهلاً وسهلاً بك يا
        <span class="font-bold underline">{{ user.name }}</span>
        في منصة
        <span class="font-bold text-xl text-yellow-500">Ailence</span>
        (منظومة التعلم بالذكاء الاصطناعي للتعليم الإبداعي الجديد)
      </p>
      <p>صمّمنا هذه المنصة خصيصاً لطلاب سوريا، لتكون بوابتهم نحو بيئة تعليمية متطورة تجمع بين قوة الذكاء الاصطناعي
        واحتياجات المناهج الدراسية.</p>
      <p class="text-yellow-300">
        تنبيه: المنصة الآن في المرحلة التجريبية (Beta)، ولذلك أغلب أقسامها مقفلة حالياً، ولضمان جودة عالية في التعليم ..
        تقتصر
        المنصة فقط على عرض الاختبارات فقط
      </p>
      <p>
        نتمنى لك تجربة مفيدة وموفقة، ولا تتردد في مشاركة ملاحظاتك وأفكارك حتى نتمكن من تحسين المنصة معاً لدعم رحلتك
        التعليمية على أكمل وجه!
      </p>
      <hr class="w-3/4" />
      <p>والآن لنبدأ بمراجعة معلوماتك وتقييمها ...</p>
      <p>رجاء اختر إحدى المواد التالية لإجراء اختبار فيها :</p>
      <div class="border-2 border-white hover:border-blue-400 hover:text-blue-400 px-2 py-1 rounded-lg cursor-pointer"
        @click="selectMaterial(0)">
        <p>التربية الدينية الإسلامية لطلاب البكلوريا</p>
      </div>
      <div class="text-base">
        ويرجى أخذ العلم أنه يتم حالياً إضافة مواد أخرى من منهاج البكلوريا العلمي والأدبي، وبعد الانتهاء من تدقيقها ..
        سيتم رفعها للمنصة فوراً، لذلك قم بزيارتنا باستمرار لتعرف كل جديد
      </div>
    </div>

    <!-- user massage -->
    <transition name="fade" appear>
      <div class="flex flex-col mt-10 bg-gray-800 rounded-xl px-5 py-2" v-if="material">
        <div class="flex items-center gap-3 justify-end mb-2">
          <p class="">{{ user.email }}</p>
          <img :src="user.image" class="w-10 h-10 rounded-full p-1" />
        </div>
        <div class="flex justify-end">
          <p>التربية الدينية الإسلامية لطلاب البكلوريا</p>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { storeToRefs } from 'pinia'
import { onMounted, ref } from 'vue'
import { storageStore } from '@/utils/store';

const store = storageStore()

const material = ref(null)

const { user } = storeToRefs(store)

const name = ref('عزيزي الطالب')
const msg = ref('')
const stepOne = ref(false)
const stepTwo = ref(false)
const stepThree = ref(false)

onMounted(() => {
  if (user.value && user.value.name) name.value = user.value.name
  msg.value = `
    <p>أهلاً وسهلاً بك يا
      <span class="font-bold underline">${name.value}</span>
      في منصة
      <span class="font-bold text-xl text-yellow-500">Ailence</span>
      (منظومة التعلم بالذكاء الاصطناعي للتعليم الإبداعي الجديد)
    </p>
    <p>صمّمنا هذه المنصة خصيصاً لطلاب سوريا، لتكون بوابتهم نحو بيئة تعليمية متطورة تجمع بين قوة الذكاء الاصطناعي
      واحتياجات المناهج الدراسية.</p>
    <p class="text-yellow-300">
      تنبيه: المنصة الآن في المرحلة التجريبية (Beta)، ولذلك أغلب أقسامها مقفلة حالياً، ولضمان جودة عالية في التعليم ..
      تقتصر
      المنصة فقط على عرض الاختبارات فقط
    </p>
    <p>
      نتمنى لك تجربة مفيدة وموفقة، ولا تتردد في مشاركة ملاحظاتك وأفكارك حتى نتمكن من تحسين المنصة معاً لدعم رحلتك
      التعليمية على أكمل وجه!
    </p>
    <hr class="w-3/4" />

    <!-- choose option -->
    <p>والآن لنبدأ بمراجعة معلوماتك وتقييمها ...</p>
    <p>رجاء اختر إحدى المواد التالية لإجراء اختبار فيها :</p>
    <div
      class="border-2 border-white hover:border-blue-400 hover:text-blue-400 px-2 py-1 rounded-lg cursor-pointer">
        <p>التربية الدينية الإسلامية لطلاب البكلوريا</p>
    </div>
    <div class="text-base">
      ويرجى أخذ العلم أنه يتم حالياً إضافة مواد أخرى من منهاج البكلوريا العلمي والأدبي، وبعد الانتهاء من تدقيقها ..
      سيتم رفعها للمنصة فوراً، لذلك قم بزيارتنا باستمرار لتعرف كل جديد
    </div>
`
  startTypewriter(msg.value, () => stepOne.value = true)
})

function selectMaterial(materialId) {
  /* quesType = 0 mean choose from 4 answers | quesType = 0 mean type answer */
  if (materialId == 0) material.value = { name: 'التربية الدينية الإسلامية', mini: 'سؤال واحد', max: 'أربع أسئلة', examType: '' }
  msg.value = `
      <div class="flex flex-col gap-3">
        <p>حسناً، لنبدأ بمادة ${material.value.name}</p>
        <p>ولكن قبل ذلك، ما هو نوع الاختبار التي ترغب بها ؟</p>
        <div class="flex flex-col gap-3 mt-3">
          <div
            class="border-2 border-white hover:border-blue-400 hover:text-blue-400 px-2 py-1 rounded-lg cursor-pointer"
            @click="selectMaterial(0)">
            <p>اختبار مصغر (${material.value.mini} عشوائي)</p>
          </div>
          <div
            class="border-2 border-white hover:border-blue-400 hover:text-blue-400 px-2 py-1 rounded-lg cursor-pointer"
            @click="selectMaterial(0)">
            <p>اختبار شامل (${material.value.max})</p>
          </div>
        </div>
      </div>
  `
  setTimeout(() => {
    startTypewriter(msg.value, () => stepTwo.value = true)
  }, 500)
}

const displayedHtml = ref('')

function startTypewriter(html, updateStep) {
  console.log(html);

  const chunkSize = 10
  const maxDuration = 1500
  const chunks = html.match(new RegExp(`.{1,${chunkSize}}`, 'gs')) || []
  const total = chunks.length
  const interval = total ? maxDuration / total : 0
  let i = 0

  const handle = setInterval(() => {
    displayedHtml.value += chunks[i] || ''
    i++
    if (i >= total) {
      clearInterval(handle)
      // 3. once done, strip off everything from CHOOSER-START onward
      const cutIndex = displayedHtml.value.indexOf('<!-- choose option -->')
      if (cutIndex !== -1) displayedHtml.value = displayedHtml.value.slice(0, cutIndex) // now show the real chooser in the template
      console.log(displayedHtml.value);
      displayedHtml.value = ''

      updateStep()
    }
  }, interval)
}
</script>

<style scoped>
.fade-enter-active {
  transition: opacity 0.3s;
}

.fade-enter-from {
  opacity: 0;
}

.fade-enter-to {
  opacity: 1;
}
</style>