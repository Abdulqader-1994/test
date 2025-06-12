import { createApp } from 'vue'
import App from './App.vue'
import router from './utils/router'
import { words } from './utils/translation'
import { createI18n } from 'vue-i18n'
import './assets/main.css'

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

const app = createApp(App)

if (!isES6Supported() || !hasFlexbox()) {
  alert('Your browser is not supported. Please update your browser for the best experience.');
} else {
  app.use(router)
  app.use(i18n)
  app.mount('#app')
}
