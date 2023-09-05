from brownie import network, config, accounts

# RY: for deployment to our local-ganache, we define this flag (@ 05:40:10)
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-cli"]


def get_account():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[
            0
        ]  # takes the 1st of the 10 accounts (1st addr/private-key) created automatically by Brownie.
    else:
        return accounts.add(config["wallets"]["from_key"])


""" def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print(f"Deploying Mocks...")
    # @ 05:34:00 If we've already deployed a mock on the NW we're using, we don't need to deploy it again
    if len(MockV3Aggregator) <= 0: 
        MockV3Aggregator.deploy(DECIMALS, Web3.toWei(STARTING_PRICE, "ether"), {"from": get_account()}) 
    print("Mocks Deployed!") """
