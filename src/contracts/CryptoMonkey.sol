// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
 * This code is only for showing the code behind the contracts used by this vue app,
 * you dont really need it in this codebase
*/
// Taken from https://github.com/imsudonym/blockchain-training-contracts/blob/master/contracts/1_CryptoMonkey/CryptoMonkey.sol

contract CryptoMonkey {
	uint maxMonkeys = 10 ** 6;
	
	struct Monkey {
		uint id;
		string name;
	}
	
	Monkey[] public monkeys;

	function createMonkey(uint _id, string memory _name) private {
		monkeys.push(Monkey(_id, _name));
	}

	function _generateRandomId(string memory _str) private pure returns(uint) {
		uint rand = uint(keccak256(abi.encodePacked(_str)));
		return rand % 7;
	}
	
	function createRandomMonkey(string memory _name) public {
		uint randId = _generateRandomId(_name);
		createMonkey(randId, _name);
	}
}