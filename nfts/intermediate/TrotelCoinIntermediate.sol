// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/IERC20.sol";

contract TrotelCoinIntermediateNFT is ERC721, Ownable {
    IERC20 public trotelCoin;
    uint256 public holdingRequirement = 10000;
    uint256 public tokenIdCounter = 0;

    mapping(address => bool) public allowedMinters;
    mapping(address => uint256) public mintLockTimestamp;

    constructor(address _trotelCoinAddress) ERC721("TrotelCoin Intermediate", "TCI") {
        trotelCoin = IERC20(_trotelCoinAddress);
        allowedMinters[msg.sender] = true;
    }

    event NFTMinted(address indexed to, uint256 tokenId, uint256 trotelSpent);
    event UserProgressChanged(address indexed user, bool eligible);
    event HoldingRequirementUpdated(uint256 newHoldingRequirement);
    event TrotelCoinUpdated(address newTrotelCoin);
    event MinterAdded(address minter);
    event MinterRemoved(address minter);

    function setTrotelCoin(address newTrotelCoinAddress) external onlyOwner {
        trotelCoin = IERC20(newTrotelCoinAddress);
        emit TrotelCoinUpdated(newTrotelCoinAddress);
    }

    modifier onlyAllowedMinter() {
        require(allowedMinters[msg.sender], "Caller is not an allowed minter");
        _;
    }

    function addMinter(address _minter) external onlyOwner {
        allowedMinters[_minter] = true;
        emit MinterAdded(_minter);
    }

    function removeMinter(address _minter) external onlyOwner {
        allowedMinters[_minter] = false;
        emit MinterRemoved(_minter);
    }

    function mint(address to) public {
        require(isEligibleForIntermediateNFT(to), "Not eligible for Intermediate NFT");
        require(balanceOf(to) < 1, "Already claimed the NFT");
        require(tx.origin == msg.sender, "Flash loans not allowed");

        _mint(to, tokenIdCounter);
        tokenIdCounter++;
        mintLockTimestamp[msg.sender] = block.timestamp;
        emit NFTMinted(to, tokenIdCounter, holdingRequirement);
    }

    function mintToAddress(address to) external onlyAllowedMinter {
        _mint(to, tokenIdCounter);
        tokenIdCounter++;
        emit NFTMinted(to, tokenIdCounter, 0);
    }

    function isEligibleForIntermediateNFT(address user) public view returns (bool) {
        uint256 userBalance = trotelCoin.balanceOf(user);
        return userBalance >= holdingRequirement;
    }

    function totalSupply() external view returns (uint256) {
        return tokenIdCounter;
    }

    function checkUserProgress(address user) public view returns (bool eligible) {
        eligible = isEligibleForIntermediateNFT(user);
    }

    function setHoldingRequirement(uint256 newRequirement) external onlyOwner {
        holdingRequirement = newRequirement;
        emit HoldingRequirementUpdated(newRequirement);
    }

    function _transfer(address from, address to, uint256 tokenId) internal override {
        require(to == address(0), "Transfers not allowed for this NFT");
        super._transfer(from, to, tokenId);
    }
}
