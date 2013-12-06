/*

Author: Eamon Kelly, Enclude

Purpose: When a fundraising object is created, set the organisation to the org of the contact

Called from: Before Insert Trigger 

*/
public with sharing class CreateUpdateFundraisingClass implements TriggerDispatcher.ITriggerEntry
{
	public void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
		List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
	{
		if (trigger.isInsert)
		{
			FundRaisingBeingInserted (newList);
		}
	}

	// if the Organisation__c is empty, then fill in the Organisation__c field with the org of the contact
	// since Contact__c is the master, it cannot be empty
	public void FundRaisingBeingInserted (List<Fundraising__c> frList)
	{
		map <ID, Fundraising__c> contactsToFund = new map <ID, Fundraising__c>();
		for (Fundraising__c fund: frList)
		{
			if (fund.Organisation__c == null) contactsToFund.put (fund.Contact__c, fund);
		}
		if (contactsToFund.size() > 0)
		{
			List <Contact>contactsWithOrg = [select ID, AccountID from Contact where ID in :contactsToFund.KeySet()];
			for (Contact oneC: contactsWithOrg)
			{
				ID orgID = oneC.AccountId;
				Fundraising__c oneFund = contactsToFund.get (oneC.ID);
				oneFund.Organisation__c = orgID;
			}
		}
	}
}