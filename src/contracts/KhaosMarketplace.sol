// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./KhaosNFT.sol";
interface IKhaosNFTFactory {
    function createNFTCollection(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyFee
    ) external;

    function isKhaosNFT(address _nft) external view returns (bool);
}
interface IKhaosNFT {
    function getRoyaltyFee() external view returns (uint256);

    function getRoyaltyRecipient() external view returns (address);
}


contract KhaosMarketplace is Ownable, ReentrancyGuard {
    
    // ========== State Variables ========== //
    uint256 public policyFee;
    address public marketAddress;
    IKhaosNFTFactory private immutable khaosNFTFactory;


    // Define a struct based on NFT components
    struct NFTstruct {
        address nft;
        uint256 tokenId;
        address seller;
        address payToken;
        uint256 price;
        bool sold;
    }

    // ========== Events ========== //
    event Listed_NFT (address indexed _nft, uint256 indexed _tokenId, address _payToken, uint256 _price, address indexed _seller);
    event Bought_NFT (address indexed _nft, uint indexed _tokenId, address _payToken, uint _price, address indexed _seller);

    // Keep track of all NFT listed on the Marketplace
    mapping(address => mapping(uint256 => NFTstruct)) private listOfNFTs;
    // Keep track payable functionality
    mapping(address => bool) private payableToken;
    address[] private tokens;

    constructor(uint256 _policyFee, address _marketAddress, IKhaosNFTFactory _khaosNFTFactory) {
        require(policyFee <= 10000, "Can't be more than 10 percent");
        policyFee = _policyFee;
        marketAddress = _marketAddress;
        khaosNFTFactory = _khaosNFTFactory;
    }

    /** 
        @notice List NFT on Marketplace
        @dev  ===> Add modifier to restrict if is payable
     */
    function listNFT(address _nft, uint256 _tokenId, address _payToken, uint256 _price) external {
        IERC721 nft = IERC721(_nft);
        require(nft.ownerOf(_tokenId) == msg.sender, "Caller is not the NFT owner");
        nft.transferFrom(msg.sender, address(this), _tokenId);

        listOfNFTs[_nft][_tokenId] = NFTstruct({
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
        @notice Buy a Listed NFT
     */
    function buyNFT(address _nft, uint _tokenId, address _payToken, uint _price) external isNFTListed(_nft, _tokenId) isPayableToken(_payToken) {
        NFTstruct storage listedNFT = listOfNFTs[_nft][_tokenId];
        require(_payToken != address(0) && _payToken == listedNFT.payToken);
        require(!listedNFT.sold, "NFT was already sold");
        require(_price >= listedNFT.price);

        listedNFT.sold = true;
        uint256 totalPrice = _price;

        // Royalties
        KhaosNFT nft = KhaosNFT(listedNFT.nft);
        address royaltyRecipient = nft.getRoyaltyRecipient();
        uint256 royaltyFee = nft.getRoyaltyFee();

        // Transfer royalty value to owner
        if (royaltyFee > 0) {
            uint256 royaltyAmount = getRoyaltyAmount(royaltyFee, _price);
            IERC20(listedNFT.payToken).transferFrom(msg.sender, royaltyRecipient, royaltyAmount);
            totalPrice -= royaltyAmount;
        }
        
        // Policy Fee
        uint256 totalPolicyFee = getPolicyFeeAmount(_price);
        IERC20(listedNFT.payToken).transferFrom(msg.sender, marketAddress, totalPolicyFee);

        // Transfer value to nft owner
        IERC20(listedNFT.payToken).transferFrom(msg.sender, listedNFT.seller, totalPrice - totalPolicyFee);

        // Transfer NFT to buyer
        IERC721(listedNFT.nft).safeTransferFrom(address(this), msg.sender, listedNFT.tokenId);

        emit Bought_NFT(listedNFT.nft, listedNFT.tokenId, listedNFT.payToken, _price, msg.sender);
    }
    
    // ========== Modifiers ========== //
    modifier isNFTListed(address _nft, uint256 _tokenId) {
        NFTstruct memory listedNFT = listOfNFTs[_nft][_tokenId];
        require(listedNFT.seller != address(0) && !listedNFT.sold, "Not listed");
        _;
    }
    modifier isKhaosNFT(address _nft) {
        require(khaosNFTFactory.isKhaosNFT(_nft), "Not Khaos NFT");
        _;
    }
    modifier isPayableToken(address _payToken) {
        require(_payToken != address(0) && payableToken[_payToken],"Invalid pay token");
        _;
    }

    // ========== Aux Functions ========== //
    function updatePolicyFee(uint256 _policyFee) external onlyOwner {
        require(_policyFee <= 10000, "Can't be more than 10 percent");
        policyFee = _policyFee;
    }

    function getRoyaltyAmount(uint256 _royaltyFee, uint256 _price) public pure returns (uint256) {
        return (_price * _royaltyFee) / 10000;
    }

    function getPolicyFeeAmount(uint256 _price) public view returns (uint256) {
        return (_price * policyFee) / 10000;
    }

    function getPayableTokens() external view returns (address[] memory) {
        return tokens;
    }

    function checkIsPayableToken(address _payableToken) external view returns (bool) {
        return payableToken[_payableToken];
    }

    function addPayableToken(address _token) external onlyOwner {
        require(_token != address(0), "Invalid token");
        require(!payableToken[_token], "Already payable token");
        payableToken[_token] = true;
        tokens.push(_token);
    }
}