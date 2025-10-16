// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract TipJar {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function tip() public payable {
        require(msg.value > 0, "You should send a tip to use this function");
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "you are not owner");
        _;
    }

    function withdraw() public onlyOwner{
        // 查询余额
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "no tips to withdraw");
        payable(owner).transfer(contractBalance);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
}