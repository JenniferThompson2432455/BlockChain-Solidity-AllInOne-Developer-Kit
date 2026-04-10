// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStakingReward is Ownable {
    IERC721 public immutable nft;
    IERC20 public immutable reward;

    uint256 public rewardPerDay = 10 * 10**18;
    mapping(address => uint256[]) public stakedTokens;
    mapping(address => uint256) public stakeTime;
    mapping(address => uint256) public pendingRewards;

    constructor(address _nft, address _reward) Ownable(msg.sender) {
        nft = IERC721(_nft);
        reward = IERC20(_reward);
    }

    function stake(uint256[] calldata ids) external {
        require(ids.length > 0, "Empty list");
        _updateReward(msg.sender);
        for (uint256 i = 0; i < ids.length; i++) {
            nft.transferFrom(msg.sender, address(this), ids[i]);
            stakedTokens[msg.sender].push(ids[i]);
        }
    }

    function _updateReward(address user) internal {
        if (stakedTokens[user].length == 0) return;
        uint256 timeDiff = block.timestamp - stakeTime[user];
        uint256 calc = (timeDiff * rewardPerDay * stakedTokens[user].length) / 1 days;
        pendingRewards[user] += calc;
        stakeTime[user] = block.timestamp;
    }

    function claim() external {
        _updateReward(msg.sender);
        uint256 amt = pendingRewards[msg.sender];
        pendingRewards[msg.sender] = 0;
        reward.transfer(msg.sender, amt);
    }

    function unstake(uint256[] calldata ids) external {
        _updateReward(msg.sender);
        uint256[] storage userStaked = stakedTokens[msg.sender];
        for (uint256 i = 0; i < ids.length; i++) {
            for (uint256 j; j < userStaked.length; j++) {
                if (userStaked[j] == ids[i]) {
                    userStaked[j] = userStaked[userStaked.length - 1];
                    userStaked.pop();
                    nft.transferFrom(address(this), msg.sender, ids[i]);
                    break;
                }
            }
        }
    }
}
