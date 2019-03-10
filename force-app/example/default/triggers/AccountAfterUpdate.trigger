trigger AccountAfterUpdate on Account (after update) {
    TriggerHandler.performAllActions(
        new List<Triggerable>{
            new AccountAddressSync() 
        }, 
        Trigger.new, 
        Trigger.oldMap
    );
}
