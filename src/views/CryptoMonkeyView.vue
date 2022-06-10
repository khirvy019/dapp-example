<template>
  <div class="container">
    <h3>Crypto Monkeys</h3>
    <hr/>
    <form v-on:submit.prevent="createNewMonkey">
      <input type="text" v-model="newMonkeyName"/>
      <button type="submit">
        Create new monkey
      </button>
    </form>
    <div>
      <h5>Monkeys</h5>
      <div
        v-for="(monkey, index) in monkeys"
        :key="index"
        class="monkey-item"
      >
        <div>UserID: {{ monkey.id }}</div>
        <div>Name: {{ monkey.name }}</div>
      </div>
    </div>
  </div>
</template>
<script>
import { cryptoMonkey } from '../contracts'
export default {
  name: 'CryptoMonkeyView',
  data() {
    return {
      newMonkeyName: '',
      monkeys: [],
    }
  },
  methods: {
    createNewMonkey() {
      if (this.newMonkeyName.length <= 0) return

      const contract = cryptoMonkey.connect(this.$metamask.signer)
      contract.createRandomMonkey(this.newMonkeyName)
        .then(response => {
          response.wait().then(() => {
            this.newMonkeyName = ''
            this.fetchMonkeys()
          })
        })
    },
    async fetchMonkeys() {
      const contract = cryptoMonkey.connect(this.$metamask.provider)
      this.monkeys = []
      let index = 0;
      while (index < 100) {
        try {
          const monkey = await contract.monkeys(index)
          this.monkeys.push(monkey)
          index++;
        } catch { break }
      }
    }
  },
  mounted() {
    this.fetchMonkeys()
  }
}
</script>
<style scoped>
.container {
  margin: 0 auto;
  width: 560px;
  border-radius: 8px;
  border: 1px solid #ccc;
  background-color: #eee;
  box-shadow: 0px 2px 5px 2px #ddd;
  padding: 10px;
}


.monkey-item {
  margin-bottom: 10px;
  border: 1px solid #ccc;
  border-radius: 8px;
  background-color: #fefefe;
  padding: 10px;
}
</style>