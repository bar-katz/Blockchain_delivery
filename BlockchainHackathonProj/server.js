
var config = require('./config');

var Web3 = require('web3');

function createContract(buyerAddress) {
  var parcelContract = web3.eth.contract(config.delivery_json);
  var parcel = parcelContract.at(config.delivery_contract);
  return parcel;
}

function getDeliveryInfo() {
  var parcelContract = web3.eth.contract(config.delivery_json);
  var parcel = parcelContract.at(config.delivery_contract);
  var list_str = parcel.getDeliveryCompanies.call();

  var company_list = getCompanyList();
  var overall = "";

  var split_by_obj = list_str.split(';');
  var size = split_by_obj.length - 1;
  var i = 0;
  for(i = 0; i < size; i++) {
    var props = split_by_obj[i].split(',');

    if(i != 0) {
      var company_info = company_list.getCompanyInfo.call(props[0]);

      overall = overall.concat(company_info[0], ", ", company_info[1], ", ", company_info[2]);
      overall = overall.concat(" ; Description: ", props[1]);
      overall = overall.concat("----->");
    }
    if(i == 0) {
      overall = overall.concat("Seller, Description: ");
      overall = overall.concat(props[1]);
      overall = overall.concat("----->");
      continue;
    }
  }

  return overall;
}

async function RequestTransfer(my_address, description) {
  var parcelContract = web3.eth.contract(config.delivery_json);
  var parcel = parcelContract.at(config.delivery_contract);
  var company_list = getCompanyList();
  
  web3.eth.defaultAccount = my_address;
  return await parcel.requestDelivery.sendTransaction(description);
}

async function ConfirmTransfer(my_address) {
  var parcelContract = web3.eth.contract(config.delivery_json);
  var parcel = parcelContract.at(config.delivery_contract);

  web3.eth.defaultAccount = my_address;
  await parcel.currentToNext.sendTransaction();
}

function getCompanyList() {
  var companyListContract = web3.eth.contract(config.companies_list_json);
  var companyList = companyListContract.at(config.companies_list_contract);
  return companyList;
}

var CommandEnum = {
  "CreateContract": 1, "GetInfo": 2,
  "RequestTransfer": 3, "ConfirmTransfer": 4
};
Object.freeze(CommandEnum);

// ----------------- WEB3
if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
} else {
  // set the provider you want from Web3.providers
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
}
web3.eth.defaultAccount = web3.eth.accounts[0];

var delivery_address;

var http = require('http');
var url = require('url');
const express = require('express');


var bodyParser = require('body-parser');

const app = express();
// parse application/json
app.use(bodyParser.json());

app.post('/', async function(req, res) {
        // TODO Parse JSON get parameters
        var command = req.body.command;
        var args = [req.body.args.first, req.body.args.second];

        if(command == 1) {
          web3.eth.defaultAccount = args[0];
          var deliveryInfo = createContract(args[1]);
          res.send([{body : deliveryInfo.address}]);
        } else if (command == 2) {
          web3.eth.defaultAccount = args[0];
          var deliveryInfo = getDeliveryInfo();
          res.send([{body : deliveryInfo}]);
        } else if (command == 3) {
          web3.eth.defaultAccount = args[0];
          var feedback = RequestTransfer(args[0], args[1]);
          res.send([{body : feedback}]);
        } else if (command == 4) {
          web3.eth.defaultAccount = args[0];
          ConfirmTransfer();
        }
        
    });
app.listen(8080, function(){});
