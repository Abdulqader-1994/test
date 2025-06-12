<template>
  <q-page>
    <q-table class="my-sticky-header-table" flat bordered title="Curriculum" :rows="rows" :columns="columns"
      :loading="loading" row-key="id" virtual-scroll style="max-height: 700px" v-model:pagination="pagination"
      :rows-per-page-options="[0]">

      <template v-slot:body-cell-id="props">
        <q-td :props="props">
          <div class="col">
            <q-btn :to="'task/' + props.row.id" color="brown" :label="'check task for Id: ' + props.row.id" sizs="md" dense />
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-country="props">
        <q-td :props="props">
          <div v-for="op in countryOptions" :key="op.value">
            <div v-if="op.value == props.row.country">{{ op.label }}</div>
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-levelType="props">
        <q-td :props="props">
          <div v-for="op in levelOptions" :key="op.value">
            <div v-if="op.value == props.row.levelType">{{ op.label }}</div>
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-semester="props">
        <q-td :props="props">
          <div v-for="op in semesterOptions" :key="op.value">
            <div v-if="op.value == props.row.semester">{{ op.label }}</div>
          </div>
        </q-td>
      </template>

      <template v-slot:body-cell-openToWork="props">
        <q-td :props="props">
          <div v-if="props.row.openToWork == 0" class="text-white bg-red-5" style="padding: 5px;">مغلق</div>
          <div v-if="props.row.openToWork == 1" class="text-white bg-green-5" style="padding: 5px;">مفتوح</div>
        </q-td>
      </template>

      <template v-slot:body-cell-edit="props">
        <q-td :props="props">
          <q-btn label="edit" color="primary" @click="edit(props.row.id)" />
        </q-td>
      </template>
    </q-table>


    <div class="row justify-between">
      <div class="column q-mx-auto" style="width: 500px; padding: 20px;">
        <div class="text-h4 text-center q-mb-lg" v-if="!editing">أضف مادة جديدة</div>
        <div class="text-h4 text-center q-mb-lg" v-if="editing">تعديل المادة</div>

        <q-form @submit="onSubmit" class="q-gutter-md">
          <q-input filled v-model="name" label="material name" lazy-rules hint="مادة الرياضيات"
            :rules="[val => val && val.length > 0 || 'Please type something']" />
          <hr />

          <div>choose material country</div>
          <q-option-group v-model="countryId" :options="countryOptions" color="primary" />
          <hr />

          <div>choose level type</div>
          <q-option-group v-model="levelType" :options="levelOptions" color="primary" />
          <hr />

          <q-input filled v-model="level" label="level name" lazy-rules hint="الصف الثالث الثانوي"
            :rules="[val => val && val.length > 0 || 'Please type something']" />
          <hr />

          <div>choose semester</div>
          <q-option-group v-model="semester" :options="semesterOptions" color="primary" />
          <hr />

          <q-toggle v-model="openToWork" :true-value="1" :false-value="0" label="مفتوحة للعمل" />
          <hr />

          <div class="row justify-between">
            <q-btn label="Submit" type="submit" color="primary" :loading="loading" />
            <q-btn label="Close Editing" color="red" @click="reset()" v-if="editing" />
          </div>
        </q-form>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { gql } from '@apollo/client/core'
import { jwtToken } from './config'

const editing = ref(false)

const columns = [
  { name: 'id', align: 'center', label: 'id', field: 'id', sortable: true },
  { name: 'name', align: 'center', label: 'name', field: 'name', sortable: true },
  { name: 'country', align: 'center', label: 'country', field: 'country', sortable: true },
  { name: 'levelType', align: 'center', label: 'levelType', field: 'levelType', sortable: true },
  { name: 'level', align: 'center', label: 'level', field: 'level', sortable: true },
  { name: 'semester', align: 'center', label: 'semester', field: 'semester', sortable: true },
  { name: 'completedPercent', align: 'center', label: 'completedPercent', field: 'completedPercent', sortable: true },
  { name: 'openToWork', align: 'center', label: 'openToWork', field: 'openToWork', sortable: true },
  { name: 'edit', align: 'center', label: 'edit', field: 'edit' },
]

const id = ref(null)
const name = ref(null)
const countryId = ref(963)
const levelType = ref(0)
const level = ref(null)
const semester = ref(0)
const openToWork = ref(0)

const countryOptions = [
  { label: 'سوريا', value: 963 },
]

const levelOptions = [
  { label: 'مدرسي', value: 0 },
]

const semesterOptions = [
  { label: 'كامل السنة', value: 0 },
  { label: 'الفصل الأول', value: 1 },
  { label: 'الفصل الثاني', value: 2 },
]

const GET_CURRICULUMS = gql`
  query adminGetCurriculums {
    adminGetCurriculums(jwtToken: "${jwtToken.value}") {
      id
      name
      countryId
      levelType
      completedPercent
      level
      semester
      openToWork
    }
  }
`

const { result, loading, refetch } = useQuery(GET_CURRICULUMS, null, { fetchPolicy: 'network-only' })

const pagination = ref({ rowsPerPage: 0 })
const rows = computed(() => {
  if (!result.value?.adminGetCurriculums) return []

  const res = result.value.adminGetCurriculums.map(el => ({
    id: el.id,
    name: el.name,
    country: el.countryId,
    levelType: el.levelType,
    completedPercent: el.completedPercent,
    level: el.level,
    semester: el.semester,
    openToWork: el.openToWork
  }))

  return res;
})

const ADD_CURRICULUM = gql`
  mutation adminAddCurriculum(
    $id: Int
    $name: String!
    $countryId: Int!
    $levelType: Int!
    $level: String!
    $semester: Int!
    $openToWork: Int!
    $jwtToken: String!
  ) {
    adminAddCurriculum(
      id: $id
      name: $name
      countryId: $countryId
      levelType: $levelType
      level: $level
      semester: $semester
      openToWork: $openToWork
      jwtToken: $jwtToken
    )
  }
`
const { mutate: adminAddCurriculum } = useMutation(ADD_CURRICULUM)

async function onSubmit() {
  const res = await adminAddCurriculum({
    id: id.value,
    name: name.value,
    countryId: countryId.value,
    levelType: levelType.value,
    level: level.value,
    semester: semester.value,
    openToWork: openToWork.value,
    jwtToken: jwtToken.value,
  })

  await refetch();
  reset()
}

async function edit(dataId) {
  editing.value = true
  const existData = rows.value.filter(el => el.id == dataId)[0]

  id.value = existData.id
  name.value = existData.name
  countryId.value = existData.country
  levelType.value = existData.levelType
  level.value = existData.level
  semester.value = existData.semester
  openToWork.value = existData.openToWork
}

function reset() {
  editing.value = false

  id.value = null
  name.value = null
  countryId.value = 20
  levelType.value = 0
  level.value = null
  semester.value = 0
  openToWork.value = 0

  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>
