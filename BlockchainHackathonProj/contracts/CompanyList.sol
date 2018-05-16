pragma solidity ^0.4.18;

import "./Structs.sol";

contract CompanyList {
    using Structs for Structs.CompanyInfo;
    using Structs for Structs.Location;

    address public admin;
    uint public count_company;
    
    mapping (string => address) companiesFromString;
    mapping (address => Structs.CompanyInfo) companies;
    
    function CompanyList() public {
        admin = msg.sender;
        count_company = 0;
    }
    
    function isValidCompany(address company) public view returns(bool) {
        if(companies[company].isValid != 0) {
            return true;
        }
        return false;
    }
    
    function getCompanyInfo(string company_add_str) public constant returns(string c_name, string c_country, string c_city) {
        address company_add = companiesFromString[company_add_str];
        
        c_name = companies[company_add].name;
        c_country = companies[company_add].location.country;
        c_city = companies[company_add].location.city;
    }
    
    function getCount() public constant returns(uint) {
        return count_company;
    }
    
    modifier onlyOwner() {
        require(admin == msg.sender);
        _;
    }

    function addCompany(string name, address public_key, string country, string city) public onlyOwner  {
        Structs.Location memory l = Structs.Location(country,city);
        Structs.CompanyInfo memory c = Structs.CompanyInfo(name, l, 1);
        companies[public_key] =  c;
        count_company++;
        
        companiesFromString[addressTotring(public_key)] = public_key;
    }  
    
    function removeCompany(address company_add) public onlyOwner {
        delete companies[company_add];
        count_company--;
    }
    
    function addressTotring(address x) private pure returns (string) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }
    
    function char(byte b) private pure returns (byte c) {
        if (b < 10) {
            return byte(uint8(b) + 0x30);
        }
        return byte(uint8(b) + 0x57);
    }
}
