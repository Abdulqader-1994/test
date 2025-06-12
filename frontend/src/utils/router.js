import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import Terms from '../views/terms.vue'
import Privacy from '../views/privacy.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/terms', name: 'terms', component: Terms },
    { path: '/privacy', name: 'privacy', component: Privacy },
    // Redirect any undefined route to the home page
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

export default router
