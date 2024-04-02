// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/TrotelCoin/trotelcoin-contracts/blob/main/token/TrotelCoinV2.sol";

contract TrotelCoinShopV1 {
    address public owner;
    address public daoAddress;
    uint256 public feePercentage;
    uint256 public totalItems;
    TrotelCoinV2 public tokenFee;

    struct Item {
        string name;
        uint256 price;
        uint256 discount;
    }

    struct InventoryItem {
        Item item;
        uint256 quantity;
    }

    mapping(uint256 => Item) public items;
    mapping(address => InventoryItem[]) public inventories;

    event ItemAdded(uint256 indexed itemId, string name, uint256 price, uint256 discount);
    event ItemRemoved(uint256 indexed itemId);
    event FeePercentageChanged(uint256 newFeePercentage);
    event ItemBuyed(uint256 indexed itemId, uint256 quantity, uint256 price);
    event TokenChanged(address newAddress);
    event OwnerChanged(address newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor(address _daoAddress, uint256 _feePercentage, address _tokenFeeAddress) {
        owner = msg.sender;
        daoAddress = _daoAddress;
        feePercentage = _feePercentage;
        tokenFee = TrotelCoinV2(_tokenFeeAddress);
    }

    function addItem(string memory _name, uint256 _price, uint256 _discount) external onlyOwner {
        totalItems++;
        items[totalItems] = Item(_name, _price, _discount);
        emit ItemAdded(totalItems, _name, _price, _discount);
    }

    function removeItem(uint256 _itemId) external onlyOwner {
        require(_itemId > 0 && _itemId <= totalItems, "Invalid item id");
        delete items[_itemId];
        totalItems--;
        emit ItemRemoved(_itemId);
    }

    function buyItem(uint256 _itemId, uint256 _quantity) external {
        require(_itemId > 0 && _itemId <= totalItems, "Invalid item id");
        Item storage item = items[_itemId];
        require(_quantity > 0, "Invalid quantity");
        require(item.price > 0, "Item not found");

        uint256 itemsPrice = item.price * _quantity;
        uint256 feeAmount = (itemsPrice * feePercentage) / 100;
        uint256 totalAmount = itemsPrice;

        require(tokenFee.transferFrom(msg.sender, address(this), totalAmount), "Transfer failed");
        require(tokenFee.transfer(daoAddress, feeAmount), "Transfer to DAO failed");

        totalAmount -= feeAmount;
        
        if (_quantity > 1 && item.discount > 0) {
            uint256 discountAmount = item.discount * (_quantity - 1);
            totalAmount -= discountAmount;
        }

        tokenFee.burn(totalAmount);

        bool found = false;
        for(uint i = 0; i < inventories[msg.sender].length; i++) {
            if(keccak256(abi.encodePacked(inventories[msg.sender][i].item.name)) == keccak256(abi.encodePacked(item.name))) {
                inventories[msg.sender][i].quantity += _quantity;
                found = true;
                break;
            }
        }
        if(!found) {
            inventories[msg.sender].push(InventoryItem(item, _quantity));
        }

        emit ItemBuyed(_itemId, _quantity, totalAmount);
    }

    function setFeePercentage(uint256 _newFeePercentage) external onlyOwner {
        require(_newFeePercentage <= 100, "Fee percentage must be less than or equal to 100");
        feePercentage = _newFeePercentage;
        emit FeePercentageChanged(_newFeePercentage);
    }

    function setTokenFee(address _newAddress) external onlyOwner {
        tokenFee = TrotelCoinV2(_newAddress);
        emit TokenChanged(_newAddress);
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}
