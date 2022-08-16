// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/contracts/KhaosNFT.sol";
import "../src/contracts/KhaosMarketplace.sol";

contract KhaosMarketplaceTest is Test {
    using stdStorage for StdStorage;

    KhaosNFT nft;
    KhaosMarketplace marketplace;
    IKhaosNFTFactory factory;
    uint256 private constant policyFee = 250;
    address private artist = address(2);
    address private bob = address(3);
    address private alice = address(4);

    function setUp() public {
        marketplace = new KhaosMarketplace(policyFee, address(1), factory);
        factory = IKhaosNFTFactory(msg.sender);

        vm.deal(artist, 2 ether);
        vm.deal(marketplace.marketAddress(), 2 ether);
    }

    // function testCreateNFTColletion() public {
    //     factory.createNFTCollection("Khaos NFTs", "KHS", 250);
    //     emit log_named_address("factory: ", address(factory));
    // }

    function testGetDeployerAddress() public {
        emit log_named_address("Deployer Address", msg.sender);
    }

    function testMarketplaceAddress() public {
        emit log_named_address("Marketplace Address", marketplace.marketAddress());
        assertEq(address(1), marketplace.marketAddress());
    }
    
    function testArtistAddress() public {
        assertEq(address(2), artist);
        emit log_named_address("Artist Address", address(artist));
    }

    function testDeployNFT() public {
        emit log_named_address("Sender", address(msg.sender));
        nft = new KhaosNFT("Khaos NFT", "KHS", msg.sender, policyFee, artist);
        emit log_named_address("NFT Owner ", address(nft.owner()));
    }

    function testUpdatePolicyFee() public {
        emit log_named_uint("Policy Fee", marketplace.policyFee());
        marketplace.updatePolicyFee(5000);
        assertEq(marketplace.policyFee(), 5000);
        emit log_named_uint("Updated Policy Fee", marketplace.policyFee());
    }

    function testFailSafeMintToZeroAddress() public {
        nft.safeMint(address(0), "uri");
        emit log_named_address("NFT address", address(nft));
    }

    function testMintNFT() public {
        marketplace.addPayableToken(address(nft));
        nft.safeMint(address(this), "artemis.education");
        emit log_named_address("NFT address", address(nft));
    }

}
