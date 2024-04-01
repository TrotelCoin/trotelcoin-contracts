// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/IERC20.sol";
import "https://github.com/TrotelCoin/trotelcoin-contracts/blob/main/TrotelCoinV2.sol";

contract TrotelCoinExpertNFTV2 is ERC721, Ownable {
    TrotelCoinV2 public trotelCoin;
    uint256 public holdingRequirement;
    uint256 public tokenIdCounter = 0;
    address public daoAddress = 0x804BCfe2cF0C9d363fE2D85FF29CF0A8FfcBB8db;

    mapping(address => bool) public allowedMinters;
    mapping(address => uint256) public mintLockTimestamp;

    constructor(address _trotelCoinAddress) ERC721("TrotelCoin Expert", "TCE") {
        trotelCoin = TrotelCoinV2(_trotelCoinAddress);
        holdingRequirement = 50000 * 10 ** trotelCoin.decimals();
        allowedMinters[msg.sender] = true;
    }

    event NFTMinted(address indexed to, uint256 tokenId, uint256 trotelSpent);
    event UserProgressChanged(address indexed user, bool eligible);
    event HoldingRequirementUpdated(uint256 newHoldingRequirement);
    event TrotelCoinUpdated(address newTrotelCoin);
    event MinterAdded(address minter);
    event MinterRemoved(address minter);
    event changingDaoAddress(address daoAddress);

    function setTrotelCoin(address newTrotelCoinAddress) external onlyOwner {
        trotelCoin = TrotelCoinV2(newTrotelCoinAddress);
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

    function approveContract(uint256 amount) external {
        trotelCoin.approve(address(this), amount);
    }

    function mint(address to) public {
        require(isEligibleForExpertNFT(to), "Not eligible for Expert NFT");
        require(balanceOf(to) < 1, "Already claimed the NFT");

        require(trotelCoin.allowance(msg.sender, address(this)) >= holdingRequirement, "Contract not approved to spend tokens");
        trotelCoin.transferFrom(msg.sender, daoAddress, holdingRequirement);
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
        holdingRequirement = newRequirement * 10 ** trotelCoin.decimals();
        emit HoldingRequirementUpdated(holdingRequirement);
    }

    function setDaoAddress(address newAddress) external onlyOwner {
        daoAddress = newAddress;
        emit changingDaoAddress(daoAddress);
    }

    function _transfer(address from, address to, uint256 tokenId) internal override {
        require(to == address(0), "Transfers not allowed for this NFT");
        super._transfer(from, to, tokenId);
    }
}
