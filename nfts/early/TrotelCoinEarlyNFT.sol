// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/IERC20.sol";

contract TrotelCoinEarlyNFT is ERC721, Ownable {
    uint256 public tokenIdCounter = 0;
    address public defaultMinter;

    mapping (address => bool) minters;

    event NFTMinted(address indexed to, uint256 tokenId);

    constructor() ERC721("TrotelCoin Early", "TCEARLY") {
        defaultMinter = msg.sender;
        minters[msg.sender] = true;
    }

    modifier onlyDefaultMinter() {
        require(msg.sender == defaultMinter, "Not the owner");
        _;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Not a minter");
        _;
    }

    function mint(address to) public onlyMinter {
        _mint(to, tokenIdCounter);
        tokenIdCounter++;
        emit NFTMinted(to, tokenIdCounter);
    }

    function mintToMultiple(address[] memory addresses) public onlyMinter {
        for (uint256 i = 0; i < addresses.length; i++) {
            _mint(addresses[i], tokenIdCounter);
            tokenIdCounter++;
            emit NFTMinted(addresses[i], tokenIdCounter);
        }
    }

    function setMinter(address _newMinter) external onlyDefaultMinter {
        minters[_newMinter] = true;
    }

    function totalSupply() external view returns (uint256) {
        return tokenIdCounter;
    }
}

