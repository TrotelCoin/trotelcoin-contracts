// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "remix_tests.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./TrotelCoinEarlyNFT.sol";

contract TrotelCoinEarlyNFTTest is ERC721Holder {
    TrotelCoinEarlyNFT trotelCoin;

    address constant private TEST_ADDRESS = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    function beforeAll() public {
        trotelCoin = new TrotelCoinEarlyNFT();
    }

    function beforeEach() public {
        trotelCoin.defaultMinter();
        trotelCoin.setMinter(address(this));
    }

    function testMint() public {
        trotelCoin.mint(TEST_ADDRESS);
        Assert.equal(trotelCoin.totalSupply(), 1, "Total supply should increase after minting");
    }

    function testMintToMultiple() public {
        address[] memory addressesToMint = new address[](3);
        addressesToMint[0] = TEST_ADDRESS;
        addressesToMint[1] = address(0x123);
        addressesToMint[2] = address(0x456);

        trotelCoin.mintToMultiple(addressesToMint);

        Assert.equal(trotelCoin.totalSupply(), 3, "Total supply should increase after minting to multiple addresses");
    }

    function testSetMinter() public {
        trotelCoin.setMinter(TEST_ADDRESS);

        bool isMinter = trotelCoin.minters(TEST_ADDRESS); // need to put minters as public to test
        assert(isMinter);
    }
}
