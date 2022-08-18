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
    uint256 private constant royalty = 3000;
    uint256 private constant price = 1 ether;

    address private marketAddr = address(0x11345);
    address private artist = address(0x1111);
    address private bob = address(0x1222);
    address private alice = address(0x1333);

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

    function testMarketplaceAddress() public {
        assertEq(marketAddr, marketplace.marketAddress());
    }

    function testArtistDeployNFT() public {
        vm.startPrank(artist);
        nft = new KhaosNFT("Khaos NFT", "KHS", artist, royalty, artist);
        vm.stopPrank();
    }
    
    function testArtistUpdatePolicyFee() public {
        vm.startPrank(artist);
        emit log_named_uint("Policy Fee", marketplace.policyFee());

        marketplace.updatePolicyFee(5000);
        assertEq(marketplace.policyFee(), 5000);

        vm.stopPrank();
        emit log_named_uint("Updated Policy Fee", marketplace.policyFee());
    }

    function testFailMintToZeroAddress() public {
        nft.safeMint(address(0), "uri");
    }
    
    function testArtistCreateNFTColletionAndListNFT() public { 
        vm.startPrank(artist);

        khaosFactory.createNFTCollection("Silly NFT", "SLY", 3000, artist);
        khaosFactory.createNFTCollection("Dope NFT", "DPE", 4000, artist);
        khaosFactory.createNFTCollection("APE NFT", "APE", 2000, artist);
        
        address[] memory artistCollections = khaosFactory.getOwnCollections();
        
        for (uint256 i = 0; i < artistCollections.length; i++) {
            emit log_named_address("Artist's Collection", artistCollections[i]);
            //
        }
        
        vm.stopPrank();
        emit log_named_uint("Artist's balance", address(artist).balance);
    }

    function testBobCreateNFTColletion() public {
        vm.startPrank(bob);

        khaosFactory.createNFTCollection("Bob NFT","BOB", royalty, bob);
        
        address[] memory bobCollection = khaosFactory.getOwnCollections();
        // address nftId = bobCollection[0];
    
        vm.stopPrank();
        emit log_named_uint("Bob's balance", address(bob).balance);
        emit log_named_address("Bob's Collection 0", bobCollection[0]);
    }

}
