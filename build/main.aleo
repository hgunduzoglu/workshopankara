program hgunduzoglu.aleo {
  mapping account:address => u64;
  record lolipop {
    owner: adress,
    amount: u64
  }

  transition mint_public(public receiver:address, public amount:u64){
    return then finalize(receiver,amount);
  }

  finalize mint_public(public receiver:address, public amount:u64){
    let receiver_amount:u64 = Mapping::get_or_use(account,receiver, 0u64);
    Mapping::set(account,receiver, receiver_amount);

  }
  transition mint_private(receiver:address, amount:u64) -> lolipop {
    return lolipop{
      owner: receiver,
      amount: amount,
    };
  }
  
  transition transfer_public(public receiver:address, public amount:u64){
    return then finalize(self.caller, receiver, amount);
  }
  finalize transfer_public(public sender:address, public receiver:address, public amount:u64){
    let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64);
    Mapping::set(account, sender, sender_amount - amount);

    let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
    Mapping::set(account,receiver, receiver_amount + amount);
  }
  transition transfer_private(sender:lolipop, receiver:address, amount:u64) -> (lolipop, lolipop) {
    let difference:u64 = sender.amount - amount;

    let remaining:lolipop = lolipop {
      owner:sender.owner,
      amount:difference
    };

    let transferred:lolipop = lolipop {
      owner: receiver,
      amount: amount
    };
    return(remanining, transferred);
  }

  transition transfer_private_to_public(sender:lolipop, public receiver:address, public amount:u64) -> lolipop{
    let difference:u64 = sender.amount - amount;
    let remaining:lolipop = lolipop {
      owner: sender.owner,
      amount:difference
    };

    return remaining then finalize(receiver, amount);

  }
  
  finalize transfer_private_to_public(public receiver:address, public amount:u64) {
    let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
    Mapping::set(account, receiver, receiver_amount + amount);
  }
  
  transition transfer_public_to_private(receiver:address, amount:u64) -> lolipop {
    let transferred:lolipop = lolipop{
      owner:receiver,
      amount: amount
    };
    return transferred then finalize(self.caller, amount);
  }
  finalize transfer_public_to_private(public sender:address, public amount:u64) {
    let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64);
    Mapping::set(account, sender, sender_amount - amount);
  }

  
}
