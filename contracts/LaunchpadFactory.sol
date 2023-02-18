// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interface/ILaunchpadInitializable.sol";

contract LaunchpadFactory is Ownable {
    using Counters for Counters.Counter;

    event NewLaunchpadContract(address indexed launchpad);
    event managerStatus(address indexed user, bool indexed isManagerNow);

    address private implemented;

    mapping(address => bool) private manager;
    mapping(uint256 => address) private pairList;
    mapping(address => mapping(address => address[])) private stakePair;

    Counters.Counter private totalPair;

    constructor(address base) {
        implemented = base;
    }

    modifier onlyManager() {
        require(
            isManager(_msgSender()) == true,
            "LaunchpadFactory : only launchpad manager allowed!"
        );
        _;
    }

    function setManager(address target, bool status)
        external
        virtual
        onlyOwner
    {
        manager[target] = status;

        emit managerStatus(target, status);
    }

    function deployPool(
        uint256 _startTime,
        uint256 _duration,
        uint256 _totalSupply,
        IERC20Metadata _IDOTokenAddress,
        IERC20Metadata _txnTokenAddress,
        uint256 _txnRatio
    ) external onlyManager {
        require(_IDOTokenAddress.decimals() > 0);
        require(_txnTokenAddress.decimals() > 0);

        bytes32 salt = keccak256(
            abi.encodePacked(_IDOTokenAddress, _txnTokenAddress, _startTime)
        );
        address launchpadAddress = Clones.cloneDeterministic(implemented, salt);

        ILaunchpadInitializable(launchpadAddress).initialize(
            _startTime,
            _duration,
            _totalSupply,
            address(_IDOTokenAddress),
            address(_txnTokenAddress),
            _txnRatio
        );

        {
            uint256 currentIndex = totalPair.current();
            totalPair.increment();
            pairList[currentIndex] = launchpadAddress;
        }

        emit NewLaunchpadContract(launchpadAddress);
    }

    function getTotalLaunchpad() public view returns (uint256) {
        return totalPair.current();
    }

    function getLaunchpadAddressByIndex(uint256 index)
        public
        view
        returns (address)
    {
        return pairList[index];
    }

    function getLaunchpadAddressByRangeIndex(uint256 fromIndex, uint256 toIndex)
        public
        view
        returns (address[] memory)
    {
        unchecked {
            uint256 getRange = (toIndex - fromIndex) + 1;
            address[] memory list = new address[](getRange);

            for (uint256 a; a < getRange; a++) {
                uint256 index = fromIndex + a;
                list[a] = pairList[index];
            }

            return list;
        }
    }

    function isManager(address user) public view returns (bool) {
        return user == owner() || manager[user] == true;
    }
}
