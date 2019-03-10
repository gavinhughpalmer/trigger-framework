public without sharing class AccountAddressSync implements Triggerable {

    private static final String ACCOUNT_ERROR = 'An error has occured syncing the address with related contacts';

    private final Map<Id, Account> accountsWithAddressesToCopy = new Map<Id, Account>();

    public void register(SObjectTriggerWrapper modifiedAccount) {
        if (modifiedAccount.hasChanged('BillingStreet') || modifiedAccount.hasChanged('BillingPostalCode')) {
            final Account accountRecord = (Account) modifiedAccount.getSObject();
            accountsWithAddressesToCopy.put(accountRecord.Id, accountRecord);
        }
    }

    public void performAction() {
        if (!accountsWithAddressesToCopy.isEmpty()) {
            final List<Contact> contactsToUpdate = [
                SELECT AccountId, MailingStreet, MailingPostalCode
                FROM Contact
                WHERE AccountId IN :accountsWithAddressesToCopy.keySet()
            ];
            for (Contact contactToUpdate : contactsToUpdate) {
                Account parentAccount = accountsWithAddressesToCopy.get(contactToUpdate.AccountId);
                contactToUpdate.MailingStreet = parentAccount.BillingStreet;
                contactToUpdate.MailingPostalCode = parentAccount.BillingPostalCode;
            }

            List<Database.SaveResult> updateResults = Database.update(contactsToUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                if (!updateResults[i].isSuccess()) {
                    final Id failedAccountId = contactsToUpdate[i].AccountId;
                    accountsWithAddressesToCopy.get(failedAccountId).addError(ACCOUNT_ERROR);
                }
            }
        }
    }
}