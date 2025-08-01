// SPDX-License-Identifier: MIT
// wtf.academy

// 透明可升级合约
// 本质上使用逻辑合约的方法去更新代理合约的状态变量

pragma solidity ^0.8.30;

contract CounterV1 {
    // address public implementation;
    // address public admin;
    uint256 public count;

    function inc() external {
        count += 1;
    }
}


contract CounterV2 {
    // address public implementation;
    // address public admin;
    uint256 public count;

    function inc() external {
        count += 1;
    }

    function decc() external {
        count -= 1;
    }
}

contract Proxy {
    bytes32 public constant IMPLEMENTATION_SLOT = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

    bytes32 public constant ADMIN_SLOT = bytes32(uint(keccak256("eip1967.proxy.admin")) - 1);

    constructor(){
        _setAdmin(msg.sender);
    }

    fallback() external payable { 
        _delegate(_getImplementation());
    }

    receive() external payable {
        _delegate(_getImplementation());
     }

    // 代理合约
    function _delegate(address _implementation) private {
        assembly{
            calldatacopy(0,0,calldatasize())

            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result

            case 0{
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }

        }
    }

    function upgradeTo(address _implemention)external {
        require(msg.sender == _getAdmin(), "not authorized");
        _setImplementation(_implemention);
    }

    function _getAdmin() private view returns(address){
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }
    
    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin = 0 address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    } 

    function _getImplementation() private  view returns(address){
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0 , "not acontract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    function admin() external  view returns(address){
        return _getAdmin();
    }

    function implementation() external view returns(address){
        return _getImplementation();
    }
}

library StorageSlot{
    struct AddressSlot{
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns(AddressSlot storage r){
        assembly{
            r.slot := slot
        }
    }
}

contract TestSlot{
    bytes32 public constant SLOT = keccak256("TEST_SLOT");

    function getSlot() external view returns(address){
        return StorageSlot.getAddressSlot(SLOT).value;
    }

    function writeSlot(address _addr) external {
        StorageSlot.getAddressSlot(SLOT).value = _addr;
    } 
}