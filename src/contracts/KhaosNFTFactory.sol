// SPDX-License-Identifier: MIT
// Author: kofkuiper
pragma solidity ^0.8.13;

import "./KhaosNFT.sol";

/* 
    Create new KhaosNFT collection
*/
contract KhaosNFTFactory {

    mapping(address => address[]) private nfts;
    mapping(address => bool) private khaosNFT;

    event CreatedNFTCollection(address creator, address nft, string name, string symbol);

    function createNFTCollection(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyFee,
        address _royaltyRecipient
    ) external {
        KhaosNFT nft = new KhaosNFT(
            _name,
            _symbol,
            msg.sender,
            _royaltyFee,
            _royaltyRecipient
        );
        nfts[msg.sender].push(address(nft));
        khaosNFT[address(nft)] = true;
        emit CreatedNFTCollection(msg.sender, address(nft), _name, _symbol);
    }

    function getOwnCollections() external view returns (address[] memory) {
        return nfts[msg.sender];
    }

    function isKhaosNFT(address _nft) external view returns (bool) {
        return khaosNFT[_nft];
    }
}