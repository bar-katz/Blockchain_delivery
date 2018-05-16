pragma solidity ^0.4.18;

import "./strings.sol";

contract DeliveryContract {
    using strings for *;
    
    address public seller;
    address public buyer;
    
    enum ContractState { active, inactive }
    ContractState public contract_state;
    
    string public package_state;
    
    string public company_status;
    string private temp_company;
    uint status_size;
    
    address public current_company;
    address public request_company;
    
    bool private is_request_transfer;
    
    function DeliveryContract(address endPointAddress) public {
        buyer = endPointAddress;
        seller = msg.sender;
        current_company = seller;
        contract_state = ContractState.active;
        package_state = "Intact";
        
        is_request_transfer = false;
        
        // add seller to string
        // example "'seller address','package state';"
        status_size = 1;
        temp_company = strings.concat(
            strings.toSlice(addressTotring(seller)), strings.toSlice(","));
        temp_company = strings.concat(
            strings.toSlice(temp_company), strings.toSlice(package_state));
        company_status = strings.concat(
            strings.toSlice(temp_company), strings.toSlice(";"));
    }
    
    modifier sellerOnly {
        require (msg.sender == seller);
        _;
    }
    
    modifier buyerOnly {
        require (msg.sender == buyer);
        _;
    }
    
    modifier isNotBuyer {
        require (msg.sender != buyer);
        _;
    }
    
    modifier isActive {
        require (contract_state == ContractState.active);
        _;
    }
    
    modifier isCurrent {
        require (current_company == msg.sender);
        _;
    }
    
    modifier isNotCurrent {
        require (current_company != msg.sender);
        _;
    }
    
    modifier isNotRequest {
        require(is_request_transfer == false);
        _;
    }
    
    modifier isRequest {
        require(is_request_transfer == true);
        _;
    }
    
    function requestDelivery(string description) public
    isActive isNotRequest isNotCurrent returns(string) {
        request_company = msg.sender;
        package_state = description;
        is_request_transfer = true;
        
        return addressTotring(current_company);
    }
    
    function requestFlush() public isActive isRequest isCurrent {
        request_company = 0x0;
        is_request_transfer = false;
    }
    
    function currentToNext() public isActive isCurrent isRequest
    isNotBuyer {
        if(request_company != buyer) {
            current_company = request_company;
            
            // add company to string
            status_size += 1;
            temp_company = strings.concat(
                strings.toSlice(addressTotring(current_company)), strings.toSlice(","));
            temp_company = strings.concat(
                strings.toSlice(temp_company), strings.toSlice(package_state));
            temp_company = strings.concat(
                strings.toSlice(temp_company), strings.toSlice(";"));
            company_status = strings.concat(
                strings.toSlice(company_status), strings.toSlice(temp_company));
                
            request_company = 0x0;
            package_state = "";
            is_request_transfer = false;
        } else {
            buyerReceived();
        }
        
    }
    
    function buyerReceived() private {
        
        current_company = buyer;
        
        temp_company = strings.concat(
            strings.toSlice(addressTotring(current_company)), strings.toSlice(","));
        temp_company = strings.concat(
            strings.toSlice(temp_company), strings.toSlice(package_state));
        temp_company = strings.concat(
            strings.toSlice(temp_company), strings.toSlice(";"));
        company_status = strings.concat(
            strings.toSlice(company_status), strings.toSlice(temp_company));
            
        contract_state = ContractState.inactive;  
        request_company = 0x0;
        package_state = "";
    }
    
    function getDeliveryCompanies() public returns(string) {
        return company_status;
    }
    
    function addressTotring(address x) private returns (string) {
        if(x == seller) {
            return "Seller";
        }
        if(x == buyer) {
            return "Buyer";
        }
        
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
    
    function isBuyer(address x) public returns(bool) {
        return (strings.compare(addressTotring(buyer).toSlice(),
                                addressTotring(x).toSlice()) == 0);
    }
    
    function char(byte b) private pure returns (byte c) {
        if (b < 10) {
            return byte(uint8(b) + 0x30);
        }
        return byte(uint8(b) + 0x57);
    }
}
