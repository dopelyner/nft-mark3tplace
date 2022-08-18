// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/contracts/KhaosNFT.sol";
import "../src/contracts/KhaosMarketplace.sol";
import "../src/contracts/KhaosNFTFactory.sol";

contract KhaosMarketplaceTest is Test {
    using stdStorage for StdStorage;

    KhaosNFT nft;
    KhaosMarketplace marketplace;
    IKhaosNFTFactory factory;
    KhaosNFTFactory khaosFactory;
    uint256 private constant policyFee = 250;
    uint256 private constant royalty = 5000;
    uint256 private constant price = 1 ether;
    address private marketAddr = address(0x11345);
    address private artist = address(0x1111);
    address private bob = address(0x1222);

    function setUp() public {
        vm.deal(artist, 5 ether);
        vm.deal(bob, 5 ether);

        vm.startPrank(artist);
        marketplace = new KhaosMarketplace(policyFee, marketAddr, factory);
        khaosFactory = new KhaosNFTFactory();
        factory = IKhaosNFTFactory(artist);

        emit log_named_address("Market", marketplace.marketAddress());
        emit log_named_address("Artist", artist);
        emit log_named_address("Sender setup", msg.sender);
        vm.stopPrank();
    }
    function testArtistDeployNFT() public {
        vm.startPrank(artist);
        nft = new KhaosNFT("Khaos NFT", "KHS", artist, royalty, artist);
        emit log_named_address("NFT Owner ", address(nft.owner()));
        vm.stopPrank();
    }
    
    function testMarketplaceAddress() public {
        assertEq(marketAddr, marketplace.marketAddress());
    }

    function testArtistUpdatePolicyFee() public {
        vm.startPrank(artist);
        emit log_named_uint("Policy Fee", marketplace.policyFee());
        marketplace.updatePolicyFee(5000);
        assertEq(marketplace.policyFee(), 5000);
        emit log_named_uint("Updated Policy Fee", marketplace.policyFee());
        vm.stopPrank();
    }

    function testFailMintToZeroAddress() public {
        nft.safeMint(address(0), "uri");
    }
    
    function testCreateNFTColletion() public { 
        vm.startPrank(artist);
        khaosFactory.createNFTCollection("Silly NFT","SLY", royalty, artist);
        vm.stopPrank();
    }

}
