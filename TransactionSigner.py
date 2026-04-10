from web3 import Web3

class TransactionSigner:
    def __init__(self, rpc_url):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))

    def create_transaction(self, from_addr, to_addr, value, gas_price, gas_limit=21000, nonce=None):
        if nonce is None:
            nonce = self.w3.eth.get_transaction_count(from_addr)
        return {
            'from': from_addr,
            'to': to_addr,
            'value': self.w3.to_wei(value, 'ether'),
            'gas': gas_limit,
            'gasPrice': self.w3.to_wei(gas_price, 'gwei'),
            'nonce': nonce,
            'chainId': self.w3.eth.chain_id
        }

    def sign_transaction(self, tx, private_key):
        signed = self.w3.eth.account.sign_transaction(tx, private_key)
        return signed

    def send_signed_tx(self, signed_tx):
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        return tx_hash.hex()
