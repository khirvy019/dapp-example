<template>
  <div class="container">
    <h3>Storage Contract</h3>
    <hr/>
    <form v-on:submit.prevent="updateValue">
      <input type="number" v-model="inputValue"/>
      <button type="submit">
        Update
      </button>
    </form>
    <p>Value: {{ value }}</p>

    <div v-if="numberUpdateHistory && numberUpdateHistory.length">
      <h5>Number Updates</h5>
      <div
        v-for="(numberUpdate, index) in numberUpdateHistory"
        :key="index"
        class="log-container"
      >
        <div>
          From: <span>{{ numberUpdate.from }}</span>
        </div>
        <div>
          To: <span>{{ numberUpdate.to }}</span>
        </div>
        <div>
          Updated By:{{ numberUpdate.updatedBy }}
        </div>
        <hr/>
        <div>
          Tx: <small>{{ numberUpdate.hash }}</small>
        </div>
        <div>
          Block#: <small>{{ numberUpdate.hash }}</small>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { storageContract } from '../contracts'
import { BigNumber } from 'ethers'

export default {
  name: 'StorageView',
  data() {
    return {
      inputValue: null,
      value: null,
      numberUpdateHistory: [],
    }
  },
  methods: {
    fetchValue() {
      const contract = storageContract.connect(this.$metamask.provider)
      contract.retrieve()
        .then(value => {
          this.value = value
        })
    },
    updateValue() {
      const contract = storageContract.connect(this.$metamask.signer)
      contract.store(BigNumber.from(this.inputValue))
        .then(response => {
          response.wait().then(() => {
            this.fetchValue()
            this.fetchNumberUpdateHistory()
          })
        })
    },
    fetchNumberUpdateHistory() {
      const contract = storageContract.connect(this.$metamask.provider)
      const filter = contract.filters.NumberUpdate()

      contract.queryFilter(filter)
        .then(logs => {
          this.numberUpdateHistory = logs.map(log => {
            return {
              hash: log.transactionHash,
              blockNumber: log.blockNumber,
              from: log.args.from,
              to: log.args.to,
              updatedBy: log.args.updatedBy,
            }
          })
          this.numberUpdateHistory.reverse()
        })
      
    }
  },
  mounted() {
    this.fetchValue()
    this.fetchNumberUpdateHistory()
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

.log-container {
  margin-bottom: 10px;
  border: 1px solid #ccc;
  border-radius: 8px;
  background-color: #fefefe;
  padding: 10px;
}

</style>
