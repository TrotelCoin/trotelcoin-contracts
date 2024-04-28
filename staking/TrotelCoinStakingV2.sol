// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "../src/trotelcoin-contracts/token/implementation/TrotelCoinV2.sol";

contract TrotelCoinStakingV2 is AccessControl {
    using SafeMath for uint256;

    struct UserStaking {
        uint256 totalAmount;
        uint256 startTime;
        uint32 duration;
        uint256 endTime;
        uint256 apr;
        uint256[] amounts;
        uint256[] times;
    }

    mapping(address => UserStaking) public stakings;

    TrotelCoinV2 public trotelToken;

    struct Reward {
        uint256 apr;
        bool exists;
    }

    mapping(uint256 => Reward) public rewards;

    uint256[] public durations = [
        30 days,
        91 days,
        182 days,
        365 days,
        730 days,
        1460 days
    ];

    uint256 public multiplierVotingPower;

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
        uint256 stakingTime,
        uint256 apr
    ) public pure returns (uint256) {
        return amount.mul(stakingTime).mul(apr).div(365 days).div(100);
    }

    function getUserTimeLeft(address user) public view returns (uint256) {
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
        require(amount > 0, "Staking amount must be greater than 0");
        require(stakings[msg.sender].totalAmount == 0, "Already staked");

        uint256 reward = calculateReward(
            amount,
            duration,
            rewards[duration].apr
        );

        uint256 totalSupply = trotelToken.totalSupply();
        uint256 cap = trotelToken.cap();
        require(totalSupply.add(reward) <= cap, "Cap exceeded");

        trotelToken.transferFrom(msg.sender, address(this), amount);

        stakings[msg.sender] = UserStaking({
            totalAmount: amount,
            startTime: block.timestamp,
            duration: duration,
            endTime: block.timestamp.add(duration),
            apr: rewards[duration].apr,
            amounts: new uint256[](0),
            times: new uint256[](0)
        });

        stakings[msg.sender].amounts.push(amount);
        stakings[msg.sender].times.push(block.timestamp);

        emit Staked(msg.sender, amount, duration);
    }

    function increaseStaking(uint256 amount) external {
        require(amount > 0, "Staking amount must be greater than 0");
        UserStaking storage userStaking = stakings[msg.sender];
        require(userStaking.totalAmount > 0, "No staking found");
        require(
            getUserTimeLeft(msg.sender) > 0,
            "Staking duration is expired"
        );

        uint256 reward = calculateReward(
            amount,
            userStaking.duration,
            userStaking.apr
        );

        uint256 totalSupply = trotelToken.totalSupply();
        uint256 cap = trotelToken.cap();
        require(totalSupply.add(reward) <= cap, "Cap exceeded");

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
            uint256 stakingTime = userStaking.endTime.sub(userStaking.times[i]);
            totalReward = totalReward.add(
                calculateReward(
                    userStaking.amounts[i],
                    stakingTime,
                    userStaking.apr
                )
            );
        }

        trotelToken.transfer(msg.sender, userStaking.totalAmount);
        trotelToken.mint(msg.sender, totalReward);

        emit Unstaked(msg.sender, userStaking.totalAmount, totalReward);

        delete stakings[msg.sender];
    }

    function getUserReward(address user) external view returns (uint256) {
        UserStaking storage userStaking = stakings[user];

        uint256 totalReward = 0;
        for (uint256 i = 0; i < userStaking.amounts.length; i++) {
            uint256 stakingTime = userStaking.endTime.sub(userStaking.times[i]);
            totalReward = totalReward.add(
                calculateReward(
                    userStaking.amounts[i],
                    stakingTime,
                    userStaking.apr
                )
            );
        }
        return totalReward;
    }

    function changeMultiplierVotingPower(uint256 newMultiplierVotingPower)
        external
    {
        multiplierVotingPower = newMultiplierVotingPower;
    }

    function getVotingPower(address user) external view returns (uint256) {
        return stakings[user].totalAmount.mul(multiplierVotingPower);
    }

    function changeRewards(uint32 duration, uint256 newAPR)
        external isValidDuration(duration)
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        rewards[duration].apr = newAPR;
    }

    function getStakingTotalAmount(address _address) public view returns (uint256) {
        return stakings[_address].totalAmount;
    }

    function getRewardApr(uint256 duration) public view returns (uint256) {
        return rewards[duration].apr;
    }

    function getStakings(address _address) public view returns (UserStaking memory) {
        return stakings[_address];
    }
}