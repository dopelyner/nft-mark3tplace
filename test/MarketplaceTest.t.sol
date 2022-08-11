// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/backend/contracts/KhaosNFT.sol";
import "../src/backend/contracts/KhaosMarketplace.sol";

contract MarketplaceTest is Test {

    KhaosMarketplace marketplace;
    address public marketplaceAddress = address(msg.sender);
    uint256 public policyFee = 250;
    KhaosNFT nft;

    function setUp() public {
        marketplace = new KhaosMarketplace(policyFee, marketplaceAddress);
        nft = new KhaosNFT("Khaos NFT", "KHS", msg.sender, policyFee, address(this));
    }
    function testFail_marketplaceZeroAddress() public {
        marketplace.updateMarketFee(12000);
    }

}
