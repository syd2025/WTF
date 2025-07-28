// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// 多次委托调用

contract Multidelegatecall {
    error DelegatecallFailed();

    function multiDelegatecall(address _addr,bytes[] calldata data) external payable returns (bytes[] memory results){
        results = new bytes[](data.length);

        for(uint i; i<data.length; i++){
            (bool success, bytes memory result) = _addr.delegatecall(data[i]);
            require(success, "delegatecall failed");
            results[i] = result;
        }
    }

}


contract TestMultiDelegatecall {

    event Log(address caller, string func, uint256 i);

    function func1(uint256 x, uint256 y) external {
        emit Log(msg.sender, "func1", x+y);
    }

    function func2() external {
        emit Log(msg.sender, "func2", 2);
    }
}

contract Helper{
    function getFunc1(uint x, uint y) external pure returns(bytes memory){
        return abi.encodeWithSignature("func1(uint256,uint256)", x,y);
    }

    function getFunc2() external pure returns(bytes memory){
        return abi.encodeWithSignature("func2()");
    }
}