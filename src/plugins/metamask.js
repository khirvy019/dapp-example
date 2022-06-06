import { ethers } from 'ethers';

class MetamaskConnector {
  constructor() {
    this._default_rpc_url = 'http://localhost:8545'
    this._default_provider = new ethers.providers.JsonRpcBatchProvider(this._default_rpc_url)
    this._provider = null
    this.accounts = []
  }

  get provider() {
    if (this._provider instanceof ethers.providers.BaseProvider) return this._provider
    return this._default_provider
  }

  set provider(newProvider) {
    if (newProvider instanceof ethers.providers.BaseProvider) this._provider = newProvider
  }

  get signer() {
    if (this._provider?.getSigner?.call) return this._provider.getSigner()
    return undefined
  }

  async connect() {
    if (window.ethereum === undefined) return { success: false, error: 'Metamask provider not found' }

    const _metamaskProvider = new ethers.providers.Web3Provider(window.ethereum)
    this.accounts = await _metamaskProvider.send("eth_requestAccounts", [])
    this.provider = _metamaskProvider

    return {
      success: true,
      accounts: this.accounts,
    }
  }
}


export default {
  install(Vue, /* opts */) {
    Vue.prototype.$metamask = Vue.observable(new MetamaskConnector())
  }
}