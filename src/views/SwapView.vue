<template>
  <div class="container">
    <h3>Token Swap</h3>
    <TokensList ref="tokensList"/>
    <hr/>
    <form v-on:submit.prevent="performSwap()">
      <div class="field-section">
        <label>Swap from</label>
        <select v-model="swapFrom" >
          <option :value="null" disabled>Select token</option>
          <option v-for="(token, index) in tokensInfo" :key="index" :value="token">
            {{ token.name }}
          </option>
        </select>
      </div>

      <div class="field-section">
        <label>Swap to</label>
        <select v-model="swapTo">
          <option :value="null" disabled>Select token</option>
          <option v-for="(token, index) in tokensInfo" :key="index" :value="token">
            {{ token.name }}
          </option>
        </select>
      </div>

      <div class="field-section">
        <label>Amount</label>
        <input type="number" v-model="amount">
      </div>

      <hr/>

      <div v-if="swapFrom && swapTo" class="field-section">
        <label>
          Expected Return:
          <button v-on:click="calculateExpectedReturn()" type="button">
            Calculate
          </button>
        </label>
        <span>{{ expectedReturn }} {{ swapTo.symbol }}</span>
        <div v-if="calculatingReturns">
          Calculating ...
        </div>
      </div>
      <div class="field-section"><button v-if="!swapFromApproved" type="button" v-on:click="approveSwapFrom()">
          Approve
        </button>
        <button v-else-if="swapFrom && swapTo && amount" type="submit">
          Swap
        </button>
      </div>
    </form>
  </div>
</template>
<script>
import { utils } from 'ethers'
import { tokenContracts, createErc20Contract, swapContract } from '../contracts'
import TokensList from '../components/TokensList.vue'

export default {
  components: { TokensList },
  name: 'SwapView',
  data() {
    return {
      tokensInfo: [],

      swapFrom: null,
      swapTo: null,
      amount: 0,

      swapFromApproved: false,

      calculatingReturns: false,
      expectedReturn: 0,
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
    checkApprovedSwapFrom() {
      const contract = createErc20Contract(this.swapFrom.address).connect(this.$metamask.provider);
      const filter = contract.filters.Approval(this.$metamask.accounts[0], contract.address)
      contract.queryFilter(filter)
        .then(logs => {
          this.swapFromApproved = logs.length > 0
        })
        .catch(() => {
          this.swapFromApproved = false
        })
    },
    approveSwapFrom() {
      const contract = createErc20Contract(this.swapFrom.address).connect(this.$metamask.signer);
      const approveAmountHex = '0x' + 'f'.repeat(64)// hex for 2 ^ 256
      contract.approve(swapContract.address, approveAmountHex).then(response => {
        response.wait().then(() => this.checkApprovedSwapFrom())
      })
    },
    calculateExpectedReturn() {
      const contract = swapContract.connect(this.$metamask.provider)
      this.calculatingReturns = true
      contract.getExpectedReturn(
        this.swapFrom.address,
        this.swapTo.address,
        utils.parseUnits(String(this.amount), this.swapFrom.decimals),
      ).then(expectedReturn => {
        this.expectedReturn = utils.formatUnits(expectedReturn, this.swapTo.decimals)
      }).finally(() => {
        this.calculatingReturns = false
      })
    },
    performSwap() {
      const contract = swapContract.connect(this.$metamask.signer)
      contract.swap(
        this.swapFrom.address,
        this.swapTo.address,
        utils.parseUnits(String(this.amount), this.swapFrom.decimals),
      )
        .then(response => {
          response.wait().then(() => {
            this.swapFrom = null
            this.swapTo = null
            this.amount = 0
            this.$refs.tokensList.updateBalances()
          })
        })
    }
  },
  watch: {
    'swapFrom.address': {
      handler() {
        this.calculateExpectedReturn()
        this.checkApprovedSwapFrom()
      }
    },
    'swapTo.address': {
      handler() {
        this.calculateExpectedReturn()
      }
    },
    amount() {
      this.calculateExpectedReturn()
    }
  },
  mounted() {
    this.loadTokenInfo()
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

.field-section {
  margin-bottom: 5px;
  display: flex;
}

.field-section label {
  width: 25%;
}
</style>
