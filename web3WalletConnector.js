const { ethers } = require("ethers");

class Web3WalletConnector {
    constructor() {
        this.provider = null;
        this.signer = null;
        this.address = null;
    }

    async connectMetaMask() {
        if (!window.ethereum) throw new Error("MetaMask not installed");
        await window.ethereum.request({ method: "eth_requestAccounts" });
        this.provider = new ethers.BrowserProvider(window.ethereum);
        this.signer = await this.provider.getSigner();
        this.address = await this.signer.getAddress();
        return { address: this.address, chainId: await this.getChainId() };
    }

    async getChainId() {
        const network = await this.provider.getNetwork();
        return network.chainId.toString();
    }

    async switchChain(chainId) {
        try {
            await window.ethereum.request({
                method: "wallet_switchEthereumChain",
                params: [{ chainId: `0x${chainId.toString(16)}` }],
            });
        } catch (e) {
            throw new Error("Chain switch failed");
        }
    }

    async signMessage(message) {
        return await this.signer.signMessage(message);
    }

    disconnect() {
        this.provider = null;
        this.signer = null;
        this.address = null;
    }
}

module.exports = Web3WalletConnector;
