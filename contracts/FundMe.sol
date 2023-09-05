// SPDX-License-Identifier: MIT

 // Smart contract that lets anyone deposit ETH into the contract
 // Only the owner of the contract can withdraw the ETH
// pragma solidity ^0.6.6 <0.9.0;
pragma solidity ^0.6.6;

 // Get the latest ETH/USD price from chainlink price feed

 // IMPORTANT: This contract has been updated to use the Goerli testnet
 // Please see: https://docs.chain.link/docs/get-the-latest-price/
 // For more information

 import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
 import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
     // safe math library check uint256 for integer overflows
     using SafeMathChainlink for uint256;

     //mapping to store which address depositeded how much ETH
     mapping(address => uint256) public addressToAmountFunded;
     // array of addresses who deposited
     address[] public funders;
     //address of the owner (who deployed the contract)
     address public owner;
     AggregatorV3Interface public priceFeed;

     //RY (@05:23:00): 
        // for deployment on Brownie's local BlCh, we need to 'mock' the price-feed;
        // that's why we're adding this 'address _priceFeed' param to the constructor.
        // so instead of setting the priceFeed in functions like 'getVersion()', we set it here.
     constructor(address _priceFeed) public {
         priceFeed = AggregatorV3Interface(_priceFeed);
         owner = msg.sender;
     }

     function fund() public payable {
         // 18 digit number to be compared with donated amount
         uint256 minimumUSD = 1 * 10**18;
         //is the donated amount less than 1USD [originally it was 50USD!]?
         require(
             getConversionRate(msg.value) >= minimumUSD,
             "You need to spend more ETH!"
         );
         //if not, add to mapping and funders array
         addressToAmountFunded[msg.sender] += msg.value;
         funders.push(msg.sender);
     }

     //function to get the version of the chainlink pricefeed
     function getVersion() public view returns (uint256) {
        // RY: 
            // we set the 'priceFeed' param in the constructor now, so we don't need to set it here anymore (@05:24:00)
            // This change is needed to be able to deploy the contract to our local BlCh.:).
         /* AggregatorV3Interface priceFeed = AggregatorV3Interface(
             // 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e -> this is the addr for Goreli testnet
             0x694AA1769357215DE4FAC081bf1f309aDC325306
         ); */
         return priceFeed.version();
     }

     function getPrice() public view returns (uint256) {
        // RY: 
            // we set the 'priceFeed' param in the constructor now, so we don't need to set it here anymore (@05:24:00)
            // This change is needed to be able to deploy the contract to our local BlCh.:).
         /* AggregatorV3Interface priceFeed = AggregatorV3Interface(
             // 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e -> this is the addr for Goreli testnet
             0x694AA1769357215DE4FAC081bf1f309aDC325306
         ); */
         (, int256 answer, , , ) = priceFeed.latestRoundData();
         // ETH/USD rate in 18 digit
         return uint256(answer * 10000000000);
     }

     // 1000000000
     function getConversionRate(uint256 ethAmount) public view returns (uint256)
     {
         uint256 ethPrice = getPrice();
         uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
         // the actual ETH/USD conversation rate, after adjusting the extra 0s.
         return ethAmountInUsd;
     }

     // @05:44:06 -> this function was added when we were adding the fund_and_withdraw.py script.:).
     function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

     //modifier: https://medium.com/coinmonks/solidity-tutorial-all-about-modifiers-a86cf81c14cb
     modifier onlyOwner() {
         //is the message sender owner of the contract?
         require(msg.sender == owner);
         _;
     }

     // onlyOwner modifer will first check the condition inside it
     // and
     // if true, withdraw function will be executed
     function withdraw() public payable onlyOwner {
         msg.sender.transfer(address(this).balance);

         //iterate through all the mappings and make them 0
         //since all the deposited amount has been withdrawn
         for (
             uint256 funderIndex = 0;
             funderIndex < funders.length;
             funderIndex++
         ) {
             address funder = funders[funderIndex];
             addressToAmountFunded[funder] = 0;
         }
         //funders array will be initialized to 0
         funders = new address[](0);
     }
}
