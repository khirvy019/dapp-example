<template>
  <nav>
    <div  class="nav-title-section">
      <h2 @click="$router.go('/')" style="cursor:pointer;">Dapp</h2>
    </div>
    <div>
      <router-link to="/">Home</router-link> |
      <router-link to="/about">About</router-link>
    </div>
    <div style="margin-left:5px;">
      <button v-if="!connectedAccounts.length" @click="connectToMetamask()">Connect to Metamask</button>
      <div v-else>
        0x...{{ connectedAccounts[0].substr(-5) }}
      </div>
    </div>
  </nav>
</template>
<script>
export default {
  name: 'HeaderNav',
  computed: {
    connectedAccounts() {
      if (Array.isArray(this.$metamask?.accounts)) return this.$metamask.accounts
      return []
    }
  },
  methods: {
    connectToMetamask() {
      this.$metamask.connect()
        .then(console.log)
        .finally(() => this.$forceUpdate())
        .then(() => this.$metamask.provider.getNetwork().then(console.log))
    },
  }
}
</script>
<style scoped>
.nav-title-section {
  flex-grow: 1;
  display: flex;
}

nav {
  padding: 5px 10px;
  display: flex;
  align-items: center;
  text-align: left;
  border-bottom: 1px;
}

nav a {
  font-weight: bold;
  color: #2c3e50;
}

nav a.router-link-exact-active {
  color: #42b983;
}
</style>