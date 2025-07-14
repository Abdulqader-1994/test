<template>
  <div class="flex-1 flex flex-col items-center justify-center">
    <div class="flex flex-col gap-4 items-center mb-5">
      <img class="w-32 h-32" src="/src/assets/logo.png" />
      <div class="text-5xl">Ailence</div>
    </div>
    <a :href="authGoogle" class="border-2 border-white rounded-full px-3 py-1.5 cursor-pointer">
      تسجيل الدخول عن طريق Google
    </a>
    <div class="flex flex-col w-40">
      <img src="/src/assets/arrow.png" class="h-12 w-16 mt-2 ">
      <div class="mt-2 text-sm">اضغط هنا</div>
    </div>
  </div>
</template>

<script setup>
import queryString from 'query-string'

const authGoogle = `https://accounts.google.com/o/oauth2/v2/auth?${queryString.stringify({
  client_id: '1039087411910-kvkrgh0os6d8h8rq7v7anf2uv14kfi2m.apps.googleusercontent.com',
  redirect_uri: 'http://localhost:5173/chat',
  response_type: 'code',
  scope: 'email',
  include_granted_scopes: 'true',
  state: 'pass-through value'
})}`
</script>
