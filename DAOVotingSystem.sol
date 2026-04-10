// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAOVotingSystem is Ownable {
    IERC20 public immutable governanceToken;
    uint256 public proposalCount;
    
    struct Proposal {
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    constructor(address token) Ownable(msg.sender) {
        governanceToken = IERC20(token);
    }

    function createProposal(string calldata desc, uint256 duration) external onlyOwner {
        require(duration >= 1 days && duration <= 14 days, "Invalid duration");
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: desc,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            forVotes: 0,
            againstVotes: 0,
            executed: false
        });
    }

    function vote(uint256 id, bool support) external {
        Proposal storage prop = proposals[id];
        require(block.timestamp >= prop.startTime && block.timestamp < prop.endTime, "Voting closed");
        require(!hasVoted[id][msg.sender], "Voted already");
        uint256 balance = governanceToken.balanceOf(msg.sender);
        require(balance > 0, "No voting power");

        hasVoted[id][msg.sender] = true;
        if (support) prop.forVotes += balance;
        else prop.againstVotes += balance;
    }

    function executeProposal(uint256 id) external onlyOwner {
        Proposal storage prop = proposals[id];
        require(block.timestamp >= prop.endTime && !prop.executed, "Cannot execute");
        require(prop.forVotes > prop.againstVotes, "Rejected");
        prop.executed = true;
    }
}
