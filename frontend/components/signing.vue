<template>
  <div class="flex flex-col justify-center items-center flex-1">
    <div class="w-24 h-24">
      <svg class="w-full h-full animate-spin text-blue-500">
        <circle class="text-white" cx="50%" cy="50%" r="45%" stroke-width="8 " fill="none" stroke="currentColor" />
        <circle class="opacity-75" cx="50%" cy="50%" r="45%" stroke-width="7" fill="none" stroke="blue"
          stroke-linecap="round" stroke-dasharray="283" stroke-dashoffset="200" />
      </svg>
    </div>

    <span class="text-lg font-medium text-white mt-5">حاري تسجيل الدخول لحسابك الآن ...</span>
  </div>
</template>

<script setup>
import { gql } from '@apollo/client/core'
import { useQuery } from '@vue/apollo-composable'
import { watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { storageStore } from '@/utils/store';
import { storeToRefs } from 'pinia'

const store = storageStore()

const { signing, user } = storeToRefs(store)

const route = useRoute()
const router = useRouter()

const login = gql`
  query socialLogin {
    socialLogin(code: "${route.query.code}") {
      email
      balance
			image
			name
      jwtToken
    }
  }
`

const { result } = useQuery(login, null, { fetchPolicy: 'network-only' })

watch((result), (newVal) => {    
  if (newVal.socialLogin.email) {
    signing.value = false;

    user.value = {
      email: newVal.socialLogin.email,
      balance: newVal.socialLogin.balance,
      image: newVal.socialLogin.image,
      name: newVal.socialLogin.name,
      jwtToken: newVal.socialLogin.jwtToken,
    }

    router.push('/chat')
  }
})

</script>
