<template>
  <div class="flex flex-col items-center justify-center gap-4 py-10">
    <div class="text-3xl text-white font-bold mb-5">إنشاء حساب</div>
    <input v-model="email" type="email" :placeholder="$t('email')"
      class="border border-gray-300 rounded px-3 py-2 w-80 max-w-full text-black" />
    <div class="relative w-80 max-w-full text-black">
      <input v-model="password" :type="showPassword ? 'text' : 'password'" :placeholder="$t('password')"
        class="border border-gray-300 rounded px-3 py-2 w-full" />
      <button type="button" class="absolute inset-y-0 left-0 flex items-center px-3 text-gray-500"
        @click="showPassword = !showPassword">
        <SvgIcon type="mdi" :path="showPassword ? mdiEyeOff : mdiEye" />
      </button>
    </div>
    <div class="relative w-80 max-w-full text-black">
      <input v-model="confirmPassword" :type="showPassword ? 'text' : 'password'" :placeholder="$t('confirmPassword')"
        class="border border-gray-300 rounded px-3 py-2 w-full" />
    </div>
    <button @click="onSignUp" class="bg-blue-500 text-white rounded px-3 py-2 w-80 max-w-full">
      {{ $t('signUp') }}
    </button>
    <RouterLink to="/signin" class="text-sm mt-3">لديك حساب مسبقاً ؟ تسجيل الدخول</RouterLink>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import SvgIcon from '@jamescoyle/vue-icon'
import { mdiEye, mdiEyeOff } from '@mdi/js'

const email = ref('')
const password = ref('')
const confirmPassword = ref('')

const showPassword = ref(false)

const onSignUp = () => {
  if (password.value !== confirmPassword.value) {
    alert('Passwords do not match')
    return
  }
  // TODO: connect with backend API
  console.log('Sign up', email.value)
}
</script>
