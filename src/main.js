// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import locale from 'element-ui/lib/locale/lang/ja'
import VueMaterial from 'vue-material'
import 'vue-material/dist/vue-material.min.css'
import 'vue-material/dist/theme/default.css'

Vue.use(ElementUI, { locale })
Vue.config.productionTip = false
Vue.use(VueMaterial)

Vue.filter('title_cut', function (value) {
  if (value.length >= 50) {
    return value.slice(0, 75) + '...'
  }
  return value
})

Vue.filter('details_cut', function (value) {
  if (value.length >= 120) {
    return value.slice(0, 170) + '...'
  }
  return value
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>'
})
