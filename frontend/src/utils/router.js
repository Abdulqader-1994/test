import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import Terms from '../views/terms.vue'
import Privacy from '../views/privacy.vue'
import Chat from '../views/chat.vue'
import SignIn from '../views/signin.vue'
import SignUp from '../views/signup.vue'

const authed = () => {
  const appStorage = JSON.parse(localStorage.getItem('appStorage'))
  return (appStorage && appStorage.user) ? true : false;
}


const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  scrollBehavior(to) {
    if (to.hash) {
      return { el: to.hash, behavior: 'smooth' }
    }
    return { top: 0 }
  },
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/terms', name: 'terms', component: Terms },
    { path: '/privacy', name: 'privacy', component: Privacy },
    {
      path: '/signin',
      name: 'signin',
      component: SignIn,
      beforeEnter: (to, from, next) => authed() ? next('/chat') : next()
    },
    {
      path: '/signup',
      name: 'signup',
      component: SignUp,
      beforeEnter: (to, from, next) => authed() ? next('/chat') : next()
    },
    {
      path: '/chat',
      name: 'chat',
      component: Chat,
      beforeEnter: (to, from, next) => authed() ? next() : next('/signin')
    },

    // Redirect any undefined route to the home page
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

export default router
