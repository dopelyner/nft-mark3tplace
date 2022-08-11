// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./KhaosNFT.sol";

contract KhaosMarketplace is Ownable, ReentrancyGuard {

    uint256 public policyFee;
    address public marketAddress;

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
    event Listed_NFT (address indexed _nft, uint256 indexed _tokenId, address _buyer, uint256 _price, address indexed _seller);
    event Bought_NFT (address indexed _nft, uint indexed _tokenId, address _buyer, uint _price, address indexed _seller);

    // Keep track of all NFT listed on the Marketplace
    mapping(address => mapping(uint256 => NFTstruct)) private listOfNFTs;

    constructor(uint256 _policyFee, address _marketAddress) {
        require(policyFee <= 10000, "Can't be more than 10 percent");
        policyFee = _policyFee;
        marketAddress = _marketAddress;
    }

     // Modifiers
    modifier isNFTListed(address _nft, uint256 _tokenId) {
        NFTstruct memory listedNFT = listOfNFTs[_nft][_tokenId];
        require(listedNFT.seller != address(0) && !listedNFT.sold, "Not listed");
        _;
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
    
    function buyNFT(address _nft, uint _tokenId, address _buyer, uint _price) external isNFTListed(_nft, _tokenId) {
        NFTstruct storage listedNFT = listOfNFTs[_nft][_tokenId];
        require(_buyer != address(0) && _buyer == listedNFT.buyer);
        require(!listedNFT.sold, "NFT was already sold");
        require(_price >= listedNFT.price);

        listedNFT.sold = true;
        uint256 totalPrice = _price;

        // Royalties
        KhaosNFT nft = KhaosNFT(listedNFT.nft);
        address royaltyRecipient = nft.getRoyaltyRecipient();
        uint256 royaltyFee = nft.getRoyaltyFee();

        if (royaltyFee > 0) {
            uint256 royaltyAmount = getRoyaltyAmount(royaltyFee, _price);
            
            IERC20(listedNFT.buyer).transferFrom(msg.sender, royaltyRecipient, royaltyAmount);
            
            totalPrice -= royaltyAmount;
        }
    

    }

    function updateMarketFee(uint256 _marketFee) external onlyOwner {
        require(_marketFee <= 10000, "Can't be more than 10 percent");
        policyFee = _marketFee;
    }

    function getRoyaltyAmount(uint256 _royaltyFee, uint256 _price) public view returns (uint256) {
        return (_price * _royaltyFee) / 10000;
    }

    function getPolicyFeeAmount(uint256 _price) public view returns (uint256) {
        return (_price * policyFee) / 10000;
    }




}