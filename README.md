# Trigger Framework

This is yet another trigger framework, the reasoning behind it was to remove some of the complexities that other frameworks offered.

The best practice in Salesforce development is to have one trigger per object, but I disagee with this as that then forces developers to include a number of if statements (or maybe a switch statement nowadays) in their "Trigger Handler" which just increased the complexity of the code. So in my opinion developers should limit triggers to 1 per object per action, this removes the need for any if statements as each trigger will already have the context of the trigger based on its definition. My reccomended naming convention for triggers using this pattern would be to name the object and then the specific action, so that any developer looking at the triggers in their IDE will be able to quickly identify what that trigger is being used for (eg OpportunityBeforeInsert).

One other issue that I have seen with other trigger handler frameworks is that they tend to have a trigger handler for each of the objects that require a trigger, but these classes tend to get added to directly rather than having them call into methods. Leading to a bloated trigger handler class that has far more responsability than it originally intended to.

The intention behind this framework is to have a signle entry point for all trigger actions this allows enforcements on all triggers to be easily made. For example on some projects I have used a trigger switch in here, or a call to log all messages stored in a logging class. This entry point I have called the `TriggerHandler`. The basis of the framework is the `Triggerable` interface, any action that a developer wants to perform on some triggered records will need to implement this interface. The 2 methods on this interface are

- `register(SObjectTriggerWrapper)` - this function call will get called for all of the records in the trigger, passing in a wrapper around the sobject, this wrapper contains the old and the new records so that you can check for changes in field values easily. Because of this the records will only be iterated over once, rather than for every peice of code that is added on into the trigger handler.
- `performAction()` - this method will be called after all of the records have been iterated over, this is where you will need to perform any DML / SOQL required to complete the action.

Each trigger that is required would need to add the following method call:

```Java
TriggerHandler.performAllActions(
    new List<Triggerable>{
        new MyTriggerableAction1(),
        new MyTriggerableAction2()
    },
    Trigger.new,
    Trigger.oldMap
);
```

_Note: the order of the triggerable actions passed into the list determines the order they are performed in_

See the directory `force-app/example` for a simple example of the framework being used. Where we have a class that is copying the address down to the contacts when it has changed.
