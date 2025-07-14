<template>
  <div>
    <div class="flex items-center justify-between">
      <a :href="authGoogle" class="flex text-white w-44 items-center bg-darkGold py-1 m-2 rounded-md">
        <q-icon name="mdiGoogle" class="mx-2" />
        <p>تسجيل الدخول عن طريق Google</p>
      </a>
    </div>
  </div>
</template>

<script setup>
import SvgIcon from '@jamescoyle/vue-icon'
import { mdiGoogle } from '@mdi/js';

const authGoogle = `https://accounts.google.com/o/oauth2/v2/auth?${queryString.stringify({
  client_id: '41263391446-7l04344s9t6krgmhka73f19bl5tgvsv7.apps.googleusercontent.com',
  redirect_uri: 'https://sosphon.com/auth/redirect-google',
  response_type: 'code',
  scope: 'email',
  include_granted_scopes: 'true',
  state: 'pass-through value'
})}`

</script>
