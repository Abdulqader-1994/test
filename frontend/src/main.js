import { createApp, h, provide } from 'vue'
import { DefaultApolloClient } from '@vue/apollo-composable'
import App from './App.vue'
import router from './utils/router'
import { words } from './utils/translation'
import { createI18n } from 'vue-i18n'
import './assets/main.css'
import { ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client/core'
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

// Define the feature detection function
function isES6Supported() {
  try {
    new Function('(a = 0) => a');
    return true;
  } catch (err) {
    return false;
  }
}

function hasFlexbox() {
  const d = document.createElement('div');
  d.style.display = 'flex';
  return d.style.display === 'flex';
}

const i18n = createI18n({
  legacy: false,
  locale: 'ar',
  fallbackLocale: 'ar',
  messages: words,
})

const httpLink = createHttpLink({ uri: 'http://localhost:8787/api' })

// Cache implementation
const cache = new InMemoryCache()

// Create the apollo client
const apolloClient = new ApolloClient({ link: httpLink, cache })

const app = createApp({
  setup() { provide(DefaultApolloClient, apolloClient) },
  render: () => h(App),
})

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

if (!isES6Supported() || !hasFlexbox()) {
  alert('Your browser is not supported. Please update your browser for the best experience.');
} else {
  app.use(router)
  app.use(i18n)
  app.use(pinia)
  app.mount('#app')
}
