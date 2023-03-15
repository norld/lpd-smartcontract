// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface ILaunchpadFactory {
    function deployPool(
        uint256 _startTime,
        uint256 _duration,
        uint256 _totalSupply,
        address _IDOTokenAddress,
        address _txnTokenAddress,
        uint256 _txnRatio
    ) external;

    function getLaunchpadAddressByIndex(uint256 index)
        external
        view
        returns (address);

    function getLaunchpadAddressByRangeIndex(uint256 fromIndex, uint256 toIndex)
        external
        view
        returns (address[] memory);

    function getTotalLaunchpad() external view returns (uint256);

    function isManager(address user) external view returns (bool);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function setManager(address target, bool status) external;

    function transferOwnership(address newOwner) external;
}
