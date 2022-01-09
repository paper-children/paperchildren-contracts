// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../openzeppelin/contracts/utils/Context.sol";
import "../openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IPaperChildrenV1.sol";

contract SaleV1 is Context {
	using SafeMath for uint256;

	IPaperChildrenV1 public PaperChildrenContract;
	uint256 PRICE = 50000000000000000000; //50 klay
	uint256 MAX_NFT_SUPPLY = 1003;
	bool public isSale = false;
	address public devAddress;
	address public C1;
	address public C2;

	mapping(address => bool) public buyerList;

	modifier onlyCreator() {
		require(devAddress == _msgSender(), "onlyCreator: caller is not the creator");
		_;
	}

	modifier saleRole() {
		require(isSale, "The free sale has not started.");
		require(PaperChildrenContract.totalSupply() < MAX_NFT_SUPPLY, "Sale has already ended.");
		require(buyerList[_msgSender()] == false, "Public sale can participate only once.");
		require(PRICE <= msg.value, "KLAY value sent is not correct");
		_;
	}

	constructor(
		address v1Contract,
		address _C1,
		address _C2,
		address _dev
	) {
		PaperChildrenContract = IPaperChildrenV1(v1Contract);
		C1 = _C1;
		C2 = _C2;
		devAddress = _dev;
	}

	function publicSale() public payable saleRole {
		PaperChildrenContract.mint(_msgSender());
		buyerList[_msgSender()] = true;
	}

	function preMint(address _to) public payable onlyCreator {
		PaperChildrenContract.mint(_to);
	}

	function withdraw() public payable onlyCreator {
		uint256 contractBalance = address(this).balance;
		uint256 percentage = contractBalance / 100;

		require(payable(C1).send(percentage * 33));
		require(payable(C2).send(percentage * 67));
	}

	function setDevAddress(address changeAddress) public onlyCreator {
		devAddress = changeAddress;
	}

	function setC1(address changeAddress) public onlyCreator {
		C1 = changeAddress;
	}

	function setC2(address changeAddress) public onlyCreator {
		C2 = changeAddress;
	}

	function setSale() public onlyCreator {
		isSale = !isSale;
	}
}
