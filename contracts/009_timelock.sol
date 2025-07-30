// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// 时间锁

contract TimeLock{
    address public owner;
    mapping (bytes32 => bool) public queued;

    error NotOwnerError();
    error AlreadyQueueError(bytes32);
    error InvalidTimestampError(uint, uint);
    error NotQueuedError(bytes32);
    error TimestampNotPassedError(uint, uint);
    error TxIdFailedError();

    uint constant MIN_DELAY = 10;
    uint constant MAX_DELAY = 1000;
    uint constant GRADCE_PERIOD = 1000;

    event Queue(bytes32 indexed ,address indexed , uint, string, bytes, uint);
    event Execute(bytes32, address, uint, string, bytes, uint);

    receive() external payable { }

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender != owner){
            revert NotOwnerError();
        }
        _;
    }

    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) public  pure returns(bytes32 txId){
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external  {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // check tx_id
        if(queued[txId]){
            revert AlreadyQueueError(txId);
        }
        // check timestamps
        if(_timestamp < block.timestamp + MIN_DELAY || _timestamp > block.timestamp + MAX_DELAY){
            revert InvalidTimestampError(block.timestamp, _timestamp);
        }
        // queue tx
        queued[txId] = true;

        emit Queue(
            txId,_target, _value, _func, _data, _timestamp
        );
    }

    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external onlyOwner payable returns(bytes memory){
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // check tx is queued
        if(!queued[txId]){
            revert NotQueuedError(txId);
        }

        // check block.timestamp > _timestamp
        if(block.timestamp < _timestamp){
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }

        if(block.timestamp > _timestamp + GRADCE_PERIOD){
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }
        // delete tx from queue
        queued[txId] = false;

        bytes memory data;
        if(bytes(_func).length > 0){
            data = abi.encodePacked(
                bytes4(keccak256(bytes(_func))), _data
            );
        }else{
            data = _data;
        }
        // execute the tx
        (bool success, bytes memory result) = _target.call{value: _value}(_data);
        if(!success){
            revert TxIdFailedError();
        }

        emit Execute(txId, _target, _value, _func, _data, _timestamp);
        return result;
    }
}

contract TestTimeLock {
    address public timelock;

    constructor(address _timelock){
        timelock = _timelock;
    }

    function test() external view {
        require(msg.sender == timelock, "timelock failed");
    }
}