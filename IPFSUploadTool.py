import requests
import json

class IPFSUploadTool:
    def __init__(self, gateway="https://api.ipfs.io"):
        self.gateway = gateway

    def upload_file(self, file_path):
        url = f"{self.gateway}/api/v0/add"
        with open(file_path, "rb") as f:
            files = {"file": f}
            res = requests.post(url, files=files)
        return res.json()

    def upload_text(self, text):
        url = f"{self.gateway}/api/v0/add"
        data = text.encode("utf-8")
        res = requests.post(url, files={"file": ("text.txt", data)})
        return res.json()

    def get_file(self, cid):
        url = f"https://ipfs.io/ipfs/{cid}"
        return requests.get(url).text
