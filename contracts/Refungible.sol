// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Refungible is ERC20{
    uint256 public immutable sharePrice;
    uint256 public immutable totalShares;
    uint256 public endTime;
    address public immutable owner; 
    uint256 public immutable tokenId;
    IERC721 public immutable nft;
    IERC20 public constant TST = IERC20(0x722dd3F80BAC40c951b51BdD28Dd19d435762180); //Ropsten Test Token

    modifier onlyOwner{
        require(msg.sender==owner, "Only the owner can call this function");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint256 _tokenId, address _nft, uint256 _sharePrice, uint256 _totalShares) ERC20(_name, _symbol){
        tokenId = _tokenId;
        nft = IERC721(_nft);
        owner = msg.sender;
        sharePrice = _sharePrice;
        totalShares = _totalShares;
    }
    function startSale() external onlyOwner{
        nft.transferFrom(msg.sender, address(this), tokenId);
        endTime = block.timestamp + 7 days;
    }
    function buyShare(uint256 amount) external{
        require(endTime>block.timestamp, "Sale not active");
        require(totalSupply() + amount <= totalShares, "Not enough shares left");
        uint256 transferAmount = sharePrice * amount; 
        TST.transferFrom(msg.sender, address(this), transferAmount);
        _mint(msg.sender, amount);
    }
    function withdrawShares() external onlyOwner{
        require(block.timestamp>endTime, "Sale still active" );
        uint256 currentBalance = TST.balanceOf(address(this));
        if(currentBalance>0) TST.transfer(owner, currentBalance);
        uint256 unsoldShares = totalShares - totalSupply();
        if(unsoldShares>0) _mint(owner, unsoldShares);
    }
}