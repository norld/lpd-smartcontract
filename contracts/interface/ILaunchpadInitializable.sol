// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface ILaunchpadInitializable {
    function LAUNCHPAD_FACTORY() external view returns (address);

    function initialize(
        uint256 _startTime,
        uint256 _duration,
        uint256 _totalSupply,
        address _IDOTokenAddress,
        address _txnTokenAddress,
        uint256 _txnRatio,
        uint256 _minAmount,
        uint256 _maxAmount
    ) external;

    function getEndTime() external view returns (uint256);

    function getSoftCap() external view returns (uint256);

    function getAccountsLength() external view returns (uint256);

    function purchase(uint256 txnAmount) external payable;

    function earned(address account) external view returns (uint256);

    function claimRewards() external;
}
