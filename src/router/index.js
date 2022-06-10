import Vue from 'vue'
import VueRouter from 'vue-router'
import HomeView from '../views/HomeView.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/about',
    name: 'about',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/AboutView.vue')
  },
  {
    path: '/storage',
    name: 'storage',
    component: () => import('../views/StorageContractView.vue')
  },
  {
    path: '/crypto-monkeys',
    name: 'crypt-monkeys',
    component: () => import('../views/CryptoMonkeyView.vue')
  },
  {
    path: '/swap',
    name: 'swap',
    component: () => import('../views/SwapView.vue')
  }
]

const router = new VueRouter({
  routes
})

export default router
