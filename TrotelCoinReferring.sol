// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface TrotelCoin {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ReferralSystem {
    mapping(address => address[]) public referrals;
    mapping(address => uint256) public referralCounts;

    TrotelCoin public trotelCoin;
    address public owner;

    event TokensRewarded(address recipient, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    constructor(address _trotelCoinAddress) {
        trotelCoin = TrotelCoin(_trotelCoinAddress);
        owner = msg.sender;
    }

    function setTrotelCoin(address _newTrotelCoinAddress) external onlyOwner {
        trotelCoin = TrotelCoin(_newTrotelCoinAddress);
    }

    function refer(address referredUser) external {
        require(msg.sender != referredUser, "You cannot refer yourself.");

        referrals[msg.sender].push(referredUser);
        referralCounts[referredUser]++;

        if (referralCounts[msg.sender] >= 3) {
            distributeRewardTokens(msg.sender);
        }
    }

    function distributeRewardTokens(address recipient) internal {
        uint256 rewardAmount = 2500;

        require(trotelCoin.balanceOf(address(this)) >= rewardAmount, "Insufficient funds in the contract.");

        bool transferSuccess = trotelCoin.transfer(recipient, rewardAmount);
        require(transferSuccess, "Token transfer failed");

        emit TokensRewarded(recipient, rewardAmount);
    }

    function getReferralCount(address referrer) external view returns (uint256) {
        return referralCounts[referrer];
    }

    function checkTrotelCoinBalance() external view returns (uint256) {
        return trotelCoin.balanceOf(address(this));
    }
}
