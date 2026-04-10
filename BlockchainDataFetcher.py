from web3 import Web3

class BlockchainDataFetcher:
    def __init__(self, rpc_url):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        if not self.w3.is_connected():
            raise Exception("RPC connection failed")

    def get_latest_block(self):
        block = self.w3.eth.get_block('latest')
        return {
            "number": block.number,
            "hash": block.hash.hex(),
            "timestamp": block.timestamp,
            "tx_count": len(block.transactions)
        }

    def get_balance(self, address):
        bal = self.w3.eth.get_balance(address)
        return self.w3.from_wei(bal, 'ether')

    def get_transaction(self, tx_hash):
        try:
            return self.w3.eth.get_transaction(tx_hash)
        except:
            return None

    def get_contract_code(self, address):
        return self.w3.eth.get_code(address).hex()
