// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/backend/contracts/KhaosNFT.sol";
import "../src/backend/contracts/KhaosMarketplace.sol";

contract KhaosMarketplaceTest is Test {

    KhaosNFT nft;
    KhaosMarketplace marketplace;
    uint256 constant private policyFee = 250;
    address private artist = address(2);

    function setUp() public {
        emit log_named_address("Deployer Address", msg.sender);

        marketplace = new KhaosMarketplace(policyFee, address(1));
        
        vm.deal(artist, 2 ether);
        vm.deal(marketplace.marketAddress(), 2 ether);

        emit log_named_address("Marketplace Address", marketplace.marketAddress());
        emit log_named_uint("Policy Fee", marketplace.policyFee());

        emit log_named_address("Artist Address", address(artist));
    }

    function test_artistDeployNFT() public {
        emit log_named_address("Sender", address(msg.sender));

        nft = new KhaosNFT("Khaos NFT", "KHS", msg.sender, policyFee, artist);
        emit log_named_address("NFT Owner ", address(nft.owner()));
    }

    function test_updatePolicyFee() public {
        marketplace.updatePolicyFee(5000);
        assertEq(marketplace.policyFee(), 5000);
        emit log_named_uint("Updated Policy Fee", marketplace.policyFee());
    }

   
}
