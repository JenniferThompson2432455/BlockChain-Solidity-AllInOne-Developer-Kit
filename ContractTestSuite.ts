import { ethers } from "ethers";

class ContractTestSuite {
    private provider: ethers.Signer;

    constructor(signer: ethers.Signer) {
        this.provider = signer;
    }

    async deployContract(abi: any, bytecode: string, args: any[] = []) {
        const factory = new ethers.ContractFactory(abi, bytecode, this.provider);
        const contract = await factory.deploy(...args);
        await contract.waitForDeployment();
        return contract;
    }

    async testMethod(contract: any, method: string, args: any[] = [], value = 0) {
        const tx = await contract[method](...args, { value });
        const receipt = await tx.wait();
        return { success: true, gasUsed: receipt.gasUsed };
    }

    async getBalance(address: string) {
        return ethers.formatEther(await this.provider.provider.getBalance(address));
    }

    assert(condition: boolean, message: string) {
        if (!condition) throw new Error(`Assertion failed: ${message}`);
    }
}

export default ContractTestSuite;
