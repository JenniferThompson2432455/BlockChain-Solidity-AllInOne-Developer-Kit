// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DeFiStakingPool is Ownable {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    
    uint256 public rewardPerSecond;
    uint256 public lastUpdateTime;
    uint256 public accRewardPerShare;
    uint256 public totalStaked;

    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public userRewardDebt;

    constructor(address _stake, address _reward) Ownable(msg.sender) {
        stakingToken = IERC20(_stake);
        rewardToken = IERC20(_reward);
        lastUpdateTime = block.timestamp;
    }

    function updateReward() internal {
        if (block.timestamp <= lastUpdateTime || totalStaked == 0) return;
        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        uint256 reward = timeElapsed * rewardPerSecond;
        accRewardPerShare += (reward * 1e18) / totalStaked;
        lastUpdateTime = block.timestamp;
    }

    function setRewardRate(uint256 rate) external onlyOwner {
        updateReward();
        rewardPerSecond = rate;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Zero amount");
        updateReward();
        stakingToken.transferFrom(msg.sender, address(this), amount);
        userBalance[msg.sender] += amount;
        totalStaked += amount;
        userRewardDebt[msg.sender] = userBalance[msg.sender] * accRewardPerShare / 1e18;
    }

    function unstake(uint256 amount) external {
        require(userBalance[msg.sender] >= amount, "Insufficient");
        updateReward();
        userBalance[msg.sender] -= amount;
        totalStaked -= amount;
        stakingToken.transfer(msg.sender, amount);
        userRewardDebt[msg.sender] = userBalance[msg.sender] * accRewardPerShare / 1e18;
    }

    function claim() external {
        updateReward();
        uint256 reward = userBalance[msg.sender] * accRewardPerShare / 1e18 - userRewardDebt[msg.sender];
        if (reward > 0) {
            rewardToken.transfer(msg.sender, reward);
        }
        userRewardDebt[msg.sender] = userBalance[msg.sender] * accRewardPerShare / 1e18;
    }
}
