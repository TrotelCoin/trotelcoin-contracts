// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/math/SafeMath.sol";
import "https://github.com/TrotelCoin/trotelcoin-contracts/blob/main/token/TrotelCoinV2.sol";

contract TrotelCoinStakingV2 is AccessControl {
    using SafeMath for uint256;

    struct UserStaking {
        uint256 totalAmount;
        uint256[] amounts;
        uint256[] times;
        uint256[] durations;
        uint256 startTime;
    }

    mapping(address => UserStaking) public stakings;

    TrotelCoinV2 private trotelToken;

    mapping(uint256 => uint256) private rewards;

    uint256[] public durations = [30 days, 91 days, 182 days, 365 days, 730 days, 1460 days];

    event Staked(address indexed user, uint256 amount, uint256 duration);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address _defaultAdmin,
        address _trotelToken
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);

        trotelToken = TrotelCoinV2(_trotelToken);

        rewards[durations[0]] = 3;   // 3%
        rewards[durations[1]] = 6;   // 6%
        rewards[durations[2]] = 10;  // 10%
        rewards[durations[3]] = 15;  // 15%
        rewards[durations[4]] = 20;  // 20%
        rewards[durations[5]] = 30;  // 30%
    }

    modifier isValidDuration(uint256 duration) {
        bool isValid;
        for (uint256 i = 0; i < durations.length; i++) {
            if (durations[i] == duration) {
                isValid = true;
                break;
            }
        }
        require(isValid, "Invalid duration");
        _;
    }

    function calculateReward(uint256 amount, uint256 duration, uint256 stakingTime) internal view returns (uint256) {
        uint256 reward = amount.mul(rewards[duration]).mul(stakingTime).div(365 days).div(100);
        return reward;
    }

    function stake(uint256 amount, uint256 duration) external isValidDuration(duration) {
        require(stakings[msg.sender].totalAmount == 0, "Already staked");

        trotelToken.transferFrom(msg.sender, address(this), amount);

        stakings[msg.sender] = UserStaking({
            totalAmount: amount,
            amounts: new uint256[](0),
            times: new uint256[](0),
            durations: new uint256[](0),
            startTime: block.timestamp
        });

        stakings[msg.sender].amounts.push(amount);
        stakings[msg.sender].times.push(block.timestamp);
        stakings[msg.sender].durations.push(duration);

        emit Staked(msg.sender, amount, duration);
    }

    function increaseStaking(uint256 amount) external {
        UserStaking storage userStaking = stakings[msg.sender];
        require(userStaking.totalAmount > 0, "No staking found");

        trotelToken.transferFrom(msg.sender, address(this), amount);

        userStaking.amounts.push(amount);
        userStaking.times.push(block.timestamp);
        userStaking.totalAmount = userStaking.totalAmount.add(amount);

        emit Staked(msg.sender, userStaking.totalAmount, userStaking.durations[userStaking.durations.length - 1]);
    }

    function unstake() external {
        UserStaking storage userStaking = stakings[msg.sender];
        require(userStaking.totalAmount > 0, "No staking found");

        uint256 totalReward = 0;
        uint256 stakingTime = block.timestamp - userStaking.startTime;
        for (uint256 i = 0; i < userStaking.amounts.length; i++) {
            uint256 duration = userStaking.durations[i];
            uint256 reward = calculateReward(userStaking.amounts[i], duration, stakingTime);
            totalReward = totalReward.add(reward);
        }

        trotelToken.mint(msg.sender, totalReward);
        trotelToken.transfer(msg.sender, userStaking.totalAmount);

        emit Unstaked(msg.sender, userStaking.totalAmount, totalReward);

        delete stakings[msg.sender];
    }

    function getDurations() external view returns (uint256[] memory) {
        return durations;
    }

    function getVotingPower(address user) external view returns (uint256) {
        UserStaking storage userStaking = stakings[user];
        return userStaking.totalAmount.mul(2);
    }

    function getTokenAddress() external view returns (TrotelCoinV2) {
        return trotelToken;
    }

    function getRewards(uint256 duration) external view returns (uint256) {
        return rewards[duration];
    }

    function getAllRewards() external view returns (uint256[] memory) {
        uint256[] memory allRewards = new uint256[](durations.length);

        for (uint256 i = 0; i < durations.length; i++) {
            allRewards[i] = rewards[durations[i]];
        }

        return allRewards;
    }

    function changeRewards(uint256 duration, uint256 newAPR) external onlyRole(DEFAULT_ADMIN_ROLE) {
        rewards[duration] = newAPR;
    }

    function getUserReward(address user) external view returns (uint256) {
        UserStaking storage userStaking = stakings[user];
        uint256 reward = calculateReward(userStaking.totalAmount, userStaking.durations[userStaking.durations.length - 1], block.timestamp - userStaking.startTime);
        return reward;
    }
}
