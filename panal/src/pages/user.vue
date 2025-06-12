<template>
  <q-page class="column items-center q-pt-sm">
    <div>
      <span class="bg-black text-white q-pa-sm" @click="copyText()">
        function to add admin: wrangler d1 execute user --command="UPDATE User SET isAdmin = 1 WHERE id = 1;"
      </span>
      <br /><br />don't forget to edit id in last
    </div>
    <q-table class="my-sticky-header-table" flat bordered title="Users" :rows="rows" :columns="columns"
      :loading="loading" row-key="id" virtual-scroll style="max-height: 700px" v-model:pagination="pagination"
      :rows-per-page-options="[0]">
      <template v-slot:body-cell-time="props">
        <q-td :props="props">
          {{new Date(props.row.time * 1000).toLocaleString("en-US") }}
        </q-td>
      </template> 

      <template v-slot:body-cell-country="props">
        <q-td :props="props">
          {{ countryOptions[props.row.country] }} 
        </q-td>
      </template> 

      <template v-slot:body-cell-isAdmin="props">
        <q-td :props="props">
          <div v-if="props.row.isAdmin == '1'" style="background-color: green; color: white">True</div>
          <div v-else style="background-color: red; color: white">False</div>
        </q-td>
      </template> 
    </q-table>
  </q-page>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { gql } from '@apollo/client/core'
import { jwtToken } from './config'

async function copyText() {
  await navigator.clipboard.writeText('wrangler d1 execute user --command="UPDATE User SET isAdmin = 1 WHERE id = 1;"')
}

const columns = [
  { name: 'id', align: 'center', label: 'id', field: 'id', sortable: true },
  { name: 'userName', align: 'center', label: 'userName', field: 'userName', sortable: true },
  { name: 'time', align: 'center', label: 'time', field: 'time', sortable: true },
  { name: 'loginType', align: 'center', label: 'loginType', field: 'loginType', sortable: true },
  { name: 'loginInfo', align: 'center', label: 'loginInfo', field: 'loginInfo', sortable: true },
  { name: 'country', align: 'center', label: 'country', field: 'country', sortable: true },
  { name: 'balance', align: 'center', label: 'balance', field: 'balance', sortable: true },
  { name: 'trustPoint', align: 'center', label: 'trustPoint', field: 'trustPoint', sortable: true },
  { name: 'balanceToBuyShare', align: 'center', label: 'balanceToBuyShare', field: 'balanceToBuyShare', sortable: true },
  { name: 'distributePercent', align: 'center', label: 'distributePercent', field: 'distributePercent', sortable: true },
  { name: 'isAdmin', align: 'center', label: 'isAdmin', field: 'isAdmin', sortable: true },
  { name: 'adminPrivileges', align: 'center', label: 'adminPrivileges', field: 'adminPrivileges', sortable: true },
]

const GET_AllUSERS = gql`
  query adminGetAllUsers {
    adminGetAllUsers(jwtToken: "${jwtToken.value}") {
      id
      userName
      loginType
      loginInfo
      country
      time
      balance
      trustPoint
      balanceToBuyShare
      distributePercent
      isAdmin
      adminPrivileges      
    }
  }
`

const { result, loading } = useQuery(GET_AllUSERS, null, { fetchPolicy: 'network-only' })

const pagination = ref({ rowsPerPage: 0 })
const rows = computed(() => {
  if (!result.value?.adminGetAllUsers) return []

  const res = result.value.adminGetAllUsers.map(el => ({
    id: el.id,
    userName: el.userName,
    loginType: el.loginType,
    loginInfo: el.loginInfo,
    country: el.country,
    time: el.time,
    balance: el.balance,
    trustPoint: el.trustPoint,
    balanceToBuyShare: el.balanceToBuyShare,
    distributePercent: el.distributePercent,
    isAdmin: el.isAdmin,
    adminPrivileges: el.adminPrivileges,
  }))

  return res;
})

const countryOptions = {
  963: 'Syria',
  20: 'Egypt',
}
</script>
