<template>
  <q-page class="flex flex-center q-pa-xl">
    <div v-if="!jwtToken" style="width: 320px;">
      <q-form @submit.prevent="onSubmit" class="q-gutter-md">
        <q-input filled v-model="email" label="email" lazy-rules
          :rules="[val => val && val.length > 0 || 'Please type something']" />

        <q-input filled v-model="password" label="password" lazy-rules
          :rules="[val => val && val.length > 0 || 'Please type something']" />

        <q-btn label="Submit" type="submit" color="primary" />
      </q-form>
    </div>

    <div v-if="jwtToken" class="text-h3">
      مرحباً بك {{ userName }}
    </div>
  </q-page>
</template>

<script setup>
import { useQuery } from '@vue/apollo-composable'
import gql from 'graphql-tag'
import { jwtToken, userName } from './config'
import { ref } from 'vue'

const email = ref('system@ailence.ai')
const password = ref('aiRoot.2017-2025@ailence.com')

const SIGN_IN_QUERY = gql`
  query emailLogin{
    emailLogin(email: "${email.value}", password: "${password.value}") {
      userName
      jwtToken
    }
  }
`


const onSubmit = async () => {
  await executeSignIn()
  if (!result.value.emailLogin.jwtToken || !result.value.emailLogin.userName) return;
  jwtToken.value = result.value.emailLogin.jwtToken
  userName.value = result.value.emailLogin.userName
}

const { refetch: executeSignIn, result } = useQuery(SIGN_IN_QUERY)
</script>
