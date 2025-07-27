// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
原理：
metamask钱包签名：
1、 对明文进行keccak256(abi.encodePacked(_message))编码和Hash
2、 对第一步的编码信息，再次进行编码：
        keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
3、 使用metamask，对第一步的编码信息进行签名，
    ethereum.request({method: "personal_sign", params: [account, hash]})
4、 使用第三步签名信息与第二步的信息恢复，验证EOA账号
5、 使用明文信息、签名信息和EOA账号验证是否一致
*/

contract VerifySig {

    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns(bool){
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory _message) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_message));
    } 

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns(address){
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v){
        require(_sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(_sig, 0x20))
            s := mload(add(_sig, 0x40))
            v := byte(0, mload(add(_sig, 0x60)))
        }
    }   
}