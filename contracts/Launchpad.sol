// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interface/ILaunchpadFactory.sol";

interface IWhiteList {
    function isInWhiteList(address account) external view returns (bool);
}

contract LaunchpadInitializable is
    Context,
    Initializable,
    ReentrancyGuard,
    Ownable
{
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20Metadata;

    address public LAUNCHPAD_FACTORY;
    uint256 public startTime;
    uint256 public endTime;
    uint256 private totalSupply;
    address public IDOTokenAddress;

    address public txnTokenAddress;
    uint256 public txnRatio;
    uint256 public txnDecimals;
    uint256 private softCap;

    mapping(address => BuyRecord) private mBuyRecords;
    address[] private aryAccounts;
    uint256 private position = 0;

    TxnLimit private buyLimit;
    uint256 private whiteListExpireTime = 0;
    address private whiteListContract;

    SharingRule[] private arySharingRules;
    ReleaseRule[] private aryReleaseRules;
    uint256 private _total;
    bool private claimOpen = true;
    address private seniorWhiteList;

    constructor() {
        if (_msgSender().isContract() == false) {
            _disableInitializers();
        }
    }

    modifier onlyController() {
        require(
            _msgSender() == owner(),
            "Ownable: caller is not the controller"
        );
        _;
    }

    function initialize(
        uint256 _startTime,
        uint256 _duration,
        uint256 _totalSupply,
        address _IDOTokenAddress,
        address _txnTokenAddress,
        uint256 _txnRatio
    ) external initializer {
        LAUNCHPAD_FACTORY = _msgSender();
        startTime = _startTime;
        endTime = _startTime + _duration;
        totalSupply = _totalSupply;
        _total = _totalSupply;
        IDOTokenAddress = _IDOTokenAddress;
        txnTokenAddress = _txnTokenAddress;
        txnRatio = _txnRatio;

        buyLimit.maxTimes = 1;
    }

    function getPoolInfo() public view returns (PoolInfo memory) {
        PoolInfo memory poolInfo = PoolInfo({
            withdrawToken: IDOTokenAddress,
            exchangeToken: txnTokenAddress,
            ratio: txnRatio,
            poolStartTime: startTime,
            poolEndTime: endTime,
            total: _total
        });
        return poolInfo;
    }

    struct PoolInfo {
        address withdrawToken;
        address exchangeToken;
        uint256 ratio;
        uint256 poolStartTime;
        uint256 poolEndTime;
        uint256 total;
    }

    function getEndTime() public view returns (uint256) {
        return endTime;
    }

    function getSoftCap() public view returns (uint256) {
        return softCap;
    }

    function getBuyRecord(address account)
        public
        view
        returns (BuyRecord memory)
    {
        return mBuyRecords[account];
    }

    function getAccountsLength() public view returns (uint256) {
        return aryAccounts.length;
    }

    function getBuyRecordByIndex(uint256 index)
        public
        view
        returns (BuyRecord memory)
    {
        return mBuyRecords[aryAccounts[index]];
    }

    function purchase(uint256 txnAmount) public payable {
        require(block.timestamp >= startTime, "this pool is not start");
        require(block.timestamp <= endTime, "this pool is end");
        if (txnTokenAddress == address(0)) {
            require(msg.value == txnAmount);
        }
        if (
            seniorWhiteList == address(0) ||
            !IWhiteList(seniorWhiteList).isInWhiteList(msg.sender)
        ) {
            if (
                whiteListContract != address(0) &&
                (whiteListExpireTime == 0 ||
                    block.timestamp < whiteListExpireTime)
            ) {
                require(
                    IWhiteList(whiteListContract).isInWhiteList(msg.sender),
                    "you is not in white list"
                );
            }
            if (buyLimit.minAmount > 0) {
                require(
                    txnAmount >= buyLimit.minAmount,
                    "buy amount too small"
                );
            }
            if (buyLimit.maxAmount > 0) {
                require(
                    txnAmount <= buyLimit.maxAmount,
                    "buy amount too large"
                );
            }
            if (buyLimit.maxTimes > 0) {
                require(
                    mBuyRecords[msg.sender].buyTimes < buyLimit.maxTimes,
                    "buy times is not enough"
                );
            }
        }

        uint256 rewards;

        require(totalSupply >= rewards, "total supply is not enough");
        if (txnTokenAddress != address(0)) {
            txnDecimals = IERC20Metadata(txnTokenAddress).decimals();
            rewards = txnAmount.mul(txnRatio).div(10**txnDecimals);
            require(
                IERC20Metadata(txnTokenAddress).transferFrom(
                    msg.sender,
                    address(this),
                    txnAmount
                )
            );
        } else {
            rewards = txnAmount.mul(txnRatio).div(10**18);
        }
        require(rewards > 0, "txn amount is too small");

        totalSupply -= rewards;
        if (mBuyRecords[msg.sender].buyTimes == 0) {
            aryAccounts.push(msg.sender);
        }
        mBuyRecords[msg.sender].buyTimes += 1;
        mBuyRecords[msg.sender].txnAmount += txnAmount;
        mBuyRecords[msg.sender].rewards += rewards;
    }

    function earned(address account) public view returns (uint256) {
        uint256 releaseRewards = 0;
        uint256 totalTxnAmount;
        if (txnTokenAddress == address(0)) {
            totalTxnAmount = address(this).balance;
        } else {
            totalTxnAmount = IERC20Metadata(txnTokenAddress).balanceOf(
                address(this)
            );
        }

        if (block.timestamp > endTime && totalTxnAmount >= softCap) {
            uint256 calcRatio = 0;
            BuyRecord memory record = mBuyRecords[account];
            if (aryReleaseRules.length > 0) {
                for (uint256 idx = 0; idx < aryReleaseRules.length; idx++) {
                    ReleaseRule memory rule = aryReleaseRules[idx];
                    if (block.timestamp > rule.iTime) {
                        calcRatio += rule.ratio;
                    }
                }
            } else {
                calcRatio = 1e18;
            }

            releaseRewards = record.rewards.mul(calcRatio).div(1e18).sub(
                record.paidRewards
            );

            uint256 surplusRewards = IERC20Metadata(IDOTokenAddress).balanceOf(
                address(this)
            );
            releaseRewards = Math.min(releaseRewards, surplusRewards);
        }
        return releaseRewards;
    }

    function claimRewards() public {
        require(claimOpen, "can not claim now");
        require(block.timestamp > endTime, "this pool is not end");
        uint256 totalTxnAmount;
        if (txnTokenAddress == address(0)) {
            totalTxnAmount = address(this).balance;
        } else {
            totalTxnAmount = IERC20Metadata(txnTokenAddress).balanceOf(
                address(this)
            );
        }

        require(totalTxnAmount >= softCap, "IDO txn amount is not enough");
        uint256 trueRewards = earned(msg.sender);
        require(trueRewards > 0, "rewards amount can not be zero");
        require(
            IERC20Metadata(IDOTokenAddress).transfer(msg.sender, trueRewards)
        );
        mBuyRecords[msg.sender].paidRewards += trueRewards;
    }

    function clearAll() public onlyController {
        require(block.timestamp > endTime, "this pool is not end");
        require(arySharingRules.length > 0, "sharing rules must be configured");
        uint256 surplusRewards = IERC20Metadata(IDOTokenAddress).balanceOf(
            address(this)
        );
        uint256 totalTxnAmount;
        if (txnTokenAddress == address(0)) {
            totalTxnAmount = address(this).balance;
        } else {
            totalTxnAmount = IERC20Metadata(txnTokenAddress).balanceOf(
                address(this)
            );
        }
        if (totalTxnAmount < softCap) {
            for (uint256 idx = 0; idx < arySharingRules.length; idx++) {
                SharingRule memory rule = arySharingRules[idx];
                surplusRewards = Math.min(totalSupply, surplusRewards);
                if (rule.iType == 1 && surplusRewards > 0) {
                    require(
                        IERC20Metadata(IDOTokenAddress).transfer(
                            rule.clearAddress,
                            surplusRewards
                        )
                    );
                }
            }
        } else {
            uint256 tmpTxnAmount = totalTxnAmount;
            for (uint256 idx = 0; idx < arySharingRules.length; idx++) {
                SharingRule memory rule = arySharingRules[idx];
                if (rule.iType == 1) {
                    uint256 revertRewards = Math.min(
                        totalSupply,
                        surplusRewards
                    );
                    if (revertRewards > 0) {
                        require(
                            IERC20Metadata(IDOTokenAddress).transfer(
                                rule.clearAddress,
                                revertRewards
                            )
                        );
                    }
                }

                uint256 sharingAmount = totalTxnAmount.mul(rule.ratio).div(
                    1e18
                );
                sharingAmount = Math.min(sharingAmount, tmpTxnAmount);
                if (sharingAmount > 0) {
                    if (txnTokenAddress == address(0)) {
                        payable(rule.clearAddress).transfer(sharingAmount);
                    } else {
                        require(
                            IERC20Metadata(txnTokenAddress).transfer(
                                rule.clearAddress,
                                sharingAmount
                            )
                        );
                    }
                }

                tmpTxnAmount = tmpTxnAmount.sub(sharingAmount);
            }
        }
    }

    function clear() public onlyController {
        require(block.timestamp > endTime, "this pool is not end");
        require(arySharingRules.length > 0, "sharing rules must be configured");
        uint256 totalTxnAmount;
        if (txnTokenAddress == address(0)) {
            totalTxnAmount = address(this).balance;
        } else {
            totalTxnAmount = IERC20Metadata(txnTokenAddress).balanceOf(
                address(this)
            );
        }
        if (totalTxnAmount >= softCap) {
            uint256 tmpTxnAmount = totalTxnAmount;
            for (uint256 idx = 0; idx < arySharingRules.length; idx++) {
                SharingRule memory rule = arySharingRules[idx];

                uint256 sharingAmount = totalTxnAmount.mul(rule.ratio).div(
                    1e18
                );
                sharingAmount = Math.min(sharingAmount, tmpTxnAmount);
                if (sharingAmount > 0) {
                    if (txnTokenAddress == address(0)) {
                        payable(rule.clearAddress).transfer(sharingAmount);
                    } else {
                        require(
                            IERC20Metadata(txnTokenAddress).transfer(
                                rule.clearAddress,
                                sharingAmount
                            )
                        );
                    }
                }

                tmpTxnAmount = tmpTxnAmount.sub(sharingAmount);
            }
        }
    }

    function withdraw(
        address tokenAddress,
        address account,
        uint256 amount
    ) public onlyOwner {
        IERC20Metadata(tokenAddress).transfer(account, amount);
    }

    function withdrawBNB(address account, uint256 amount) public onlyOwner {
        payable(account).transfer(amount);
    }

    function giveBack(uint256 offset) public onlyController {
        require(block.timestamp > endTime, "this pool is not end");
        require(position < aryAccounts.length, "all have been give back");

        uint256 totalTxnAmount;
        if (txnTokenAddress == address(0)) {
            totalTxnAmount = address(this).balance;
        } else {
            totalTxnAmount = IERC20Metadata(txnTokenAddress).balanceOf(
                address(this)
            );
        }
        require(totalTxnAmount < softCap, "IDO success not give back");
        uint256 endPosition = Math.min(position + offset, aryAccounts.length);
        for (uint256 idx = position; idx < endPosition; idx++) {
            address account = aryAccounts[idx];
            BuyRecord memory record = mBuyRecords[account];
            uint256 txnAmount = Math.min(record.txnAmount, totalTxnAmount);
            if (txnAmount > 0) {
                if (txnTokenAddress == address(0)) {
                    payable(account).transfer(txnAmount);
                } else {
                    require(
                        IERC20Metadata(txnTokenAddress).transfer(
                            account,
                            txnAmount
                        )
                    );
                }
            }
            totalTxnAmount = totalTxnAmount.sub(txnAmount);
        }
        position = endPosition;
    }

    function setClaimOpen(bool _claimOpen) public onlyController {
        claimOpen = _claimOpen;
    }

    function getClaimOpen() public view returns (bool) {
        return claimOpen;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getPosition() public view returns (uint256) {
        return position;
    }

    function setTxnLimit(
        uint256 _maxTimes,
        uint256 _minAmount,
        uint256 _maxAmount
    ) public onlyController {
        buyLimit.maxTimes = _maxTimes;
        buyLimit.minAmount = _minAmount;
        buyLimit.maxAmount = _maxAmount;
    }

    function checkTxnLimit() public view returns (TxnLimit memory) {
        return buyLimit;
    }

    function setSeniorWhiteList(address _seniorWhiteList)
        public
        onlyController
    {
        seniorWhiteList = _seniorWhiteList;
    }

    function setWhiteListInfo(address _contractAddress, uint256 _expireTime)
        public
        onlyController
    {
        whiteListContract = _contractAddress;
        whiteListExpireTime = _expireTime;
    }

    function checkWhiteListInfo()
        public
        view
        returns (address _contractAddress, uint256 _expireTime)
    {
        _contractAddress = whiteListContract;
        _expireTime = whiteListExpireTime;
    }

    function setReleaseRules(
        uint256[] calldata aryTime,
        uint256[] calldata aryRatio
    ) public onlyController {
        require(aryTime.length == aryRatio.length, "length must be equal");
        uint256 aryLength = aryTime.length;
        uint256 totalReleaseRatio = 0;
        for (uint256 idx = 0; idx < aryLength; idx++) {
            totalReleaseRatio += aryRatio[idx];
        }
        require(totalReleaseRatio == 1e18, "total ratio must be equal to 1e18");
        delete aryReleaseRules;
        for (uint256 idx = 0; idx < aryLength; idx++) {
            ReleaseRule memory _rule = ReleaseRule({
                iTime: aryTime[idx],
                ratio: aryRatio[idx]
            });
            aryReleaseRules.push(_rule);
        }
    }

    function checkReleaseRules() public view returns (ReleaseRule[] memory) {
        return aryReleaseRules;
    }

    function setSharingRules(
        uint256[] calldata aryType,
        address[] calldata aryClearAddress,
        uint256[] calldata aryRatio
    ) public onlyController {
        require(
            aryClearAddress.length == aryType.length,
            "length must be equal"
        );
        require(
            aryRatio.length == aryClearAddress.length,
            "length must be equal"
        );
        uint256 aryLength = aryType.length;
        uint256 totalSharingRatio = 0;
        for (uint256 idx = 0; idx < aryLength; idx++) {
            totalSharingRatio += aryRatio[idx];
        }
        require(totalSharingRatio == 1e18, "total ratio must be equal to 1e18");
        delete arySharingRules;
        for (uint256 idx = 0; idx < aryLength; idx++) {
            SharingRule memory _rule = SharingRule({
                iType: aryType[idx],
                clearAddress: aryClearAddress[idx],
                ratio: aryRatio[idx]
            });
            arySharingRules.push(_rule);
        }
    }

    function checkSharingRules() public view returns (SharingRule[] memory) {
        return arySharingRules;
    }

    function resetEndTime(uint256 _endTime) public onlyController {
        endTime = _endTime;
    }

    function resetSoftCap(uint256 _softCap) public onlyController {
        softCap = _softCap;
    }

    struct BuyRecord {
        uint256 buyTimes;
        uint256 txnAmount;
        uint256 rewards;
        uint256 paidRewards;
    }

    struct ReleaseRule {
        uint256 iTime;
        uint256 ratio;
    }

    struct SharingRule {
        uint256 iType;
        address clearAddress;
        uint256 ratio;
    }

    struct TxnLimit {
        uint256 maxTimes;
        uint256 minAmount;
        uint256 maxAmount;
    }
}
