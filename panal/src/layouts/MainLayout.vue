<template>
  <q-layout view="hHh lpR fFf">
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn dense flat round icon="menu" @click="toggleLeftDrawer" />
        <q-toolbar-title>
          <RouterLink to="/" style="text-decoration: none; padding-left: 10px; color: white;">AILENCE Admin Panal</RouterLink>
        </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-drawer show-if-above v-model="leftDrawerOpen" side="left" bordered class="bg-grey-3">
      <q-list>
        <!-- curriculum -->
        <q-item clickable>
          <q-item-section>
            <RouterLink to="/curriculum" style="text-decoration: none;">Curriculums</RouterLink>
          </q-item-section>
        </q-item>

        <!-- user -->
        <q-item clickable>
          <q-item-section>
            <RouterLink to="/user" style="text-decoration: none;">Users</RouterLink>
          </q-item-section>
        </q-item>

        <!-- task -->
        <q-item clickable>
          <q-item-section>
            <RouterLink to="/task" style="text-decoration: none;">Tasks</RouterLink>
          </q-item-section>
        </q-item>
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref } from 'vue'
const leftDrawerOpen = ref(false)

function toggleLeftDrawer() {
  leftDrawerOpen.value = !leftDrawerOpen.value
}
</script>
