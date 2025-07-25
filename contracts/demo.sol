// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract TestContract1 {
    address public owner = msg.sender;

    function setOwner(address _owner) public {
        require(msg.sender == owner, "not owner");
        owner = _owner;
    }
}

contract TestContract2 {
    address public owner = msg.sender;
    uint256 public value = msg.value;
    uint256 public x;
    uint256 public y;

    constructor(uint256 _x, uint256 _y) payable  {
        x = _x;
        y = _y;
    }
}

contract Proxy {
    event Deploy(address addr);

    receive() external payable { }

    function deploy(bytes memory _code) 
        external 
        payable 
        returns(address)
        {
            address addr;
            // 汇编语言,create方法就是通过字节码部署合约
            assembly {
                // create(v,p,n)
                // v: amount of ETH to send
                // p: pointer in memory to start of code
                // n: size of code
                addr := create(callvalue(), add(_code, 0x20), mload(_code))
            }
            require(addr != address(0),"deploy failed");
            emit Deploy(addr);
            return addr;
    }

    // 执行字节码并发送以太币
    function execute(address _target, bytes memory _data) external payable {
        (bool sucess,) = _target.call{value: msg.value}(_data);
        require(sucess, "execute failed");

    }
}


// 辅助类
contract Helper {
    // 当对应的合约中的构造方法不带参数，使用如下方式获取字节码
    function getBytecode1() external pure returns(bytes memory){
        bytes memory bytecode = type(TestContract1).creationCode;
        return bytecode;
    }

    // 当对应的合约中的构造方法带参数，使用如下方式获取字节码
    function getBytecode2(uint256 _x, uint256 _y) external pure  returns(bytes memory){
        bytes memory bytecode = type(TestContract2).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_x, _y));
    }

    // 
    function getCalldata(address _owner) external pure returns(bytes memory){
        return abi.encodeWithSignature("setOwner(address)", _owner);
    }
}