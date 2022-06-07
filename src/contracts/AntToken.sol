// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
 * This code is only for showing the code behind the contracts used by this vue app,
 * you dont really need it in this codebase
*/
// Generated from docs.openzeppelin.com/contracts/4.x/wizard
// Deploy with remix IDE to auto import dependencies
// Example ERC20 token, change the name symbol and initial supply to your liking

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AnToken is ERC20 {
    constructor() ERC20("AnToken", "ATK") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}