contract IntractTrotelCoinEarly {
    TrotelCoinEarlyNFT contractInstance;

    constructor(address _contractAddress) {
        contractInstance = TrotelCoinEarlyNFT(_contractAddress);
    }

    function mintToMultiple() external {
        address[] memory addressesToMint = new address[](130);
        addressesToMint[0] = address(0xa075104D047B8474576Fe0E2D3F86d94b5905f80);
        addressesToMint[1] = address(0x1990c29B1190184dE1Ed6C667f128CEb257b7BD9);
        addressesToMint[2] = address(0xAdD1129fadfEFBD660CfF48230c7EE8ea862dF3f);
        addressesToMint[3] = address(0xcE7EE38BA519b7Db03b3A0502545AA3eAB880901);
        addressesToMint[4] = address(0x0493b6988aDD9a904926937Abd80891c6F0D42ff);
        addressesToMint[5] = address(0xdB6BE2C5792455f5b4B2Bd47f1E54BA38Bd9c2B7);
        addressesToMint[6] = address(0xc09Aef0631909446D495224ADd265ED49bCa45Ca);
        addressesToMint[7] = address(0x5727b0B3FE892b25e326826FD564aF878C1d0206);
        addressesToMint[8] = address(0xDf72ca34C2BB189F4c60A707cA873B41fFe52edE);
        addressesToMint[9] = address(0xF93826C1D2D8a7f3D60D90F44fa0C1fD18d024C8);
        addressesToMint[10] = address(0x2a4E5b9C1c87DC511a7163B5A6d63A6aFEA2f7fE);
        addressesToMint[11] = address(0x2E4a9631e77247A8Bdc93F6F03d42fB5f9BAdF4e);
        addressesToMint[12] = address(0x2281c62588FA425a6E3229cE4991CC429D2263DD);
        addressesToMint[13] = address(0x89E1e6066635f69e596b7440243917aBC413689c);
        addressesToMint[14] = address(0xfb24B19a7dE9690E8085239bBB43fDc486FaD7Ab);
        addressesToMint[15] = address(0x76e8174F497e37b813eBea26050F9Bbd2C237794);
        addressesToMint[16] = address(0x0b11D438d83979374c31d219e7fb0405c9238DD5);
        addressesToMint[17] = address(0x67E6585623ef4F06d17332a311f84ae3D9E1aA3c);
        addressesToMint[18] = address(0x7A4A390633a0121F2c5A98b5D6e15445050eC246);
        addressesToMint[19] = address(0xe7B619a1C85753FE4B6e177a7d0800b20Ee3E4BC);
        addressesToMint[20] = address(0x127bB7B32Bc79D32BfbDC9614D12fd5658Be8b81);
        addressesToMint[21] = address(0xCaB7343b8e727ab3963F2bB34e65161cc07A50E0);
        addressesToMint[22] = address(0xAEC109dCd8521d4e12a7eC04532CBf9eCaFFcC52);
        addressesToMint[23] = address(0x19775E1817BC7a1e41060F80E0d00EabAE2959A7);
        addressesToMint[24] = address(0x667225CC6E9b407b46B469B861E9D29A99cE9145);
        addressesToMint[25] = address(0x158632dFccEAE59262e8a7b11B8250E9cCAa92d0);
        addressesToMint[26] = address(0x9B1c1B7a76ff97c6323257B20D70b139dB91d0f1);
        addressesToMint[27] = address(0xd152ee2e051924D167A1a87FA0099Ef125cF89FE);
        addressesToMint[28] = address(0x16813eaAED0b2fB9630700E109F81d9B0c37B03A);
        addressesToMint[29] = address(0x2a80014C978b77a85EdD2C5d654782dD68852E68);
        addressesToMint[30] = address(0xb66ef2F3ECbc18fa60538fc426C8332584b67cD1);
        addressesToMint[31] = address(0x224d2E3498E28940F89BDB1AB42C6c3a448025B8);
        addressesToMint[32] = address(0x9312225b91068b876126293E080c16f6B6dA4712);
        addressesToMint[33] = address(0xb11F0be6F95E066230fd4ea98EA63C36E3764EEE);
        addressesToMint[34] = address(0xe6f377131784Df641Bb0E69342501B1B0766281F);
        addressesToMint[35] = address(0x0C6249EF5f3aC452AE89B20e3f0Bc894D7ACF3Ff);
        addressesToMint[36] = address(0xde4CA1E38DE15F1533dF1f3660Eef16c80152bDb);
        addressesToMint[37] = address(0x7E8d97755b176349A3DA82107B2339fb95049905);
        addressesToMint[38] = address(0x10b0000Bb4B7a07ab03f2d1da71A505B41F2BFB5);
        addressesToMint[39] = address(0x223da95483520286fAFb15CC9ad00E1C4b8ce91a);
        addressesToMint[40] = address(0x4Df320d25E8DF805543a0f74B88CE2d2F6D67c90);
        addressesToMint[41] = address(0x2c96ED78A9D5FFB26FD67AcfC98267F0256c3006);
        addressesToMint[42] = address(0x3c6985BDb61d3B7f7A32c1CDC158493726084220);
        addressesToMint[43] = address(0x9B6e5967c89d05ACf5e27E6F4B480c30B7239688);
        addressesToMint[44] = address(0xa394DAabfA2F1c23db0B0c69EA550f9E6459d405);
        addressesToMint[45] = address(0x97aC14623ddC9030F5Ec84Bce140DCbe3fE2Ac48);
        addressesToMint[46] = address(0xBd6C12354288740472FE08465904A66b08C5c47e);
        addressesToMint[47] = address(0x2Bbe1998f437F74eca81D924752dcf0277c8B4Dc);
        addressesToMint[48] = address(0xBAd7136d3527cC5Bc18A81c8815956729cB72a72);
        addressesToMint[49] = address(0x70Eb58D6FD0744238Ba89D9E96C872bA326D984c);
        addressesToMint[50] = address(0xeE214b1BDA3B9C0fB4b8013E82778baA393A6F78);
        addressesToMint[51] = address(0x9f798E993fB87d1Dfc483d7576c11C239C9d9E7C);
        addressesToMint[52] = address(0x393b5505807dCe9f57ED9e285317e15fF0C622A9);
        addressesToMint[53] = address(0xcE1C9295244aF44B024a65354D80FF9389bD3536);
        addressesToMint[54] = address(0x96C7736bBBCD731E33B882b117E1214a4cCfa22E);
        addressesToMint[55] = address(0x8A83998b625d90A04BC2E0b72DCDe2f33Ab9355d);
        addressesToMint[56] = address(0xF7894F08f816EC2741563cb63861DA6E63a3d8dD);
        addressesToMint[57] = address(0xbEE2433d2de508064385C82715D8a93f5318A1d6);
        addressesToMint[58] = address(0x50794623A1618BF49E0aa475280DaEa3BE281B3c);
        addressesToMint[59] = address(0x01AE07f137DF957caCD5a02474019968c0eedB8c);
        addressesToMint[60] = address(0xf713C818a71400e76AaeaC5748DA88C762dC9Dbc);
        addressesToMint[61] = address(0xa799cF9a9242eB89d77a61571fb14502F6Ba453C);
        addressesToMint[62] = address(0x099532F577a1e474a30D198551936c8A075EFbE1);
        addressesToMint[63] = address(0x0A65C215CE8abC782A4B763FFfA10a41652Ac42C);
        addressesToMint[64] = address(0xAE7484f3587e783DebB51e430Fb2fA3a6427797B);
        addressesToMint[65] = address(0xdBe56345Cb2025Fbc4935768f49480d4004fcF32);
        addressesToMint[66] = address(0x55449773004C05CEb8fBA25E3738175800BFc906);
        addressesToMint[67] = address(0x14f22A3202FA7A9E869DC4F69dBf244aAF0D6cb5);
        addressesToMint[68] = address(0x1b76B4FE7602dD8542123eb7504b0E86Dcf90B65);
        addressesToMint[69] = address(0x1964b16073D891B048D36c4A1fA5b3E66cd919Be);
        addressesToMint[70] = address(0x094B9cf9363cc855101069d346C9eB95598C2095);
        addressesToMint[71] = address(0x3a43a837140378C74Bc9201faaEE69385E3cFcA2);
        addressesToMint[72] = address(0x1b2b3D008F85cA378d989fDD56D3e7FF24aa04f4);
        addressesToMint[73] = address(0x6a718978A8dcF0053b4Af526609215c55682d9a2);
        addressesToMint[74] = address(0xEE56FEBB8647Bc5F63F96f3b24F743e971120e28);
        addressesToMint[75] = address(0xa7462472aE2523f2ef0022690F6f891CBA6Ee94C);
        addressesToMint[76] = address(0xDC768186Cac0d2563e4986d0BED86A2D9221b87D);
        addressesToMint[77] = address(0xDDB343113B75EbB43E5aa42D71559D5A85952263);
        addressesToMint[78] = address(0x9022D014d960b1fc3e2696766698d1537b5c11eA);
        addressesToMint[79] = address(0x05a935a92Db5bfc8C665eD8d1761FDA10A91Bc2c);
        addressesToMint[80] = address(0x14Ca309223126dFd651D974CD359E1EC9ca5C59a);
        addressesToMint[81] = address(0x045A7129B943eEf7528Ef042A3AdD153B70dc8e1);
        addressesToMint[82] = address(0x94c105A920738e7ECDD5Fb442C1EA4bAdD51Ec7A);
        addressesToMint[83] = address(0xf8F90722B6D8D1B554a887662F0f16d111644c68);
        addressesToMint[84] = address(0xa4e9386BC3d8Ae26bb9a3aCE262359A4407743c1);
        addressesToMint[85] = address(0x5B839DE16d86c774Fd5ae92bff772e1f0D93E1D1);
        addressesToMint[86] = address(0x0681294fE1D527DDe290F065f249649F39d9d719);
        addressesToMint[87] = address(0x339F2Dd1C2B116618E5eC7A1ac0446E39fAbf8dd);
        addressesToMint[88] = address(0x968CD825522c50A9E1d393a546e560E49940d8e2);
        addressesToMint[89] = address(0xA5BE98ec4f02A0a6C182C2aE6168768d33dFB688);
        addressesToMint[90] = address(0x3BdfCa0d36ab23466dD68fD1cFe951921B3d2aEd);
        addressesToMint[91] = address(0x9f52E7D05eF15C5F14a419EF9abe344783Ff8d24);
        addressesToMint[92] = address(0x44FBCd7a7c9a97488B1e7047aC5f7ad5D3e3ecbf);
        addressesToMint[93] = address(0x9862c98f397c1B99D525E5e559B0aE02fF6dF52c);
        addressesToMint[94] = address(0xc7A21822aC0885999c42Ccf9A41bb1b7166789Db);
        addressesToMint[95] = address(0x22A9228C7d2BE7Da3f0A562f4fe362b95Dd9e579);
        addressesToMint[96] = address(0x56F75050FABC6296500f71521Cc10c6e32D899C6);
        addressesToMint[97] = address(0x0CD898352e9f781Af7d65E29adc890aDd42f7350);
        addressesToMint[98] = address(0xd1a690ff4392Ab677D5D2c044307FE2CE2CB5Ef2);
        addressesToMint[99] = address(0x768c545669e6821E059473FFca7912D291078cFe);
        addressesToMint[100] = address(0x3CB7e258dE4cF86f8E286ae3BEcD69B28D934c6D);
        addressesToMint[101] = address(0x9882954D15f500Ea7A63A33479CBE0132B584Eb0);
        addressesToMint[102] = address(0xCf24a48c662C096C602eBD45386A4b133B2Bd89E);
        addressesToMint[103] = address(0x27573933421403b0f832e346a6EF30ab103DafeD);
        addressesToMint[104] = address(0xA0DdEa94A1c76181ab8bBFdf6A2c2353CBE3cA05);
        addressesToMint[105] = address(0xe81B74146E27eB7c9eb862821A3dA3A8f6F29b06);
        addressesToMint[106] = address(0xBBb0C5f2E2ccF64563a8752F921DD541661E8cAd);
        addressesToMint[107] = address(0xCD5fb01D9F7af57EACCF00FF7b50014Ca7fA1146);
        addressesToMint[108] = address(0x66C0d9152209B51977047b9DC3b0B5bf2339b67C);
        addressesToMint[109] = address(0xb13D491fc28D3351eD0Aa4bBc5639ec02D8dD615);
        addressesToMint[110] = address(0x3658ce9070ba4c890cDBF59EE14AB3b4e73c0d17);
        addressesToMint[111] = address(0x94D70d38fd20e1a9ffB5B83c6298Fa4801FfeC7b);
        addressesToMint[112] = address(0x4175239A81A3280f8b93D30E40fB17133F22D713);
        addressesToMint[113] = address(0x653820cE32b3ac1DFf9D149D11eEa009B46864BB);
        addressesToMint[114] = address(0xBee2Ba88800800f49A0d8bD35969c914FCb8F53E);
        addressesToMint[115] = address(0x7FE35e8327B15912524bB850990046cdAF7Fe5E3);
        addressesToMint[116] = address(0x4Bc10a13A35565107BA0D6A0B273e163ef1Fb746);
        addressesToMint[117] = address(0x638aC4BC8C1585b7c0874c2dbaf80f5a8805559c);
        addressesToMint[118] = address(0x9FD4fAAfa63933eAA7A72AB12920dA1dC32aa1Fc);
        addressesToMint[119] = address(0xb44900990EB97CcfAF43e6d2F49C60714CF05E25);
        addressesToMint[120] = address(0x755CD4E94394F16c8214953DA4dDdDB3388A9748);
        addressesToMint[121] = address(0x71e91f689338B13aa4A8c32a69D410f433B91663);
        addressesToMint[122] = address(0xa1b95Af66E9a9Ec0aEd9A09BB6294B4f2c486A0f);
        addressesToMint[123] = address(0x1Fa4Feb6364C190cA8a340C3Af40862330d65ECD);
        addressesToMint[124] = address(0x3e9bFD8c32F76d98F0F86C622a64B27C3493cDa3);
        addressesToMint[125] = address(0x8333c1B5131CC694c3A238E41e50cbc236e73DbC);
        addressesToMint[126] = address(0x20948b421deF6A597c55e111cE43B06D1845870E);
        addressesToMint[127] = address(0x50D1F66689D7DCECCce294D15f72b3171D5579A5);
        addressesToMint[128] = address(0x8B253EceD564E483aeC4F30CD5A1916663a998Df);
        addressesToMint[129] = address(0x64EA76437183623Cd015Cc31757efFF2368f2923);

        contractInstance.mintToMultiple(addressesToMint);
    }
}
