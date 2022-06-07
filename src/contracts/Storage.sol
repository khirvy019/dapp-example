// SPDX-License-Identifier: GPL-3.0


/*
 * This code is only for showing the code behind the contracts used by this vue app,
 * you dont really need it in this codebase
*/
// This contract example is usually given as example in Remix
// Changed the code to emit event NumberUpdate

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {
    event NumberUpdate(address indexed updatedBy, uint256 from, uint256 to);
    uint256 number;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        uint256 _previous = number;
        number = num;
        emit NumberUpdate(msg.sender, _previous, number);
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}
