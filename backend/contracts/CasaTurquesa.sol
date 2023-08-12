// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

// import "@thirdweb-dev/contracts/base/ERC721Drop.sol";
import "@thirdweb-dev/contracts/token/TokenERC721.sol";
import "@thirdweb-dev/contracts/openzeppelin-presets/security/ReentrancyGuard.sol";
import "@thirdweb-dev/contracts/openzeppelin-presets/utils/Counters.sol";
import "@thirdweb-dev/contracts/extension/Ownable.sol";


import "./PoolTurquesa.sol";

contract CasaTurquesa is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    PoolTurquesa private poolContract;

    constructor(address _poolContractAddress) ERC721("CasaTurquesa", "CT") {
        poolContract = PoolTurquesa(_poolContractAddress);
    }

    function setPoolContract(address _poolContractAddress) public onlyOwner {
        poolContract = PoolTurquesa(_poolContractAddress);
    }

    function mint(address _to, uint256 _tokenId) internal {
        _safeMint(_to, _tokenId);
    }

}
