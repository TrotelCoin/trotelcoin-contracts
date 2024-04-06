// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/TrotelCoin/trotelcoin-contracts/blob/main/token/TrotelCoinV2.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/proxy/utils/Initializable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/proxy/utils/UUPSUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/access/AccessControlUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/access/OwnableUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/utils/math/SafeMathUpgradeable.sol";

contract TrotelCoinShop is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    OwnableUpgradeable
{
    using SafeMathUpgradeable for uint256;

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    address public daoAddress;
    uint256 public feePercentage;

    TrotelCoinV2 public tokenFee;

    struct Category {
        string name;
        uint256[] categoryItems;
    }

    struct Item {
        string name;
        uint256 price;
        uint256 discount;
        string emoji;
        string description;
    }

    uint256 private totalCategories;
    uint256 private totalItems;

    mapping(uint256 => Category) private categories;
    mapping(uint256 => Item) private items;
    mapping(address => mapping(uint256 => uint256)) private inventory;

    event CategoryAdded(uint256 indexed categoryId, string name);
    event CategoryChanged(uint256 indexed categoryId, string newName);
    event CategoryRemoved(uint256 indexed categoryId);
    event ItemAddedToCategory(uint256 indexed itemId, uint256 indexed categoryId);
    event ItemRemovedFromCategory(uint256 indexed itemId, uint256 indexed categoryId);
    event ItemAdded(
        uint256 indexed itemId,
        string name,
        uint256 price,
        uint256 discount,
        string emoji,
        string description
    );
    event ItemRemoved(uint256 indexed itemId);
    event ItemChanged(uint256 indexed itemId,
        string newName,
        uint256 newPrice,
        uint256 newDiscount,
        string newEmoji,
        string newDescription);
    event FeePercentageChanged(uint256 newFeePercentage);
    event ItemBuyed(uint256 indexed itemId, uint256 quantity, uint256 price);
    event ItemUsed(uint256 indexed itemId, address indexed user);
    event TokenChanged(address newAddress);
    event OwnerChanged(address newOwner);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _daoAddress,
        uint256 _feePercentage,
        address _tokenFeeAddress,
        address _upgrader
    ) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(UPGRADER_ROLE, _upgrader);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        daoAddress = _daoAddress;
        feePercentage = _feePercentage;
        tokenFee = TrotelCoinV2(_tokenFeeAddress);
    }

    function addCategory(string memory _name) external onlyRole(DEFAULT_ADMIN_ROLE) {
        totalCategories++;
        uint256 categoryId = totalCategories;
        categories[categoryId].name = _name;
        emit CategoryAdded(categoryId, _name);
    }

    function removeCategory(uint256 _categoryId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(categories[_categoryId].categoryItems.length == 0, "Category not empty");
        delete categories[_categoryId];
        totalCategories--;
        emit CategoryRemoved(_categoryId);
    }

    function modifyCategory(uint256 _categoryId, string memory _newName) external onlyRole(DEFAULT_ADMIN_ROLE) {
        categories[_categoryId].name = _newName;
        emit CategoryChanged(_categoryId, _newName);
    }

    function addItemToCategory(uint256 _itemId, uint256 _categoryId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_itemId > 0 && _itemId <= totalItems, "Invalid item id");
        require(_categoryId > 0 && _categoryId <= totalCategories, "Invalid category id");

        categories[_categoryId].categoryItems.push(_itemId);
        emit ItemAddedToCategory(_itemId, _categoryId);
    }

    function removeItemFromCategory(uint256 _itemId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 categoryId = 1; categoryId <= totalCategories; categoryId++) {
            uint256[] storage categoryItems = categories[categoryId].categoryItems;
            for (uint256 i = 0; i < categoryItems.length; i++) {
                if (categoryItems[i] == _itemId) {
                    categoryItems[i] = categoryItems[categoryItems.length - 1];
                    categoryItems.pop();
                    emit ItemRemovedFromCategory(_itemId, categoryId);
                    return;
                }
            }
        }
    }

    function getItemsInCategory(uint256 _categoryId) external view returns (Item[] memory) {
        require(_categoryId > 0 && _categoryId <= totalCategories, "Invalid category id");
        uint256[] memory itemIds = categories[_categoryId].categoryItems;
        Item[] memory categoryItems = new Item[](itemIds.length);

        for (uint256 i = 0; i < itemIds.length; i++) {
            categoryItems[i] = items[itemIds[i]];
        }

        return categoryItems;
    }

    function addItem(
        string memory _name,
        uint256 _price,
        uint256 _discount,
        string memory _emoji,
        string memory _description
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        totalItems++;
        items[totalItems] = Item(_name, _price, _discount, _emoji, _description);
        emit ItemAdded(totalItems, _name, _price, _discount, _emoji, _description);
    }

    function removeItem(uint256 _itemId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_itemId > 0 && _itemId <= totalItems, "Invalid item id");
        delete items[_itemId];
        totalItems--;
        emit ItemRemoved(_itemId);
    }

    function modifyItem(
        uint256 _itemId,
        string memory _newName,
        uint256 _newPrice,
        uint256 _newDiscount,
        string memory _newEmoji,
        string memory _newDescription
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_itemId > 0 && _itemId <= totalItems, "Invalid item id");
        items[_itemId].name = _newName;
        items[_itemId].price = _newPrice;
        items[_itemId].discount = _newDiscount;
        items[_itemId].emoji = _newEmoji;
        items[_itemId].description = _newDescription;
        emit ItemChanged(_itemId, _newName, _newPrice, _newDiscount, _newEmoji, _newDescription);
    }

    function buyItem(uint256 _itemId, uint256 _quantity) external {
        require(_itemId > 0 && _itemId <= totalItems, "Invalid item id");
        Item storage item = items[_itemId];
        require(_quantity > 0, "Invalid quantity");
        require(item.price > 0, "Item not found");

        uint256 totalAmount = item.price.mul(_quantity);
        uint256 discountAmount = 0;

        if (_quantity > 1 && item.discount > 0) {
            discountAmount = item.discount.mul(_quantity.sub(1));
            totalAmount = totalAmount.sub(discountAmount);
        }

        uint256 feeAmount = totalAmount.mul(feePercentage).div(100);

        require(
            tokenFee.transferFrom(msg.sender, address(this), totalAmount),
            "Transfer failed"
        );
        require(
            tokenFee.transfer(daoAddress, feeAmount),
            "Transfer to DAO failed"
        );

        totalAmount = totalAmount.sub(feeAmount);
        tokenFee.burn(totalAmount);

        inventory[msg.sender][_itemId] = inventory[msg.sender][_itemId].add(_quantity);

        emit ItemBuyed(_itemId, _quantity, totalAmount);
    }

    function useItem(uint256 _itemId) external {
        require(_itemId > 0 && _itemId <= totalItems, "Invalid item id");
        require(inventory[msg.sender][_itemId] > 0, "Item not found in inventory");

        inventory[msg.sender][_itemId] = inventory[msg.sender][_itemId].sub(1);

        emit ItemUsed(_itemId, msg.sender);
    }

    function changeFeePercentage(uint256 _newFeePercentage) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _newFeePercentage >= 0 && _newFeePercentage <= 100,
            "Fee percentage must be between 0 and 100"
        );
        feePercentage = _newFeePercentage;
        emit FeePercentageChanged(_newFeePercentage);
    }

    function changeTokenFee(address _newAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenFee = TrotelCoinV2(_newAddress);
        emit TokenChanged(_newAddress);
    }

    function getAllCategories() external view returns (Category[] memory) {
        Category[] memory allCategories = new Category[](totalCategories);

        for (uint256 i = 1; i <= totalCategories; i++) {
            allCategories[i - 1] = categories[i];
        }

        return allCategories;
    }

    function getAllItems() external view returns (Item[] memory) {
        Item[] memory allItems = new Item[](totalItems);

        for (uint256 i = 1; i <= totalItems; i++) {
            allItems[i - 1] = items[i];
        }

        return allItems;
    }

    function getTotalCategories() external view returns (uint256) {
        return totalCategories;
    }

    function getTotalItems() external view returns (uint256) {
        return totalItems;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
