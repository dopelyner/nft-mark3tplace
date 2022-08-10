// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./KhaosNFT.sol";

contract KhaosMarketplace is Ownable, ReentrancyGuard {

    uint256 private marketFee;
    address private marketAddress;

    // Define a struct based on NFT components
    struct NFTstruct {
        address nft;
        uint256 tokenId;
        address seller;
        address buyer;
        uint256 price;
        bool sold;
    }

    // Events
    event Listed_NFT ( address indexed _nft, uint256 indexed _tokenId, address _buyer, uint256 _price, address indexed _seller);

    // Keep track of all NFT listed on the Marketplace
    mapping(address => mapping(uint256 => NFTstruct)) private listOfNFTs;

    constructor(uint256 _marketFee, address _marketAddress) {
        require(_marketFee <= 10000, "can't be more than 10 percent");
        marketFee = _marketFee;
        marketAddress = _marketAddress;
    }

    /** 
        @notice List NFT on Marketplace
        @dev  ===> Add modifier to restrict if is payable
     */
    function listNFT(address _nft, uint256 _tokenId, address _buyer, uint256 _price) external {
        KhaosNFT nft = KhaosNFT(_nft);
        require(nft.ownerOf(_tokenId) == msg.sender, "Caller is not the NFT owner");
        nft.transferFrom(msg.sender, address(this), _tokenId);

        listOfNFTs[_nft][_tokenId] = NFTstruct({
            nft: _nft,
            tokenId: _tokenId,
            seller: msg.sender,
            buyer: _buyer,
            price: _price,
            sold: false
        });

        emit Listed_NFT(_nft, _tokenId, _buyer, _price, msg.sender);
    }

    


}