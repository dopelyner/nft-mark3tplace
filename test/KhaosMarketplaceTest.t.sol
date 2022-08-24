// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/contracts/KhaosNFT.sol";
import "../src/contracts/KhaosMarketplace.sol";
import "../src/contracts/KhaosNFTFactory.sol";

contract KhaosMarketplaceTest is Test {
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
        marketplace = new KhaosMarketplace(policyFee, marketAddr, factory);

        khaosFactory = new KhaosNFTFactory();
        factory = IKhaosNFTFactory(artist);
    }

    function testMarketplaceAddress() public {
        assertEq(marketAddr, marketplace.marketAddress());
    }

    function testDeployNFT() public {
        nft = new KhaosNFT("Khaos NFT", "KHS", artist, royalty, artist);
        marketplace.addPayableToken(address(nft));
    }

    function testArtistUpdatePolicyFee() public {
        emit log_named_uint("Policy Fee", marketplace.policyFee());

        marketplace.updatePolicyFee(5000);
        assertEq(marketplace.policyFee(), 5000);

        emit log_named_uint("Updated Policy Fee", marketplace.policyFee());
    }

    function testFailMintToZeroAddress() public {
        nft.safeMint(address(0), "uri");
    }

    function testAddPayableToken() public {
        khaosFactory.createNFTCollection("Silly NFT", "SLY", 3000, artist);
        khaosFactory.createNFTCollection("Dope NFT", "DPE", 4000, artist);
        khaosFactory.createNFTCollection("APE NFT", "APE", 2000, artist);

        address[] memory artistCollections = khaosFactory.getOwnCollections();

        for (uint256 i = 0; i < artistCollections.length; i++) {
            emit log_named_address("Artist's Collection", artistCollections[i]);
            marketplace.addPayableToken(artistCollections[i]);
        }
    }

    function testExample() public {
        khaosFactory.createNFTCollection("Silly NFT", "SLY", 3000, artist);

        address aCollection = khaosFactory.getOwnCollections()[0];
        marketplace.addPayableToken(aCollection);

    }
}
