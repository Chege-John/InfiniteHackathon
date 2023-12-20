import Principal "mo:base/Principal";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import List "mo:base/List";

actor {
  type Item = {
    title: Text;
    description: Text;
    image: Blob;
  };

  type Pledge = {
    price: Nat;
    time: Nat;
    originator: Principal.Principal;
  };

  type JamboId = Nat;

  type JamboOverview = {
    id: JamboId;
    item: Item;
  };

  type JamboDetails = {
    item: Item;
    pledgeHistory: [Pledge];
    remainingTime: Nat;
  };

  type Jambo = {
    id: JamboId;
    item: Item;
    var pledgeHistory: List.List<Pledge>;
    var remainingTime: Nat;
  };

  stable var jambos = List.nil<Jambo>();
  stable var idCounter = 0;

  func tick() : async () {
    for (jambo in List.toIter(jambos)) {
      if (jambo.remainingTime > 0) {
        jambo.remainingTime -= 1;
      };
    };
  };

  let timer = Timer.recurringTimer(#seconds 1, tick);

  func newJamboId() : JamboId {
    let id = idCounter;
    idCounter += 1;
    id;
  };

  public func newJambo(item: Item, duration: Nat) : async () {
    let id = newJamboId();
    let pledgeHistory = List.nil<Pledge>();
    let newJambo = { id; item; var pledgeHistory; var remainingTime = duration };
    jambos := List.push(newJambo, jambos);
  };

  public query func getOverviewList() : async [JamboOverview] {
    func getOverview(jambo: Jambo) : JamboOverview = {
      id = jambo.id;
      item = jambo.item;
    };
    let overviewList = List.map<Jambo, JamboOverview>(jambos, getOverview);
    List.toArray(List.reverse(overviewList));
  };

  func findJambo(jamboId: JamboId) : Jambo {
    let result = List.find<Jambo>(jambos, func jambo = jambo.id == jamboId);
    switch (result) {
      case null Debug.trap("Inexistent id");
      case (?jambo) jambo;
    };
  };

  public query func getJamboDetails(jamboId: JamboId) : async JamboDetails {
    let jambo = findJambo(jamboId);
    let pledgeHistory = List.toArray(List.reverse(jambo.pledgeHistory));
    { item = jambo.item; pledgeHistory; remainingTime = jambo.remainingTime };
  };

  func minimumPrice(jambo: Jambo) : Nat {
    switch (jambo.pledgeHistory) {
      case null 1;
      case (?(lastPledge, _)) lastPledge.price + 1;
    };
  };

  public shared (message) func makePledge(jamboId: JamboId, price: Nat) : async () {
    let originator = message.caller;
    if (Principal.isAnonymous(originator)) {
      Debug.trap("Anonymous caller");
    };
    let jambo = findJambo(jamboId);
    if (price < minimumPrice(jambo)) {
      Debug.trap("Price too low");
    };
    let time = jambo.remainingTime;
    if (time == 0) {
      Debug.trap("Jambo closed");
    };
    let newPledge = { price; time; originator };
    jambo.pledgeHistory := List.push(newPledge, jambo.pledgeHistory);

    
  };
};
