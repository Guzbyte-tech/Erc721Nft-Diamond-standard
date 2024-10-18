// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../libraries/LibDiamond.sol";
import "./ERC721Facet.sol";

contract PresaleFacet {
    function setPresaleParameters(
        uint256 _price,
        uint256 _minPurchase,
        uint256 _maxPurchase
    ) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.presalePrice = _price;
        ds.minPurchase = _minPurchase;
        ds.maxPurchase = _maxPurchase;
    }

    function buyPresale(uint256 _amount) external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_amount >= ds.minPurchase, "Below minimum purchase amount");
        require(_amount <= ds.maxPurchase, "Exceeds maximum purchase amount");
        require(msg.value >= _amount * ds.presalePrice, "Insufficient payment");

        for (uint256 i = 0; i < _amount; i++) {
            ERC721Facet(address(this)).safeMint(msg.sender, ds.totalSupply);
            ds.totalSupply++;
        }
    }
}
