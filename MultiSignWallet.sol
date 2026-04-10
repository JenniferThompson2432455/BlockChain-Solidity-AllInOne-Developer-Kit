// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSignWallet {
    address[] public owners;
    uint256 public required;
    mapping(address => bool) public isOwner;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    uint256 public txCount;

    event TxSubmitted(uint256 indexed id, address to, uint256 value);
    event TxConfirmed(uint256 indexed id, address owner);
    event TxExecuted(uint256 indexed id);

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0 && _required <= _owners.length, "Invalid");
        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Zero address");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        required = _required;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    function submitTransaction(address to, uint256 value, bytes calldata data) external onlyOwner {
        uint256 id = txCount;
        transactions[id] = Transaction(to, value, data, false, 0);
        txCount++;
        emit TxSubmitted(id, to, value);
    }

    function confirmTransaction(uint256 id) external onlyOwner {
        require(!confirmations[id][msg.sender], "Confirmed");
        Transaction storage txn = transactions[id];
        confirmations[id][msg.sender] = true;
        txn.confirmations++;
        emit TxConfirmed(id, msg.sender);
        if (txn.confirmations >= required) executeTransaction(id);
    }

    function executeTransaction(uint256 id) internal {
        Transaction storage txn = transactions[id];
        require(!txn.executed && txn.confirmations >= required, "Cannot exec");
        txn.executed = true;
        (bool success,) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Tx failed");
        emit TxExecuted(id);
    }
}
