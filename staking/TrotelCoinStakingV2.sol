// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/math/SafeMath.sol";
import "https://github.com/TrotelCoin/trotelcoin-contracts/blob/main/token/TrotelCoinV2.sol";

contract TrotelCoinStakingV2 is AccessControl {
    using SafeMath for uint256;

    struct UserStaking {
        uint256 totalAmount;
        uint256 startTime;
        uint32 duration;
        uint256[] amounts;
        uint256[] times;
    }

    mapping(address => UserStaking) public stakings;

    TrotelCoinV2 private trotelToken;

    struct Reward {
        uint256 apr;
        bool exists;
    }

    mapping(uint256 => Reward) private rewards;

    uint256[] public durations = [
        30 days,
        91 days,
        182 days,
        365 days,
        730 days,
        1460 days
    ];

    uint256 multiplierVotingPower;

    event Staked(address indexed user, uint256 amount, uint32 duration);
    event IncreasedStaking(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address _defaultAdmin, address _trotelToken) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);

        trotelToken = TrotelCoinV2(_trotelToken);

        rewards[30 days] = Reward(3, true);
        rewards[91 days] = Reward(6, true);
        rewards[182 days] = Reward(10, true);
        rewards[365 days] = Reward(15, true);
        rewards[730 days] = Reward(20, true);
        rewards[1460 days] = Reward(30, true);

        multiplierVotingPower = 2;
    }

    modifier isValidDuration(uint32 duration) {
        require(rewards[duration].exists, "Duree invalide");
        _;
    }

    function calculateReward(
        uint256 amount,
        uint32 duration,
        uint256 stakingTime
    ) internal view returns (uint256) {
        uint256 apr = rewards[duration].apr;
        return amount.mul(apr).mul(stakingTime).div(365 days).div(100);
    }

    function getUserTimeLeft(address user) internal view returns (uint256) {
        UserStaking storage userStaking = stakings[user];
        uint256 endTime = userStaking.startTime.add(userStaking.duration);

        if (block.timestamp < endTime) {
            return endTime.sub(block.timestamp);
        } else {
            return 0;
        }
    }

    function stake(uint256 amount, uint32 duration)
        external
        isValidDuration(duration)
    {
        require(stakings[msg.sender].totalAmount == 0, "Already staked");

        trotelToken.transferFrom(msg.sender, address(this), amount);

        stakings[msg.sender] = UserStaking({
            totalAmount: amount,
            startTime: block.timestamp,
            duration: duration,
            amounts: new uint256[](0),
            times: new uint256[](0)
        });

        stakings[msg.sender].amounts.push(amount);
        stakings[msg.sender].times.push(block.timestamp);

        emit Staked(msg.sender, amount, duration);
    }

    function increaseStaking(uint256 amount) external {
        UserStaking storage userStaking = stakings[msg.sender];
        require(userStaking.totalAmount > 0, "No staking found");
        require(
            getUserTimeLeft(msg.sender) > 0,
            "Staking duration is expired"
        );

        trotelToken.transferFrom(msg.sender, address(this), amount);

        userStaking.amounts.push(amount);
        userStaking.times.push(block.timestamp);
        userStaking.totalAmount = userStaking.totalAmount.add(amount);

        emit IncreasedStaking(msg.sender, amount);
    }

    function unstake() external {
        UserStaking storage userStaking = stakings[msg.sender];
        require(userStaking.totalAmount > 0, "No staking found");
        require(
            getUserTimeLeft(msg.sender) == 0,
            "Staking duration not yet expired"
        );

        uint256 totalReward = 0;
        for (uint256 i = 0; i < userStaking.amounts.length; i++) {
            uint256 stakingTime;
            if (i == userStaking.amounts.length - 1) {
                stakingTime = block.timestamp - userStaking.times[i];
            } else {
                stakingTime = userStaking.times[i + 1] - userStaking.times[i];
            }
            totalReward = totalReward.add(
                calculateReward(
                    userStaking.amounts[i],
                    userStaking.duration,
                    stakingTime
                )
            );
        }

        uint256 mintAmount = userStaking.totalAmount.add(totalReward);

        trotelToken.mint(msg.sender, mintAmount);
        trotelToken.burn(userStaking.totalAmount);

        emit Unstaked(msg.sender, userStaking.totalAmount, totalReward);

        delete stakings[msg.sender];
    }

    function getUserReward(address user) external view returns (uint256) {
        UserStaking storage userStaking = stakings[user];

        uint256 totalReward = 0;
        for (uint256 i = 0; i < userStaking.amounts.length; i++) {
            uint256 stakingTime;
            if (i == userStaking.amounts.length - 1) {
                stakingTime = block.timestamp - userStaking.times[i];
            } else {
                stakingTime = userStaking.times[i + 1] - userStaking.times[i];
            }
            totalReward = totalReward.add(
                calculateReward(
                    userStaking.amounts[i],
                    userStaking.duration,
                    stakingTime
                )
            );
        }
        return totalReward;
    }

    function getDurations() external view returns (uint256[] memory) {
        return durations;
    }

    function getMultiplierVotingPower() external view returns (uint256) {
        return multiplierVotingPower;
    }

    function changeMultiplierVotingPower(uint256 newMultiplierVotingPower)
        external
    {
        multiplierVotingPower = newMultiplierVotingPower;
    }

    function getVotingPower(address user) external view returns (uint256) {
        return stakings[user].totalAmount.mul(multiplierVotingPower);
    }

    function getTokenAddress() external view returns (TrotelCoinV2) {
        return trotelToken;
    }

    function getRewards(uint256 duration) external view returns (uint256) {
        return rewards[duration].apr;
    }

    function getAllRewards() external view returns (uint256[] memory) {
        uint256[] memory allRewards = new uint256[](durations.length);
        for (uint256 i = 0; i < durations.length; i++) {
            allRewards[i] = rewards[durations[i]].apr;
        }
        return allRewards;
    }

    function changeRewards(uint256 duration, uint256 newAPR)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        rewards[duration].apr = newAPR;
    }
}
