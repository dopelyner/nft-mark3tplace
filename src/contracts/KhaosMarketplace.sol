// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./KhaosNFT.sol";
import "./KhaosNFTFactory.sol";

interface IKhaosNFT {
    function getRoyaltyFee() external view returns (uint256);

    function getRoyaltyRecipient() external view returns (address);
}

contract KhaosMarketplace is Ownable, ReentrancyGuard {
    // ========== State Variables ========== //
    uint256 public policyFee;
    address public marketAddress;
    KhaosNFTFactory private immutable khaosNFTFactory;

    // Define a struct based on NFT components
    struct Listing {
        address nft;
        uint256 tokenId;
        address seller;
        address payToken;
        uint256 price;
        bool sold;
    }

    // ========== Events ========== //
    event Listed_NFT(
        address indexed _nft,
        uint256 indexed _tokenId,
        address _payToken,
        uint256 _price,
        address indexed _seller
    );
    event Bought_NFT(
        address indexed _nft,
        uint256 indexed _tokenId,
        address _payToken,
        uint256 _price,
        address indexed _seller
    );

    // Keep track of all NFT listed on the Marketplace [nft => tokenId => Listing struct]
    mapping(address => mapping(uint256 => Listing)) private listOfNFTs;
    // Keep track payable functionality
    mapping(address => bool) private payableToken;
    address[] private tokens;

    constructor(
        uint256 _policyFee,
        address _marketAddress,
        KhaosNFTFactory _khaosNFTFactory
    ) {
        require(policyFee <= 10000, "Can't be more than 10 percent");
        policyFee = _policyFee;
        marketAddress = _marketAddress;
        khaosNFTFactory = _khaosNFTFactory;
    }

    /** 
        @notice List NFT on Marketplace
     */
    function listNFT(
        address _nft,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    ) external isKhaosNFT(_nft) isPayableToken(_payToken) {
        IERC721 nft = IERC721(_nft);
        require(
            nft.ownerOf(_tokenId) == msg.sender,
            "Caller is not the NFT owner"
        );
        nft.transferFrom(msg.sender, address(this), _tokenId);

        listOfNFTs[_nft][_tokenId] = Listing({
            nft: _nft,
            tokenId: _tokenId,
            seller: msg.sender,
            payToken: _payToken,
            price: _price,
            sold: false
        });

        emit Listed_NFT(_nft, _tokenId, _payToken, _price, msg.sender);
    }

    /** 
        @notice Buy a Listed NFT on Marketplace
     */
    function buyNFT(
        address _nft,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    ) external payable isNFTListed(_nft, _tokenId) isPayableToken(_payToken) {
        Listing storage listingNFT = listOfNFTs[_nft][_tokenId];
        require(_payToken != address(0) && _payToken == listingNFT.payToken);
        require(!listingNFT.sold, "NFT was already sold");
        require(_price >= listingNFT.price);

        listingNFT.sold = true;
        uint256 totalPrice = _price;

        // Royalties
        KhaosNFT nft = KhaosNFT(listingNFT.nft);
        address royaltyRecipient = nft.getRoyaltyRecipient();
        uint256 royaltyFee = nft.getRoyaltyFee();

        // Transfer royalty value to owner
        if (royaltyFee > 0) {
            uint256 royaltyAmount = getRoyaltyAmount(royaltyFee, _price);
            IERC20(listingNFT.payToken).transferFrom(
                msg.sender,
                royaltyRecipient,
                royaltyAmount
            );
            totalPrice -= royaltyAmount;
        }
        
        // Policy Fee
        uint256 totalPolicyFee = getPolicyFeeAmount(_price);
        IERC20(listingNFT.payToken).transferFrom(
            msg.sender,
            marketAddress,
            totalPolicyFee
        );

        // Transfer value to nft owner
        IERC20(listingNFT.payToken).transferFrom(
            msg.sender,
            listingNFT.seller,
            totalPrice - totalPolicyFee
        );

        // Transfer NFT to buyer
        IERC721(listingNFT.nft).safeTransferFrom(
            address(this),
            msg.sender,
            listingNFT.tokenId
        );

        emit Bought_NFT(
            listingNFT.nft,
            listingNFT.tokenId,
            listingNFT.payToken,
            _price,
            msg.sender
        );
    }

    // ========== Modifiers ========== //
    modifier isNFTListed(address _nft, uint256 _tokenId) {
        Listing memory listingNFT = listOfNFTs[_nft][_tokenId];
        require(
            listingNFT.seller != address(0) && !listingNFT.sold,
            "Not listed"
        );
        _;
    }
    modifier isKhaosNFT(address _nft) {
        require(khaosNFTFactory.isKhaosNFT(_nft), "Not Khaos NFT");
        _;
    }
    modifier isPayableToken(address _payToken) {
        require(
            _payToken != address(0) && payableToken[_payToken],
            "Invalid pay token"
        );
        _;
    }

    // ========== Aux Functions ========== //
    function updatePolicyFee(uint256 _policyFee) external onlyOwner {
        require(_policyFee <= 10000, "Can't be more than 10 percent");
        policyFee = _policyFee;
    }

    function getRoyaltyAmount(uint256 _royaltyFee, uint256 _price)
        public
        pure
        returns (uint256)
    {
        return (_price * _royaltyFee) / 10000;
    }

    function getPolicyFeeAmount(uint256 _price) public view returns (uint256) {
        return (_price * policyFee) / 10000;
    }

    function getPayableTokens() external view returns (address[] memory) {
        return tokens;
    }

    function checkIsPayableToken(address _payableToken)
        external
        view
        returns (bool)
    {
        return payableToken[_payableToken];
    }

    function addPayableToken(address _token) external onlyOwner {
        require(_token != address(0), "Invalid token");
        require(!payableToken[_token], "Already payable token");
        payableToken[_token] = true;
        tokens.push(_token);
    }
}