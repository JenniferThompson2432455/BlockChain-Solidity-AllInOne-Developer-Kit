// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ContractUpgradeable {
    address public implementation;
    address public admin;

    event Upgraded(address indexed newImpl);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function upgradeTo(address newImpl) external onlyAdmin {
        require(newImpl != address(0), "Invalid impl");
        implementation = newImpl;
        emit Upgraded(newImpl);
    }

    fallback() external payable {
        address impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
