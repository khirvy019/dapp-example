// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
 * This code is only for showing the code behind the contracts used by this vue app,
 * you dont really need it in this codebase
*/
// Simple ERC20 token swap

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapContract {
    event Swap(address indexed fromToken, address indexed toToken, uint256 amount, uint256 returnAmount);

    struct SwapRatio {
        uint256 from;
        uint256 to;
    }

    // token => SwapRatio
    // map holds the value of the token against the main currency of the chain
    mapping(address => SwapRatio) private _swapRatio;

    function sort(uint256 a, uint256 b) internal pure returns(uint256, uint256){
        if (a > b){
            return (a,b);
        } else return (b,a);
    }

    /**
     * From https://github.com/pakchu/Fractions/blob/Fractions/libraries/Fractions.sol#L28
     * @dev Function for getting greatest common divisor, which is inevitable to operate Fractions.
     * This function is using Euclidean Algoithm, you can find info's here: https://en.wikipedia.org/wiki/Euclidean_algorithm
     * Has time complexity of O(log(min(a,b))), and a nice proof for this: https://www.geeksforgeeks.org/time-complexity-of-euclidean-algorithm/
     */
    function gcd(uint256 a, uint256 b) internal pure returns(uint256){
        (a,b) = sort(a,b);
        while(b != 0) {
            (a, b) = (b, a % b);
        }
        return a;
    }

    function _reduceSwapRatio(SwapRatio memory swapRatio) internal pure returns (SwapRatio memory) {
        uint256 ratioGCD = gcd(swapRatio.from, swapRatio.to);
        swapRatio.from = swapRatio.from/ratioGCD;
        swapRatio.to = swapRatio.to/ratioGCD;
        return swapRatio;
    }

    function setSwapRatio(address token,uint256 fromAmount, uint256 toAmount) public {
        _swapRatio[token] = _reduceSwapRatio(SwapRatio(fromAmount, toAmount));
    }

    function getSwapRatio(address token) public view returns (uint256 from, uint256 to) {
        SwapRatio memory ratio = _swapRatio[token];
        from = ratio.from;
        to = ratio.to;
    }

    function setSwapRatioMulti(
        address[] memory token,
        uint256[] memory fromAmount,
        uint256[] memory toAmount
    ) public {
        require(token.length == fromAmount.length, "Parameters must have equal length");
        require(fromAmount.length == toAmount.length, "Parameters must have equal length");

        for (uint i=0; i < token.length; i++) {
            setSwapRatio(token[i], fromAmount[0], toAmount[0]);
        }
    }

    function getExpectedReturn(address fromToken, address toToken, uint256 amount) public view returns (uint256) {
        SwapRatio memory ratioFrom;
        SwapRatio memory ratioTo;

        if (fromToken == address(0)) {
            ratioFrom = SwapRatio(1, 1);
        } else {
            ratioFrom = _swapRatio[fromToken];
        }

        if (toToken == address(0)) {
            ratioTo = SwapRatio(1, 1);
        } else {
            ratioTo = _swapRatio[toToken];
        }

        SwapRatio memory newRatio = _reduceSwapRatio(SwapRatio(ratioTo.to * ratioFrom.from, ratioTo.from * ratioFrom.to));
        return (amount * newRatio.to) / newRatio.from;
    }

    function swap(address fromToken, address toToken, uint256 amount) external payable returns (bool) {
        require(amount > 0, "Invalid amount");
        uint256 returnAmount = this.getExpectedReturn(fromToken, toToken, amount);
        require(returnAmount > 0, "Unable to get expected return");
        if (fromToken == address(0)) {
            require(msg.value == amount, "Incorrect amount sent for swap");
        } else {
            require(
                IERC20(fromToken).transferFrom(msg.sender, address(this), amount),
                "Swap Failed!"
            );
        }

        if (toToken == address(0)) {
            payable(msg.sender).transfer(returnAmount);
        } else {
            require(
                IERC20(toToken).transfer(msg.sender, returnAmount),
                "Swap Failed!"
            );
        }

        emit Swap(fromToken, toToken, amount, returnAmount);
        return true;
    }
}
