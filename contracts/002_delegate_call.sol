// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/** 
    代理合约调用： 使用B合约的逻辑去更新A合约的状态变量
    效果： msg.sender修改为 MOA账户；  A合约的状态变量都会有改变
    要求： 被代理合约与代理合约的状态变量要保持一致，否则结果会出错
*/

contract B {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = 5*_num;
        sender = msg.sender;
        value = msg.value;
    } 
}

contract A {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(address _contract, uint256 _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSelector(B.setVars.selector, _num)
        );
        require(success, "deletecall failed");
    }
}