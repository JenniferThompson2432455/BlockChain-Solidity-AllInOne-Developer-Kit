const { ethers } = require("ethers");

class Web3BatchTransfer {
    constructor(provider, privateKey) {
        this.wallet = new ethers.Wallet(privateKey, provider);
    }

    async batchTransferNative(recipients, amounts, gasPrice, gasLimit = 21000) {
        const txs = [];
        for (let i = 0; i < recipients.length; i++) {
            txs.push({
                to: recipients[i],
                value: ethers.parseEther(amounts[i].toString()),
                gasPrice: ethers.parseUnits(gasPrice.toString(), "gwei"),
                gasLimit,
            });
        }
        const results = [];
        for (const tx of txs) {
            const sent = await this.wallet.sendTransaction(tx);
            await sent.wait();
            results.push(sent.hash);
        }
        return results;
    }

    async batchTransferERC20(contract, recipients, amounts) {
        const results = [];
        for (let i = 0; i < recipients.length; i++) {
            const tx = await contract.transfer(recipients[i], ethers.parseUnits(amounts[i].toString(), 18));
            await tx.wait();
            results.push(tx.hash);
        }
        return results;
    }
}

module.exports = Web3BatchTransfer;
