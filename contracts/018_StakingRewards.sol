// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
1、合约变量
2、构造函数
3、管理员
4、设置持续时间、设置奖励速率
5、更新收益
6、质押、撤回、获取收益函数
7、状态查询函数
*/

contract StakingRewards {
    // 奖励token
    IERC20 public immutable rewardsToken;
    // 质押token
    IERC20 public immutable stakingToken;

    // 管理员
    address public owner;
    uint256 public duration;   // 持续时间
    uint256 public finishAt;   // 完成时间点
    uint256 public updatedAt;   // 更新时间点
    uint256 public rewardRate;  // 奖励比率
    uint256 public rewardPerTokenStored;  // 奖励数额

    mapping (address => uint256) public userRewardPerTokenPaid; // 每个代币对应的奖励数量
    mapping (address => uint256) public rewards;  // 每个账户的奖励数值
    mapping (address => uint256) public balanceOf;  // 每个账户的余额
    uint256 public totalSupply;  // 总的代币数量

    constructor(address _stakingToken, address _rewardsToken){
        owner = msg.sender;
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
    }

    // 验证是否是管理员
    modifier onlyOwner(){
        require(owner == msg.sender, "Not Owner");
        _;
    }

    function earned(address _account) public view returns(uint256){
        return balanceOf[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account]) / 1e18 + rewards[_account];
    }

    modifier updateReward(address _account){
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if(_account != address(0)){
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    function rewardPerToken() public view returns (uint256){
        if (totalSupply == 0){
            return rewardPerTokenStored; 
        }
        return rewardPerTokenStored + (rewardRate * (lastTimeRewardApplicable() - updatedAt) *1e18)/totalSupply;
    }

    // 上次奖励时间点
    function lastTimeRewardApplicable() public view returns(uint256){
        return _min(block.timestamp, finishAt);
    }

    // 获取最小值
    function _min(uint256 x, uint256 y) private pure returns(uint256){
        return x < y ? x : y;
    }

    // 设置持续时间和奖励速率
    function notifyRewardAmount(uint256 _amount) external onlyOwner updateReward(address(0)){
        // 当前时间超过完成时间
        if (block.timestamp > finishAt){
            rewardRate = _amount / duration;
        }else{
            uint256 remainingRewards = rewardRate * (finishAt - block.timestamp); // 剩下来的奖励值
            rewardRate = (remainingRewards + _amount) / duration;  // 奖励速率计算
        }

        require(rewardRate > 0 , "reward rate = 0");
        require(rewardRate * duration <= rewardsToken.balanceOf(address(this)), "reward amount > balance");

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    // 质押
    function stake(uint256 _amount) external updateReward(msg.sender){
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount); // 将用户质押的数量转移给合约
        balanceOf[msg.sender] += _amount; //  账户余额更新
        totalSupply += _amount;   // 总代币数量更新
    }

    // 提现
    function withdraw(uint256 _amount) external updateReward(msg.sender){
        require(_amount > 0, "amount = 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
    }

    // 获得奖励
    function getReward() external updateReward(msg.sender){
        uint256 reward = rewards[msg.sender];
        if(reward > 0){
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    // 设置奖励时间
    function setRewardDuration(uint _duration) external onlyOwner{
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }
}