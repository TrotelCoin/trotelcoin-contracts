// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/proxy/utils/Initializable.sol";
import "./TrotelCoinV1.sol";

contract TrotelCoinStaking is Initializable, AccessControl {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // staking informations
    struct Staking {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
    }

    // mapping for users information
    mapping(address => Staking) public stakings;

    // TrotelCoin token contract
    TrotelCoin public trotelToken;

    // staking periods and corresponding APR
    mapping(uint256 => uint256) public stakingPeriods;

    // durations
    uint256 public thirstyDays = 30 days;
    uint256 public threeMonths = 91 days;
    uint256 public sixMonths = 192 days;
    uint256 public oneYear = 365 days;

    // events
    event Staked(address indexed user, uint256 amount, uint256 duration);
    event Unstaked(address indexed user, uint256 amount, uint256 rewards);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address _defaultAdmin,
        address _upgrader,
        address _trotelToken
    ) {
        // roles
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(UPGRADER_ROLE, _upgrader);

        trotelToken = TrotelCoin(_trotelToken);

        // set staking periods and corresponding APR
        stakingPeriods[30 days] = 3;
        stakingPeriods[91 days] = 6;
        stakingPeriods[182 days] = 10;
        stakingPeriods[365 days] = 15;
    }

    // stake TrotelCoins for a specified duration
    function stake(uint256 amount, uint256 duration) public {
        require(
            duration == 30 days ||
                duration == 91 days ||
                duration == 182 days ||
                duration == 365 days,
            "Invalid duration"
        );
        require(stakings[msg.sender].amount == 0, "Already staked");

        trotelToken.transferFrom(msg.sender, address(this), amount);

        stakings[msg.sender] = Staking({
            amount: amount,
            startTime: block.timestamp,
            duration: duration
        });

        emit Staked(msg.sender, amount, duration);
    }

    // unstake and claim rewards after the staking period
    function unstake() public {
        Staking storage userStaking = stakings[msg.sender];
        require(userStaking.amount > 0, "No staking found");
        require(
            block.timestamp >= userStaking.startTime + userStaking.duration,
            "Staking period not ended"
        );

        uint256 rewards = (userStaking.amount *
            stakingPeriods[userStaking.duration]) / 100;
        trotelToken.mint(msg.sender, userStaking.amount + rewards);
        trotelToken.burn(userStaking.amount);

        emit Unstaked(msg.sender, userStaking.amount, rewards);

        delete stakings[msg.sender];
    }

    // view function to get the user's earning amount and time left
    function getUserStakingDetails(address user)
        public
        view
        returns (uint256, uint256)
    {
        Staking storage userStaking = stakings[user];

        if (userStaking.amount == 0) {
            return (0, 0);
        }

        uint256 timeLeft = userStaking.startTime +
            userStaking.duration -
            block.timestamp;
        return (
            (userStaking.amount * stakingPeriods[userStaking.duration]) / 100,
            timeLeft
        );
    }
}
