from web3 import Web3

class BlockParserTool:
    def __init__(self, rpc_url):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))

    def parse_full_block(self, block_number):
        block = self.w3.eth.get_block(block_number, full_transactions=True)
        tx_list = []
        for tx in block.transactions:
            tx_list.append({
                "hash": tx.hash.hex(),
                "from": tx["from"],
                "to": tx.get("to"),
                "value": self.w3.from_wei(tx.value, "ether"),
                "gas": tx.gas,
                "gasPrice": self.w3.from_wei(tx.gasPrice, "gwei")
            })
        return {
            "number": block.number,
            "timestamp": block.timestamp,
            "hash": block.hash.hex(),
            "transactions": tx_list,
            "tx_count": len(tx_list)
        }

    def get_block_txs(self, block_number):
        block = self.w3.eth.get_block(block_number)
        return [h.hex() for h in block.transactions]
