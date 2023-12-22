// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/IERC20.sol";

contract TrotelCoinEarlyNFT is ERC721, Ownable {
    uint256 public tokenIdCounter = 0;

    constructor() ERC721("TrotelCoin Early", "TCEARLY") {
    }

    event NFTMinted(address indexed to, uint256 tokenId);

    function mint(address to) public onlyOwner {
        _mint(to, tokenIdCounter);
        tokenIdCounter++;
        emit NFTMinted(to, tokenIdCounter);
    }

    function totalSupply() external view returns (uint256) {
        return tokenIdCounter;
    }
}