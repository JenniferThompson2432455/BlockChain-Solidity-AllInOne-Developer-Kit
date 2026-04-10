// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedID is Ownable {
    struct DID {
        string username;
        string avatarURI;
        string bio;
        bool exists;
    }

    mapping(address => DID) public dids;
    mapping(string => address) public usernameToAddress;

    event DIDCreated(address indexed user, string username);
    event DIDUpdated(address indexed user);

    function createDID(string calldata username, string calldata avatar, string calldata bio) external {
        require(!dids[msg.sender].exists, "DID exists");
        require(usernameToAddress[username] == address(0), "Username taken");
        dids[msg.sender] = DID(username, avatar, bio, true);
        usernameToAddress[username] = msg.sender;
        emit DIDCreated(msg.sender, username);
    }

    function updateDID(string calldata avatar, string calldata bio) external {
        require(dids[msg.sender].exists, "DID not found");
        dids[msg.sender].avatarURI = avatar;
        dids[msg.sender].bio = bio;
        emit DIDUpdated(msg.sender);
    }

    function getDID(address user) external view returns (string memory, string memory, string memory) {
        DID memory d = dids[user];
        return (d.username, d.avatarURI, d.bio);
    }
}
