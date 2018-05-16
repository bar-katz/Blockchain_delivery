pragma solidity ^0.4.18;

library Structs {
    
    struct Location {
        string country;
        string city;
    }
    
    struct CompanyInfo {
        string name;
        address public_key;
        Location location;    
    }
    
}