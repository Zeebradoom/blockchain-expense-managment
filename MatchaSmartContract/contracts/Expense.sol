// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @custom:security-contact derrick_cui@berkeley.edu
contract Expense is
    ERC20,
    ERC20Burnable,
    Pausable,
    Ownable,
    ERC20Permit,
    ERC20Votes,
    ERC20FlashMint
{
    constructor()
        // address usdcAddress
        ERC20("Expense", "EXP")
        ERC20Permit("Expense")
    {
        usdc = IERC20(0xDf0360Ad8C5ccf25095Aa97ee5F2785c8d848620); //Goerli USDC mock
        // usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // Initialize USDC contract
        //TODO CHANGE THIS BEFORE PUTTING ON MAINNET
        // usdc = IERC20(usdcAddress);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    //functionality so anyone can transfer USDC to contract
    using SafeERC20 for IERC20;
    IERC20 public usdc;

    //functionality that allows transfer of USDC to contract
    function fundUSDC(uint _amount) public {
        // amount should be > 0
        require(_amount > 0, "amount should be > 0");

        SafeERC20.safeTransferFrom(usdc, msg.sender, address(this), _amount);
    }

    //functionality that allows exchange of EXP for USDC
    function exchangeEXP(uint _amount) public {
        // amount should be > 0
        require(_amount > 0, "amount should be > 0");

        _transfer(msg.sender, address(this), _amount);

        require(
            usdc.balanceOf(address(this)) >= _amount,
            "Not enough USDC in contract"
        );

        SafeERC20.safeTransfer(usdc, msg.sender, _amount);
        _burn(address(this), _amount);
    }
}
