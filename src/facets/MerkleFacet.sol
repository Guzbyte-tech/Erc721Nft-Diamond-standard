// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../libraries/LibDiamond.sol";
import "./ERC721Facet.sol";

contract MerkleFacet {
    function setMerkleRoot(bytes32 _merkleRoot) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond
            .diamondStorage();
        ds.merkleRoot = _merkleRoot;
    }

    function claim(bytes32[] calldata _merkleProof) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond
            .diamondStorage();
        require(!ds.claimed[msg.sender], "Address has already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, ds.merkleRoot, leaf),
            "Invalid merkle proof"
        );

        ds.claimed[msg.sender] = true;
        ERC721Facet(address(this)).safeMint(msg.sender, ds.totalSupply);
        ds.totalSupply++;
    }

    function hasClaimed(address _address) external view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.claimed[_address];
    }
}
