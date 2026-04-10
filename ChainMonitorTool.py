import time
from web3 import Web3

class ChainMonitorTool:
    def __init__(self, rpc_url, check_interval=10):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        self.interval = check_interval
        self.last_block = None

    def is_node_healthy(self):
        try:
            return self.w3.is_connected()
        except:
            return False

    def get_sync_status(self):
        try:
            return self.w3.eth.syncing
        except:
            return True

    def monitor_blocks(self, callback):
        while True:
            if not self.is_node_healthy():
                time.sleep(self.interval)
                continue
            latest = self.w3.eth.block_number
            if self.last_block is None or latest > self.last_block:
                self.last_block = latest
                callback(latest)
            time.sleep(self.interval)

    def get_peer_count(self):
        return self.w3.net.peer_count
