<template>
  <div class="container">
    <p>Balance: {{ balance }} ETH</p>
  </div>
</template>

<script>
import { utils, BigNumber } from 'ethers'

export default {
  name: 'HomeView',
  data() {
    return {
      balance: 0,
      transactions: [],
    }
  },
  methods: {
    async updateBalance() {
      console.log('Updating balance')
      if (!this.$metamask.provider) return

      // const balance = await this.$metamask.provider.getBalance(this.$metamask.accounts[0])
      // The line above equates to the following lines:
      const balanceHex = await this.$metamask.provider.send('eth_getBalance', [ this.$metamask.accounts[0] ])
      const balance = BigNumber.from(balanceHex)

      this.balance = utils.formatUnits(balance)
    },
  },
  watch: {
    '$metamask.accounts'() {
      this.updateBalance()
    }
  },
  mounted() {
    this.updateBalance()
  }
}
</script>
<style scoped>
.container {
  max-width: 560px;
  margin: 0 auto;
  border-radius: 8px;
  padding: 10px;
  background-color: #eeeeee;
  border: 1px solid #ccc;
  box-shadow: 0px 5px 10px 2px #ddd;
}
</style>
