// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./TrotelCoinV1.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/proxy/utils/UUPSUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/proxy/utils/Initializable.sol";

contract TrotelCoinLearning is Initializable, UUPSUpgradeable {
    struct DailyStats {
        uint256 quizzesAnswered;
        uint256 rewards;
    }

    struct Learner {
        address learner;
        uint256 numberOfQuizzesAnswered;
        uint256 totalLearnerRewards;
    }

    TrotelCoin public trotelCoin;

    address public owner;
    uint256 public totalQuizzesAnswered;
    uint256 public totalRewards;
    uint256 public dailyTokensToDistribute;
    uint256 public remainingTokens;
    uint256 public rewardsPeriod;
    uint256 public rewardsTimestamp;

    mapping(address => Learner) public learners;
    mapping(address => mapping (uint => bool)) public quizzesIdAnsweredPerLearner;
    mapping(address => bool) public admins;
    mapping(address => bool) public isLearner;
    mapping (uint => bool) public availableQuizzes;

    event RewardsClaimed(address indexed learner, uint256 rewardsClaimed);
    event NewLearnerAdded(address indexed learner);
    event AdminAdded(address indexed newAdmin);
    event AdminRemoved(address indexed oldAdmin);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        owner = msg.sender;
        admins[msg.sender] = true;
        dailyTokensToDistribute = uint256(1000000 ether) / 365;
        remainingTokens = dailyTokensToDistribute / 50;
        rewardsPeriod = 1 days;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender] == true, "Not admin");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function authorizeQuizId(uint _quizId) external onlyAdmin {
        availableQuizzes[_quizId] = true;
    }

    function unauthorizeQuizId(uint _quizId) external onlyAdmin {
        availableQuizzes[_quizId] = false;
    }

    function addLearner(address _learner) private validAddress(_learner) {
        require(!isLearner[_learner], "Already learner");
        learners[_learner].learner = _learner;
        isLearner[_learner] = true;
        emit NewLearnerAdded(_learner);
    }

    function calculateRemainingRewardsPeriod() private view returns (uint256) {
        if (block.timestamp >= rewardsTimestamp + rewardsPeriod) {
            return 0;
        } else {
            return rewardsTimestamp + rewardsPeriod - block.timestamp;
        }
    }

    function calculateRewards() private view returns (uint256) {
        uint256 minReward = remainingTokens / 10; // 10%
        uint256 maxReward = remainingTokens / 4;  // 25%
        uint256 _reward = (minReward + uint256(keccak256(abi.encodePacked(block.timestamp))) % (maxReward - minReward + 1));
        return _reward;
    }

    function claimRewards(address _learner, uint _quizId) external validAddress(_learner) {
        require(availableQuizzes[_quizId], "Quiz doesn't exist");
        bool _isLearner = isLearner[_learner];
        if (!_isLearner) {
            addLearner(_learner);
        }
        require(!quizzesIdAnsweredPerLearner[_learner][_quizId], "Quiz already answered");

        uint256 remainingRewards = calculateRemainingRewardsPeriod();
        if (remainingRewards <= 0) {
            remainingTokens = dailyTokensToDistribute / 50;
        }

        uint256 rewards = calculateRewards();
        rewardsTimestamp = block.timestamp;

        trotelCoin.mint(_learner, rewards);

        learners[_learner].numberOfQuizzesAnswered++;
        learners[_learner].totalLearnerRewards += rewards;

        quizzesIdAnsweredPerLearner[_learner][_quizId] = true;
        totalQuizzesAnswered++;
        totalRewards += rewards;

        remainingTokens -= rewards / 50;

        emit RewardsClaimed(_learner, rewards);
    }


    function addAdmin(address _admin) external onlyOwner {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external onlyOwner {
        admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function getAdmin(address _admin) external view returns (bool) {
        return admins[_admin];
    }

    function setTrotelCoin(address _newTrotelCoin) external onlyAdmin {
        trotelCoin = TrotelCoin(_newTrotelCoin);
    }

    function setDailyTokensToDistribute(uint256 _dailyTokensToDistribute) external onlyAdmin {
        dailyTokensToDistribute = _dailyTokensToDistribute;
    }

    function setRemainingTokens(uint256 _remainingTokens) external onlyAdmin {
        remainingTokens = _remainingTokens;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyAdmin
    {}
}
