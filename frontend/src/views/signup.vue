<template>
  <div class="flex flex-col items-center justify-center gap-4 py-10">
    <input
      v-model="email"
      type="email"
      :placeholder="$t('email')"
      class="border border-gray-300 rounded px-3 py-2 w-80 max-w-full"
    />
    <input
      v-model="password"
      type="password"
      :placeholder="$t('password')"
      class="border border-gray-300 rounded px-3 py-2 w-80 max-w-full"
    />
    <input
      v-model="confirmPassword"
      type="password"
      :placeholder="$t('confirmPassword')"
      class="border border-gray-300 rounded px-3 py-2 w-80 max-w-full"
    />
    <button
      @click="onSignUp"
      class="bg-blue-500 text-white rounded px-3 py-2 w-80 max-w-full"
    >
      {{ $t('signUp') }}
    </button>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const email = ref('')
const password = ref('')
const confirmPassword = ref('')

const onSignUp = () => {
  if (password.value !== confirmPassword.value) {
    alert('Passwords do not match')
    return
  }
  // TODO: connect with backend API
  console.log('Sign up', email.value)
}
</script>
