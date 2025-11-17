// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract NotInitialized {
    address public owner;

    bool public initialized;

    mapping (address => uint256) funds;

    function constructor1() external {
        owner = msg.sender;
        initialized = true;
    }

    function start() external payable {
        require(initialized);
        funds[msg.sender] = msg.value;
    }

}