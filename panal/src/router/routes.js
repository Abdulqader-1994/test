import { jwtToken } from 'src/pages/config'
import Curriculum from 'src/pages/curriculum.vue'
import User from 'src/pages/user.vue'
import Task from 'src/pages/task.vue'

const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/IndexPage.vue'), },
      { path: 'curriculum', component: Curriculum, beforeEnter: (to, from, next) => (jwtToken.value) ? next() : next('/'), },
      { path: 'task/:curriculumId', component: Task, beforeEnter: (to, from, next) => (jwtToken.value) ? next() : next('/'), },
      { path: 'user', component: User, beforeEnter: (to, from, next) => (jwtToken.value) ? next() : next('/'), },
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue')
  }
]

export default routes
