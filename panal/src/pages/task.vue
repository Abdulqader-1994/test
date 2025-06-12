<template>
  <q-page>
    <q-btn label="refetch data" @click="refetch" class="q-ma-sm" />
    <q-table :columns="columns" :rows="rows" row-key="id" flat bordered :loading="loading">
      <template v-slot:body-cell-time="props">
        <q-td :props="props">
          {{ new Date(props.row.time).toLocaleString("en-US") }}
        </q-td>
      </template>

      <template v-slot:body-cell-access="props">
        <q-td :props="props" v-if="props.row.access == 0" style="background-color: green; color: white;"> for all
          user</q-td>
        <q-td :props="props" v-if="props.row.access > 0" style="background-color: blue; color: white;">
          for admin ( {{ props.row.access }} ) <br /> and above
        </q-td>
      </template>

      <template v-slot:body-cell-status="props">
        <q-td :props="props" v-if="props.row.status == -1" style="background-color: red; color: white;">unOpened
          task</q-td>
        <q-td :props="props" v-if="props.row.status == 0" style="background-color: green; color: white;">submit</q-td>
        <q-td :props="props" v-if="props.row.status == 1" style="background-color: blue; color: white;">user
          verify</q-td>
        <q-td :props="props" v-if="props.row.status == 2" style="background-color: yellow;">admin verify</q-td>
        <q-td :props="props" v-if="props.row.status == 3"
          style="background-color: green; color: white;">completed</q-td>
      </template>

      <template v-slot:body-cell-action="props">
        <q-btn label="edit" @click="edit(props.row)" />
        <q-btn label="distribute" @click="setUserList(JSON.parse(props.row.prevOccupied), props.row.shares)" />

        <q-dialog v-model="dialog" persistent>
          <q-card style="min-width: 350px">
            <q-card-section>
              <div class="text-h6 text-center">كامل المدة: {{ totalShare }} دقيقة</div>
              <div class="text-h6 text-center">المتبقي: {{ remainingShares }} دقيقة</div>
              <hr />
            </q-card-section>

            <q-card-section class="q-pt-none">
              <div class="col">
                <div class="row" v-for="(user, n) in userListShares">
                  <div v-if="n == 0" class="row items-center q-my-sm">
                    <div style="width: 130px;">منفذ المهمة: {{ user.id }}</div>
                    <q-input dense label="الأسهم:" v-model.number="user.shares" type="number" filled
                      style="width: 75px;" />
                    <div class="text-center" style="width: 50px;">/ {{ props.row.shares }}</div>
                  </div>
                  <div v-else class="row items-center q-my-sm">
                    <div style="width: 130px;">المتحقق من المهمة: {{ user.id }}</div>
                    <q-input dense label="الأسهم:" v-model.number="user.shares" type="number" filled
                      style="width: 75px;" />
                    <div class="text-center" style="width: 50px;">/ {{ props.row.shares / 5 }}</div>
                  </div>
                </div>
              </div>
            </q-card-section>

            <q-card-actions align="right" class="text-primary">
              <q-btn flat label="Cancel" v-close-popup />
              <q-btn flat label="Submit" color="primary" @click="submit(props.row.id)" />
            </q-card-actions>
          </q-card>
        </q-dialog>
      </template>
    </q-table>

    <div class="row justify-between">
      <div class="column q-mx-auto" style="width: 500px; padding: 20px;">
        <div class="text-h4 text-center q-mb-lg">أضف أو عدل مهمة</div>

        <q-form @submit="addTask" class="q-gutter-md">
          <q-input filled v-model="task.taskId" label="taskId" lazy-rules hint="id or leave it empty for new task" type="number" />
          <hr />

          <q-input filled v-model="task.access" label="access" lazy-rules hint="for admins access" type="number" />
          <hr />

          <div>choose task status</div>
          <q-option-group v-model="task.status" :options="statusOptions" color="primary" />
          <hr />

          <q-input filled v-model="task.shares" label="shares" lazy-rules hint="shares" type="number" />
          <hr />

          <q-input filled v-model="task.parentId" label="parentId" lazy-rules hint="parentId" type="number" />
          <hr />

          <div>choose task type</div>
          <q-option-group v-model="task.taskType" :options="taskNames" color="primary" />
          <hr />

          <q-input filled v-model="task.reDoIt" label="reDoIt" lazy-rules hint="reDoIt" type="number" />
          <hr />

          <div class="row justify-between">
            <q-btn label="Submit" type="submit" color="primary" :loading="loading" />
            <q-btn label="Close Editing" color="red" @click="reset()" />
          </div>
        </q-form>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { useMutation, useQuery } from '@vue/apollo-composable';
import { gql } from '@apollo/client/core';
import { useRoute } from "vue-router";
import { computed, ref } from 'vue';
import { jwtToken } from './config';

const route = useRoute();

const userListShares = ref([])
const totalShare = ref(0);
const dialog = ref(false)
const task = ref({ taskId: null, shares: 0, parentId: 0, taskName: '', taskType: -1, reDoIt: 0, access: 0, status: null })

const taskNames = [
  { label: 'إضافة فهرس', value: 0 },
]

