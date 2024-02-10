// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./TrotelCoinLearning.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/token/ERC20/IERC20Upgradeable.sol";

contract TrotelCoinLearningTest {
    TrotelCoinLearning public learningContract;
    IERC20Upgradeable public trotelCoin;

    address public owner;
    address public admin1;
    address public learner1;

    constructor() {
        owner = msg.sender;
        admin1 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        learner1 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

        learningContract = new TrotelCoinLearning();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin1, "Not an admin");
        _;
    }

    modifier onlyLearner() {
        require(msg.sender == learner1, "Not a learner");
        _;
    }

    function initializeContract() external {
        learningContract.initialize();
    }

    function addAdmin() external onlyOwner {
        learningContract.addAdmin(admin1);
    }

    function removeAdmin() external onlyOwner {
        learningContract.removeAdmin(admin1);
    }

    function authorizeQuizId(uint _quizId) external onlyAdmin {
        learningContract.authorizeQuizId(_quizId);
    }

    function unauthorizeQuizId(uint _quizId) external onlyAdmin {
        learningContract.unauthorizeQuizId(_quizId);
    }

    function claimRewards(uint _quizId) external onlyLearner {
        learningContract.claimRewards(msg.sender, _quizId);
    }
}
