// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../trotelcoin-contracts/token/implementation/TrotelCoinV2.sol";

contract TrotelCoinVestingBim is AccessControl {
    bytes32 public constant BENEFICIARY_ROLE = keccak256("BENEFICIARY_ROLE");

    uint256 public constant TOTAL_TOKENS = 5000000;
    uint256 public constant CLIFF_DURATION = 3 * 30 days; // 3 months cliff period
    uint256 public constant VESTING_DURATION = 12 * 30 days; // 12 months vesting period
    uint256 public constant MONTHLY_RELEASE_AMOUNT = TOTAL_TOKENS / 12; // 416,666 tokens per month

    address public trotelCoinDAO;
    address public beneficiary;
    uint256 public startTime;
    uint256 public releasedTokens;

    TrotelCoinV2 public trotelcoin;

    event TokensReleased(uint256 amount);

    modifier onlyBeneficiaryOrAdmin() {
        require(hasRole(BENEFICIARY_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not the beneficiary or admin");
        _;
    }

    constructor(address _beneficiary, address _trotelcoin, address _trotelCoinDAO) {
        require(_beneficiary != address(0), "Beneficiary address cannot be zero");
        require(_trotelcoin != address(0), "Token address cannot be zero");

        _setupRole(DEFAULT_ADMIN_ROLE, _trotelCoinDAO);
        _setupRole(BENEFICIARY_ROLE, _beneficiary);

        beneficiary = _beneficiary;
        trotelcoin = TrotelCoinV2(_trotelcoin);
        startTime = block.timestamp;
    }

    function release() public onlyBeneficiaryOrAdmin {
        require(block.timestamp >= startTime + CLIFF_DURATION, "Cliff duration not passed yet");
        require(trotelcoin.balanceOf(address(this)) >= MONTHLY_RELEASE_AMOUNT, "Not enough tokens to release");

        uint256 elapsedTime = block.timestamp - (startTime + CLIFF_DURATION);
        uint256 elapsedMonths = elapsedTime / 30 days;

        uint256 totalReleasable = (elapsedMonths + 1) * MONTHLY_RELEASE_AMOUNT;
        uint256 unreleased = totalReleasable - releasedTokens;

        require(unreleased > 0, "No tokens to release");

        releasedTokens += unreleased;
        trotelcoin.transfer(beneficiary, unreleased);

        emit TokensReleased(unreleased);
    }

    function changeBeneficiary(address _beneficiary) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        require(_beneficiary != address(0), "Beneficiary address cannot be zero");

        revokeRole(BENEFICIARY_ROLE, beneficiary);
        beneficiary = _beneficiary;
        grantRole(BENEFICIARY_ROLE, _beneficiary);
    }

    function getTimeUntilNextClaim() public view returns (uint256) {
        if (block.timestamp < startTime + CLIFF_DURATION) {
            return startTime + CLIFF_DURATION - block.timestamp;
        }

        uint256 elapsedTime = block.timestamp - (startTime + CLIFF_DURATION);

        if (elapsedTime % 30 days == 0) {
            return 0;
        }

        return 30 days - (elapsedTime % 30 days);
    }
}
