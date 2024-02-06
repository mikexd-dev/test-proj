// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct NFT {
        uint256 tokenId;
        address nftOwner;
        uint256 price;
        bool forSale;
    }
    
    mapping(uint256 => NFT) public nfts;
    
    constructor() ERC721("NFT Marketplace", "NFTM") {}
    
    function createNFT(address _to, uint256 _price) external returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(_to, newTokenId);
        
        NFT storage nft = nfts[newTokenId];
        nft.tokenId = newTokenId;
        nft.nftOwner = _to;
        nft.price = _price;
        nft.forSale = true;
        
        return newTokenId;
    }
    
    function buyNFT(uint256 _tokenId) external payable {
        NFT storage nft = nfts[_tokenId];
        require(nft.forSale, "NFT is not for sale");
        require(msg.value == nft.price, "Incorrect amount");
        
        address nftOwner = nft.nftOwner;
        nft.forSale = false;
        nft.nftOwner = msg.sender;
        
        _safeTransfer(nftOwner, msg.sender, _tokenId, "");
    }
    
    function setPrice(uint256 _tokenId, uint256 _price) external {
        NFT storage nft = nfts[_tokenId];
        require(_msgSender() == nft.nftOwner, "Not the owner of the NFT");
        nft.price = _price;
    }
    
    function toggleForSale(uint256 _tokenId) external {
        NFT storage nft = nfts[_tokenId];
        require(_msgSender() == nft.nftOwner, "Not the owner of the NFT");
        nft.forSale = !nft.forSale;
    }
}