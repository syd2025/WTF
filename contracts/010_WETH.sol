// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// 包装以太币
// 不需要转换代币，在ERC20协议之上封装
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{
    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);

    constructor() ERC20("Wrapped Ether","WETH"){

    }

    fallback() external payable {
        deposit();
     }

     receive() external payable { }

    function deposit() public  payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) external  {
        _burn(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }
}