const statusOptions = [
  { label: 'غير مفعلة', value: -1 },
  { label: 'قيد التنفيذ', value: 0 },
  { label: 'قيد التحقق', value: 1 },
  { label: 'قيد مراجعة الأدمن', value: 2 },
  { label: 'منتهية', value: 3 },
]

function setUserList(usersIds, shares) {
  totalShare.value = 0;
  userListShares.value = [];

  for (let i = 0; i < usersIds.length; i++) {
    totalShare.value += i == 0 ? shares : shares / 5
    const id = usersIds[i];
    userListShares.value.push({ id: id, shares: i == 0 ? shares : shares / 5 })
  }

  dialog.value = true
}

const remainingShares = computed(() => {
  var remain = 0;
  for (const el of userListShares.value) {
    remain += el.shares;
  }
  return totalShare.value - remain;
})

const GET_ALL_TASKS = gql`
  query adminGetAllTasks {
    adminGetAllTasks(curriculumId: ${route.params.curriculumId}, jwtToken: "${jwtToken.value}") {
      id
      curriculumId
      parentId
      time
      shares
      taskName
      occupied
      status
      reDoIt
      reDoItNum
      access
    }
  }
`;

const SUBMIT_SHARES = gql`
  mutation adminSubmitShares(
    $jwtToken: String!
    $curriculumId: Int!
    $taskId: Int!
    $data: String!
  ) {
    adminSubmitShares(
      jwtToken: $jwtToken
      curriculumId: $curriculumId
      taskId: $taskId
      data: $data
    )
  }
`
const { mutate: submitData } = useMutation(SUBMIT_SHARES)

const { result, loading, refetch } = useQuery(GET_ALL_TASKS, null, { fetchPolicy: 'network-only' });

const columns = [
  { name: 'id', align: 'center', label: 'ID', field: 'id', sortable: true },
  { name: 'curriculumId', align: 'center', label: 'curriculum Id', field: 'curriculumId', sortable: true },
  { name: 'parentId', align: 'center', label: 'Parent ID', field: 'parentId', sortable: true },
  { name: 'time', align: 'center', label: 'Time', field: 'time', sortable: true },
  { name: 'shares', align: 'center', label: 'Shares', field: 'shares', sortable: true },
  { name: 'taskName', align: 'center', label: 'task Name', field: 'taskName', sortable: true },
  { name: 'shares', align: 'center', label: 'Shares', field: 'shares', sortable: true },
  { name: 'status', align: 'center', label: 'status', field: 'status', sortable: true },
  { name: 'occupied', align: 'center', label: 'Occupied', field: 'occupied', sortable: true },
  { name: 'access', align: 'center', label: 'Access', field: 'access', sortable: true },
  { name: 'reDoIt', align: 'center', label: 'reDoIt', field: 'reDoIt', sortable: true },
  { name: 'reDoItNum', align: 'center', label: 'reDoItNum', field: 'reDoItNum', sortable: true },
  { name: 'action', align: 'center', label: 'action', field: 'action' },

];

const rows = computed(() => {
  if (!result.value?.adminGetAllTasks) return [];
  return result.value.adminGetAllTasks;
});

async function submit(taskId) {
  const res = await submitData({
    jwtToken: jwtToken.value,
    curriculumId: Number(route.params.curriculumId),
    taskId: taskId,
    data: JSON.stringify(userListShares.value),
  })

  dialog.value = false;
  await refetch();
}

const UPDATE_TASK = gql`
  mutation adminCreateTask(
    $taskId: Int
    $status: Int
    $access: Int!
    $jwtToken: String!
    $curriculumId: Int!
    $shares: Int!
    $parentId: Int!
    $taskName: String!
    $taskType: Int!
    $reDoIt: Int!
  ) {
    adminCreateTask(
      taskId: $taskId
      status: $status
      access: $access
      jwtToken: $jwtToken
      curriculumId: $curriculumId
      shares: $shares
      parentId: $parentId
      taskName: $taskName
      taskType: $taskType
      reDoIt: $reDoIt
    )
  }
`

const { mutate: addNewTask } = useMutation(UPDATE_TASK)

async function addTask() {
  for (const el of taskNames) {
    if (el.value != task.value.taskType) continue;
    task.value.taskName = el.label;
  }

  await addNewTask({
    taskId: Number(task.value.taskId),
    status: task.value.status,
    access: Number(task.value.access),
    jwtToken: jwtToken.value,
    curriculumId: Number(route.params.curriculumId),
    shares: Number(task.value.shares),
    parentId: Number(task.value.parentId),
    taskName: task.value.taskName,
    taskType: task.value.taskType,
    reDoIt: Number(task.value.reDoIt),
  })

  await refetch();
  reset()
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

function reset() {
  task.value = { taskId: null, shares: 0, parentId: 0, taskName: '', taskType: -1, reDoIt: 0, access: null };
}

function edit(data) {
  let t = -1;
  for (const el of taskNames) {
    if (el.label != data.taskName) continue;
    t = el.value;
  }

  task.value = { taskId: data.id, shares: data.shares, parentId: 0, taskName: data.taskName, taskType: t, reDoIt: data.reDoIt, access: data.access };
}
</script>
