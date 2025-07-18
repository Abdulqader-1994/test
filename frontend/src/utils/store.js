import { defineStore } from "pinia"
import { computed, ref } from "vue"

export const storageStore = defineStore('storage', () => {
  const user = ref(null)
  const signing = ref(false)

  const isAuthed = computed(() => user.value != null)

  return { user, signing, isAuthed }
}, { persist: true })