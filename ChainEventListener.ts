import { ethers } from "ethers";

class ChainEventListener {
    private provider: ethers.Provider;
    private listeners: Map<string, () => void>;

    constructor(rpcUrl: string) {
        this.provider = new ethers.JsonRpcProvider(rpcUrl);
        this.listeners = new Map();
    }

    async listenToEvent(
        contractAddress: string,
        abi: any[],
        eventName: string,
        callback: (...args: any[]) => void
    ) {
        const contract = new ethers.Contract(contractAddress, abi, this.provider);
        const listener = ( ...args: any[]) => callback(...args);
        contract.on(eventName, listener);
        const key = `${contractAddress}-${eventName}`;
        this.listeners.set(key, listener);
    }

    removeListener(contractAddress: string, eventName: string) {
        const key = `${contractAddress}-${eventName}`;
        const listener = this.listeners.get(key);
        if (listener) {
            this.listeners.delete(key);
        }
    }

    removeAllListeners() {
        this.listeners.clear();
    }
}

export default ChainEventListener;
