import { boot } from 'quasar/wrappers'
import vue3GoogleLogin from 'vue3-google-login'

export default boot(({ app }) => {
  app.use(vue3GoogleLogin, { clientId: '1039087411910-kvkrgh0os6d8h8rq7v7anf2uv14kfi2m.apps.googleusercontent.com' })
})
