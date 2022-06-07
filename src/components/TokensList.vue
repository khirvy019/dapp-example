<template>
  <div>
    <h4>ERC20 Tokens</h4>
    <div
      v-for="(tokenInfo, index) in tokensInfo"
      :key="index"
      class="token-container"
    >
      <h5>{{ tokenInfo.name }}</h5>
      <div>
        Balance: {{ tokenInfo.balance }} {{ tokenInfo.symbol }}
      </div>
    </div>
  </div>
</template>
<script>
import { tokenContracts, createErc20Contract } from '../contracts'
import { utils } from 'ethers'

export default {
  name: 'TokensList',
  data() {
    return {
      tokensInfo: [],
    }
  },
  methods: {
    async loadTokenInfo() {
      for(var i = 0; i < tokenContracts.length; i++) {
        const tokenContract = tokenContracts[i]
        const contract = tokenContract.connect(this.$metamask.provider)
        const tokenInfo = {
          address: contract.address,
          name: await contract.name(),
          symbol: await contract.symbol(),
          decimals: await contract.decimals(),
          balance: 0,
        }

        this.tokensInfo.push(tokenInfo)
      }

      this.updateBalances()
    },
    updateBalances() {
      this.tokensInfo.forEach(async (token) => {
        const contract = createErc20Contract(token.address).connect(this.$metamask.provider)
        const balance = await contract.balanceOf(this.$metamask.accounts[0])
        token.balance = utils.formatUnits(balance, token.decimals)
      })
    },
  },
  watch: {
    '$metamask.accounts'() {
      this.updateBalances()
    }
  },
  mounted() {
    this.loadTokenInfo()
  }
}
</script>
<style scoped>
.token-container {
  padding: 5px;
  border-bottom: 1px solid #ccc;
}

h5, h4 {
  margin: 5px 0px;
}
</style>
