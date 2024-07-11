import os
from dotenv import load_dotenv
import json
from iota_sdk import (ClientOptions, CoinType, StrongholdSecretManager, Utils, Wallet)

load_dotenv()

node_url = os.environ.get('NODE_URL')

STRONGHOLD_PASSWORD = os.environ.get('STRONGHOLD_PASSWORD')

STRONGHOLD_SNAPSHOT_PATH = os.environ.get('STRONGHOLD_SNAPSHOT_PATH')

secret_manager = StrongholdSecretManager(
    STRONGHOLD_SNAPSHOT_PATH, STRONGHOLD_PASSWORD
)

client_options = ClientOptions(nodes=[node_url])

wallet = Wallet(
    client_options=client_options,
    coin_type = CoinType.SHIMMER,
    secret_manager = secret_manager
)

for env_var in ['MNEMONIC']:
    if env_var not in os.environ:
        mnemonic = Utils.generate_mnemonic()
        print(mnemonic)
        wallet.store_mnemonic(mnemonic)

username = "Alice3"
account = wallet.create_account(username)
address = account.addresses()[0].address

with open("wallet_addresses.json","r") as file:
    wallet_add_dict = json.load(file)

wallet_add_dict[username] = address
json_object = json.dumps(wallet_add_dict, indent=4)
with open("wallet_addresses.json", "w") as outfile:
    outfile.write(json_object)

account = wallet.get_accounts()
for accounts in account:
    print(accounts.get_metadata())