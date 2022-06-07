import { ethers } from 'ethers'
import storageAbi from './abi/storage.json'
import erc20Abi from './abi/erc20.json'

export const storageContract = new ethers.Contract('0xFa77D1D8AADDd9a263C7d685375EF148E268c558', storageAbi)

export function createErc20Contract(address) {
  return new ethers.Contract(address, erc20Abi)
}

export const tokenContracts = [
  createErc20Contract('0x959204AAb55BfEEed71B4361B271628E6b9a9Adf'),
  createErc20Contract('0xb566c1239d98472550B6c372E2BCf40e9fc2da10'),
  createErc20Contract('0x4D8eB0B3665Ae0B11001B2F89db97ba49d8f576E'),
]
