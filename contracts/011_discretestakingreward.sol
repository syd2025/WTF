// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// 离散质押奖励
// 本质： 对每个时间点的奖励按照每个人的比例进行计算
// 核心： 在某个时间点获取的比例 = 某个时间点的奖励 / 某个时间点的质押数
 
interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipent, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipent, uint256 amount) external returns(bool);
}

contract DSG {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    // 用户质押金额
    mapping (address => uint) public balanceOf;
    // 总供应量
    uint public totalSupply;
    // 乘数
    uint private constant MULTIPIER = 1e18;
    // 奖励指数
    uint private rewardIndex;
    // 账户对应的指数
    mapping (address => uint) private rewardIndexOf;
    // 奖励金额
    mapping (address => uint) private earned;

    constructor(address _stakingToken, address _rewardsToken){
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    // 计算比例和合约转账
    function updateRewardIndex(uint reward) external {
        // 把EOA账户转账到质押合约中
        rewardsToken.transferFrom(msg.sender, address(this), reward);
        // 累加获得的奖励比例
        rewardIndex += (reward * MULTIPIER) / totalSupply;
    }

    // 计算单次奖励
    function _calculateRewards(address account) private view returns(uint){
        // 获取账号余额
        uint shares = balanceOf[account];
        // t1=，t0=0
        return (shares * (rewardIndex - rewardIndexOf[account])) / MULTIPIER;
    }

    // 计算获得奖励
    function calculateRewardEarned(address account) external view returns(uint){
        return earned[account] + _calculateRewards(account);
    }

    // 更新奖励指数
    function _updateRewards(address account) private {
        earned[account] += _calculateRewards(account);
        rewardIndexOf[account] = rewardIndex;
    }

    // 质押
    function stake(uint amount) external {
        _updateRewards(msg.sender);
        balanceOf[msg.sender] += amount;
        totalSupply += amount;

        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint amount) external {
        _updateRewards(msg.sender);
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        stakingToken.transfer(msg.sender, amount);
    }

    // 赎回
    function claim() external returns(uint){
        _updateRewards(msg.sender);

        uint reward = earned[msg.sender];
        if(reward > 0){
            earned[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }

        return reward;
    }
}