const { ethers } = require("ethers");

class Web3AuthSystem {
    generateAuthMessage(address, nonce) {
        return `Login to DApp\nAddress: ${address}\nNonce: ${nonce}`;
    }

    verifySignature(address, message, signature) {
        try {
            const signer = ethers.verifyMessage(message, signature);
            return signer.toLowerCase() === address.toLowerCase();
        } catch (e) {
            return false;
        }
    }

    generateNonce() {
        return Math.floor(Math.random() * 1e10).toString();
    }

    validateChainId(chainId, allowedChains) {
        return allowedChains.includes(chainId.toString());
    }
}

module.exports = Web3AuthSystem;
