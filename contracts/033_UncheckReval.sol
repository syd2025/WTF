// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract BadLottery{
    address public winner;

    uint256 public  winAmount;

    bool public paidOut = false;

    function sendToWinner() public {
        require(!paidOut);
        payable (msg.sender).send(address(this).balance);
    }
}