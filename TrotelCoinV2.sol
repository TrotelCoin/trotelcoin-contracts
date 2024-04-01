// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/token/ERC20/ERC20Upgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/access/AccessControlUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/proxy/utils/Initializable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/proxy/utils/UUPSUpgradeable.sol";

contract TrotelCoinV2 is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, AccessControlUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 private _cap;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address minter, address upgrader)
        initializer public
    {
        __ERC20_init("TrotelCoin", "TROTEL");
        __ERC20Burnable_init();
        __AccessControl_init();
        __ERC20Permit_init("TrotelCoin");
        __UUPSUpgradeable_init();
        _cap = 1000000000 * 10 ** decimals();

        _mint(msg.sender, 100000000 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= _cap, "Cap exceeded");
        _mint(to, amount);
    }

    function cap() public view returns(uint256) {
        return _cap;
    }

    function setCap(uint256 _newCap) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _cap = _newCap;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}