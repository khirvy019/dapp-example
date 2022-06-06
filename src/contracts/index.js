import { ethers } from 'ethers'
import storageAbi from './abi/storage.json'

export const storageContract = new ethers.Contract('0xFa77D1D8AADDd9a263C7d685375EF148E268c558', storageAbi)
