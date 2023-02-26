// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract CollateralizedLoan is ERC721Holder {

    struct Loan {
        address borrower;
        uint256 amount;
        uint256 interestRate;
        uint256 dueDate;
        bool funded;
    }

    IERC721 public erc721Token;
    mapping (uint256 => Loan) public loans;
    uint256 public loanCounter;
    address public taxWallet;

    event LoanRequested(uint256 loanId, address borrower, uint256 amount, uint256 interestRate, uint256 dueDate);
    event LoanFunded(uint256 loanId, address lender, uint256 amount, uint256 fee);
    event LoanRepaid(uint256 loanId, address borrower, uint256 amount, uint256 interest);
    event LoanDefaulted(uint256 loanId, address lender, address borrower);

    constructor(address _erc721Token, address _taxWallet) {
        erc721Token = IERC721(_erc721Token);
        taxWallet = _taxWallet;
        loanCounter = 0;
    }

    function requestLoan(uint256 _tokenId, uint256 _amount, uint256 _interestRate, uint256 _dueDate) external {
        require(erc721Token.ownerOf(_tokenId) == msg.sender, "You do not own this token");
        require(erc721Token.getApproved(_tokenId) == address(this), "Contract is not approved to transfer token");
        erc721Token.safeTransferFrom(msg.sender, address(this), _tokenId);

        uint256 loanId = loanCounter++;
        loans[loanId] = Loan({
            borrower: msg.sender,
            amount: _amount,
            interestRate: _interestRate,
            dueDate: _dueDate,
            funded: false
        });

        emit LoanRequested(loanId, msg.sender, _amount, _interestRate, _dueDate);
    }

    function fundLoan(uint256 _loanId) external payable {
        Loan storage loan = loans[_loanId];
        require(loan.funded == false, "Loan already funded");
        require(msg.value == loan.amount, "Amount funded does not match loan amount");

        uint256 fee = loan.amount / 100;
        uint256 amountToLender = loan.amount - fee;
        loan.funded = true;
        erc721Token.safeTransferFrom(address(this), msg.sender, _loanId);
        payable(taxWallet).transfer(fee);
        payable(loan.borrower).transfer(amountToLender);

        emit LoanFunded(_loanId, msg.sender, msg.value, fee);
    }

    function repayLoan(uint256 _loanId) external payable {
        Loan storage loan = loans[_loanId];
        require(loan.funded == true, "Loan not yet funded");
        require(msg.sender == loan.borrower, "You are not the borrower");
        require(msg.value == loan.amount + (loan.amount * loan.interestRate / 100), "Amount repaid does not match loan amount plus interest");

        uint256 interest = loan.amount * loan.interestRate / 100;
        payable(msg.sender).transfer(interest);
        payable(loan.borrower).transfer(loan.amount);

        delete loans[_loanId];

        emit LoanRepaid(_loanId, msg.sender, loan.amount, interest);
    }

    function defaultLoan(uint256 _loanId) external {
        Loan storage loan = loans[_loanId];
        require(block.timestamp >= loan.dueDate, "Loan has not yet matured");
        require(loan.funded == true, "Loan not yet funded");

        erc721Token.safeTransferFrom(address(this), msg.sender, _loanId);

        delete loans[_loanId];

        emit LoanDefaulted(_loanId, msg.sender, loan.borrower);
    }

    function withdrawToken(uint256 _tokenId) external {
        require(erc721Token.ownerOf(_tokenId) == address(this), "Token not held by contract");
        erc721Token.safeTransferFrom(address(this), msg.sender, _tokenId);
    }
}
