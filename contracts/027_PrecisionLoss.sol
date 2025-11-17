// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract PrecisionLoss {
    uint constant public sharesPerEth = 10;
    uint constant public weiPerEth = 1e18;
    mapping (address => uint) public balances;

    function buyShares() public payable {
        uint shares = msg.value / weiPerEth * sharesPerEth;
        balances[msg.sender] += shares;
    }

    function sellShares(uint shares) public  {
        require(balances[msg.sender] >= shares);
        uint eth = shares / sharesPerEth;
        balances[msg.sender] -= shares;
        payable(msg.sender).transfer(eth * weiPerEth);
    }
}