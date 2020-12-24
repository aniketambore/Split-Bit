import 'package:ether_spliter/util/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

double billAmount = 0.0;
int personCounter = 1;
TextEditingController billAmountController = TextEditingController();

Client httpClient;
Web3Client ethClient;
final myAddress =
    "Paste Your Meta Mask Address Here"; //Paste Your Meta Mask Address Here
bool data = false;
int myAmount = 0;
var myData;
String hash = "";

class EtherSplitter extends StatefulWidget {
  @override
  _EtherSplitterState createState() => _EtherSplitterState();
}

class _EtherSplitterState extends State<EtherSplitter> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient = Client();
    // Connecting to the RPC Server Via Infura
    // Paste Your Infura Test API EndPoint link
    ethClient =
        Web3Client("Paste Your Infura Test API EndPoint link", httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");

    String contractAddress =
        "Paste the deployed contract address from Remix IDE"; //Paste the deployed contract address from Remix IDE

    final contract = DeployedContract(ContractAbi.fromJson(abi, "SplitCoin"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();

    final ethFunction = contract.function(functionName);

    final result =
        ethClient.call(contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    List<dynamic> result = await query("getBalance", []);

    myData = result[0];
    data = true;
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    // You can create Credentials from private keys
    //Export the meta mask private key and paste here
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "Export the meta mask private key and paste here");

    // Or generate a new key randomly
//    var rng = new Random.secure();
//    Credentials random = EthPrivateKey.createRandom(rng);

    DeployedContract contract = await loadContract();

    final ethFunction = contract.function(functionName);

    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        fetchChainIdFromNetworkId: true);

    return result;
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("depositBalance", [bigAmount]);
    print("Deposited");
    setState(() {
      hash = response;
    });
    return response;
  }

  Future<String> withdrawCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("withdrawBalance", [bigAmount]);
    print("Withdrawn");
    setState(() {
      hash = response;
    });
    return response;
  }

  calculateSplitEther(double billAmount, int splitBy) {
    var totalPerPerson = billAmount / splitBy;
    setState(() {
      myAmount = totalPerPerson.toInt();
    });
    return totalPerPerson.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        alignment: Alignment.center,
        color: Colors.white,
        child: ListView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(20),
          children: [
            statusContainer(),
            interactionContainer(),
            interactionButtonContainer(),
            hash == ""
                ? Text("")
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Hash is ${hash}"),
                  )
          ],
        ),
      ),
    );
  }

  statusContainer() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Balance = ",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    data
                        ? Text(
                            "$myData",
                            style: TextStyle(
                                fontSize: 20.9,
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: CircularProgressIndicator(),
                          ),
                    SizedBox(
                      width: 4,
                    ),
                    Icon(
                      FontAwesomeIcons.bitcoin,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.bitcoin,
                    color: Colors.orange,
                    size: 30,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    "${calculateSplitEther(billAmount, personCounter)}",
                    style: TextStyle(
                        fontSize: 34.9,
                        color: primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  interactionContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
              color: Colors.blueGrey.shade100, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [billAmountInputField(), splitContainer()],
      ),
    );
  }

  interactionButtonContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          FlatButton.icon(
            onPressed: () => getBalance(myAddress),
            icon: Icon(Icons.refresh),
            label: Text(
              "Refresh",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blue,
          ),
          FlatButton.icon(
            onPressed: () {
              myAmount != 0 ? sendCoin() : null;
              setState(() {
                Future.delayed(Duration(seconds: 3), () {
                  billAmount = 0;
                  myAmount = 0;
                  personCounter = 1;
                  billAmountController.clear();
                });
              });
            },
            icon: Icon(Icons.call_made),
            label: Text(
              "Deposit",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.lightGreen,
          ),
          FlatButton.icon(
            onPressed: () {
              myAmount != 0 ? withdrawCoin() : 0;
              setState(() {
                Future.delayed(Duration(seconds: 3), () {
                  billAmount = 0;
                  myAmount = 0;
                  personCounter = 1;
                  billAmountController.clear();
                });
              });
            },
            icon: Icon(Icons.call_received),
            label: Text(
              "Withdraw",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.redAccent,
          )
        ],
      ),
    );
  }

  billAmountInputField() {
    return TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: primaryColor),
      decoration: InputDecoration(
          hintText: "Enter Total Bill Amount",
          //prefixText: "Bill Amount = ",
          prefixIcon: Icon(FontAwesomeIcons.solidMoneyBillAlt)),
      onChanged: (value) {
        try {
          billAmount = double.parse(value);
        } catch (err) {
          billAmount = 0.0;
        }
      },
      controller: billAmountController,
    );
  }

  splitContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Split",
          style: TextStyle(color: Colors.grey.shade700, fontSize: 17),
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (personCounter > 1) {
                    personCounter--;
                  } else {
                    //do nothing
                  }
                });
              },
              child: Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                    color: primaryColor.withOpacity(0.1)),
                child: Center(
                  child: Text(
                    "-",
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
              ),
            ),
            Text(
              "$personCounter",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: primaryColor),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  personCounter++;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                    color: primaryColor.withOpacity(0.1)),
                child: Center(
                  child: Text(
                    "+",
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
