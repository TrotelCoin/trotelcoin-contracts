// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/IERC20.sol";

contract TrotelCoinExpertNFT is ERC721, Ownable {
    IERC20 public trotelCoin;
    uint256 public holdingRequirement = 50000;
    uint256 public tokenIdCounter = 0;

    mapping(uint256 => uint256) public trotelSpent;

    constructor(address _trotelCoinAddress) ERC721("TrotelCoin Expert", "TCE") {
        trotelCoin = IERC20(_trotelCoinAddress);
    }

    event NFTMinted(address indexed to, uint256 tokenId, uint256 trotelSpent);
    event UserProgressChanged(address indexed user, bool eligible);
    event HoldingRequirementUpdated(uint256 newHoldingRequirement);
    event TrotelCoinUpdated(address newTrotelCoin);

    function setTrotelCoin(address newTrotelCoinAddress) external onlyOwner {
        trotelCoin = IERC20(newTrotelCoinAddress);
        emit TrotelCoinUpdated(newTrotelCoinAddress);
    }

    function mint(address to) public {
        require(isEligibleForExpertNFT(to), "Not eligible for Expert NFT");
        _mint(to, tokenIdCounter);
        tokenIdCounter++;
        emit NFTMinted(to, tokenIdCounter, holdingRequirement);
    }

    function isEligibleForExpertNFT(address user) public view returns (bool) {
        uint256 userBalance = trotelCoin.balanceOf(user);
        return userBalance >= holdingRequirement;
    }

    function totalSupply() external view returns (uint256) {
        return tokenIdCounter;
    }

    function checkUserProgress(address user) public view returns (bool eligible) {
        eligible = isEligibleForExpertNFT(user);
    }

    function setHoldingRequirement(uint256 newRequirement) external onlyOwner {
        holdingRequirement = newRequirement;
        emit HoldingRequirementUpdated(newRequirement);
    }
}
