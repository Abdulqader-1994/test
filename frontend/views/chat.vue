<template>
  <div class="flex flex-col p-2 w-full">
    <Login v-if="!isAuthed && !signing" />

    <Signing v-if="signing" />

    <div class="flex flex-col flex-1" v-if="isAuthed">
      <!-- icons header -->
      <ChatHeader />

      <Massages />

    </div>
  </div>
</template>

<script setup>
import Signing from '@/components/signing.vue';
import Login from '@/components/login.vue';
import ChatHeader from '@/components/chatHeader.vue';
import { ref, onMounted } from 'vue';
import { storageStore } from '@/utils/store';
import { storeToRefs } from 'pinia'
import { useRoute } from 'vue-router';
import Massages from '@/components/massages.vue';

const route = useRoute()
const store = storageStore()

const { signing, isAuthed } = storeToRefs(store)

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