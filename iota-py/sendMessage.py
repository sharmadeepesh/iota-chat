import os
from iota_sdk import SendParams, Wallet, Payload, Transaction
from dotenv import load_dotenv
import json

load_dotenv()

STRONGHOLD_PASSWORD = os.getenv('STRONGHOLD_PASSWORD')

wallet = Wallet(os.environ['WALLET_DB_PATH'])

def get_account_wallet_address(username):
    with open("wallet_addresses.json","r") as file:
        wallet_add_dict = json.load(file)
    return wallet_add_dict[username]

def sync_account_and_send(username, receiver_username):
    account = wallet.get_account(username)
    response = account.sync()

    message_trytes = "Test message".encode('utf-8').hex()

    transaction = Transaction(
        address = get_account_wallet_address(receiver_username),
        value = 0,
        message = message_trytes,
        tag = "Nothing"
    )

    params = SendParams(transaction = transaction)

    transaction_result = account.send_with_params(params)
    print(f'Block sent: {os.environ["EXPLORER_URL"]}/block/{transaction_result.block_id}')

sync_account_and_send("Alice1", "Alice2")
