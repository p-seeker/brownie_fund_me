from brownie import FundMe, MockV3Aggregator, network, config

# from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.helpful_scripts import get_account
from web3 import Web3

# DECIMALS = 18 @05:43:25: actually this should be 8, bec in getPrice() func of FundMe.sol we multiply it by 10000000000.:).
DECIMALS = 8
STARTING_PRICE = 200000000000


# RY: for deployment to our local-ganache, we define this flag (@ 05:40:10)
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-cli"]


def deploy_fund_me():
    account = get_account()
    # Now we need to pass the price feed address (price_feed_address) to the contructor in our fundme contract (@05:24:30)
    # For passing this 'price_feed_address', if we are on a persistent live NW like rinkeby, use the assoc addr
    # if network.show_active() != "development": # -> @05:40:40: changed it to line below, for deployment to our local ganache
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"  # we're getting this param fr brown-config.yaml; so we easily swtich bw diff active NWs.:).
        ]
    # o.w., i.f, if we are on a development chain, deploy mocks
    else:
        print(f"The active network is {network.show_active()}")
        print(f"Deploying Mocks...")
        # @ 05:34:00 If we've already deployed a mock on the NW we're using, we don't need to deploy it again
        if len(MockV3Aggregator) <= 0:
            MockV3Aggregator.deploy(
                DECIMALS,
                Web3.toWei(STARTING_PRICE, "ether"),
                {"from": get_account()},
            )
        print("Mocks Deployed!")
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        # @05:32:20 pull 'publish_source' fr brownie-config file; sets it to False/True, depending on the NW being a dev NW or not
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")
    # return fund_me


def main():
    deploy_fund_me()
