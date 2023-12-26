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

    string private secret;

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

    function addLearner(address _learner) public validAddress(_learner) {
        require(!isLearner[_learner], "Already learner");
        learners[_learner].learner = _learner;
        learners[_learner].numberOfQuizzesAnswered = 0;
        learners[_learner].totalLearnerRewards = 0;
        isLearner[_learner] = true;
        emit NewLearnerAdded(_learner);
    }

    function calculateRemainingRewardsPeriod() public view returns (uint256) {
        if (block.timestamp >= rewardsTimestamp + rewardsPeriod) {
            return 0;
        } else {
            return rewardsTimestamp + rewardsPeriod - block.timestamp;
        }
    }

    function calculateRewards() public view returns (uint256) {
        uint256 minReward = remainingTokens / 10; // 10%
        uint256 maxReward = remainingTokens / 4;  // 25%
        uint256 _reward = (minReward + uint256(keccak256(abi.encodePacked(block.timestamp))) % (maxReward - minReward + 1));
        return _reward;
    }

    function matchSecret(string memory _secret) public view onlyAdmin returns (bool) {
        return
            keccak256(abi.encodePacked(_secret)) ==
            keccak256(abi.encodePacked(secret));
    }

    function claimRewards(address _learner, string memory _secret, uint256 _quizzId)
        external
        validAddress(_learner)
    {
        if (!isLearner[_learner]) {
            addLearner(_learner);
        }
        require(matchSecret(_secret), "Not allowed to mint");
        require(!quizzesIdAnsweredPerLearner[_learner][_quizzId], "Quiz already answered");
        require(tx.origin == _learner, "Only learner can claim rewards");
        if (calculateRemainingRewardsPeriod() <= 0) {
            remainingTokens = dailyTokensToDistribute / 50;
        }
        uint256 _rewards = calculateRewards();
        rewardsTimestamp = block.timestamp;
        trotelCoin.mint(_learner, _rewards);
        learners[_learner].numberOfQuizzesAnswered += 1;
        learners[_learner].totalLearnerRewards += _rewards;
        quizzesIdAnsweredPerLearner[_learner][_quizzId] = true;
        totalQuizzesAnswered += 1;
        totalRewards += _rewards;
        remainingTokens -= _rewards / 50;
        emit RewardsClaimed(_learner, _rewards);
    }

    function addAdmin(address _admin) public onlyOwner {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) public onlyOwner {
        admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function getAdmin(address _admin) external view returns (bool) {
        return admins[_admin];
    }

    function setTrotelCoin(address _newTrotelCoin) public onlyAdmin {
        trotelCoin = TrotelCoin(_newTrotelCoin);
    }

    function setSecret(string memory _secret) public onlyAdmin {
        secret = _secret;
    }

    function getSecret() public view onlyAdmin returns (string memory) {
        return secret;
    }

    function getNumberOfQuizzesAnswer(address _learner)
        external
        view
        returns (uint256)
    {
        return learners[_learner].numberOfQuizzesAnswered;
    }

    function setDailyTokensToDistribute(uint256 _dailyTokensToDistribute) public onlyAdmin {
        dailyTokensToDistribute = _dailyTokensToDistribute;
    }

    function setRemainingTokens(uint256 _remainingTokens) public onlyAdmin {
        remainingTokens = _remainingTokens;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyAdmin
    {}
}
