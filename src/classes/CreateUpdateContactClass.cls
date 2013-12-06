public with sharing class CreateUpdateContactClass implements TriggerDispatcher.ITriggerEntry
{
	public void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
		List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
	{
		if (trigger.isInsert)
		{
			ContactBeingInserted (newList);
		}
		else if (trigger.isUpdate)
		{
			ContactBeingUpdated (newList);
		}
	}

	public void ContactBeingInserted (List<Contact> cmList)
	{
		Schema.DescribeFieldResult fieldResult = Contact.MailingStateCode.getDescribe();
		List<Schema.PicklistEntry> counties = fieldResult.getPicklistValues();
		system.debug (counties);

		fieldResult = Contact.MailingCountryCode.getDescribe();
		List<Schema.PicklistEntry> countries = fieldResult.getPicklistValues();
		for (Contact cont: cmList)
		{
			system.debug ('Before Country: ' + cont.MailingCountry);
			system.debug ('Before CountryCode: ' + cont.MailingCountryCode);
			system.debug ('Before State: ' + cont.MailingState);
			system.debug ('Before StateCode: ' + cont.MailingStateCode);
			system.debug ('Before County: ' + cont.County__c);
			if (cont.MailingCountry != null)
			{
				for (Schema.PickListEntry validCountry: countries)
				{
					if (cont.MailingCountry == validCountry.getLabel())
					{
						system.debug ('Country picklist: ' + validCountry);
						cont.MailingCountryCode = validCountry.getValue();
						cont.MailingCountry = validCountry.getLabel();
						system.debug ('Country: ' + cont.MailingCountry);
						system.debug ('CountryCode: ' + cont.MailingCountryCode);
						break;
					}
				}
			}
			if (cont.County__c != null)
			{
				for (Schema.PickListEntry validCounty: counties)
				{
					if (cont.County__c == validCounty.getLabel())
					{
						system.debug ('County picklist: ' + validCounty);
						cont.MailingState = cont.County__c;
						cont.MailingStateCode = validCounty.getValue();
						cont.County__c = '';
						system.debug ('State: ' + cont.MailingState);
						system.debug ('CountryCode: ' + cont.MailingCountryCode);
						break;
					}
				}
				if (cont.County__c != '')
				{
					if (cont.MailingCity == null) cont.MailingCity = cont.County__c;
					else cont.MailingCity += ', ' + cont.County__c;
					cont.County__c = '';
				}
			}
			else if (cont.MailingState != null && cont.MailingStateCode == null)
			{
				for (Schema.PickListEntry validCounty: counties)
				{
					if (cont.MailingState == validCounty.getLabel())
					{
						system.debug ('County picklist in mailing state: ' + validCounty);
						cont.MailingStateCode = validCounty.getValue();
						break;
					}
				}
			}
			system.debug ('After Country: ' + cont.MailingCountry);
			system.debug ('After CountryCode: ' + cont.MailingCountryCode);
			system.debug ('After State: ' + cont.MailingState);
			system.debug ('After StateCode: ' + cont.MailingStateCode);
		}
	}

	public void ContactBeingUpdated (List<Contact> cmList)
	{
		Schema.DescribeFieldResult fieldResult = Contact.MailingStateCode.getDescribe();
		List<Schema.PicklistEntry> counties = fieldResult.getPicklistValues();
		system.debug (counties);

		fieldResult = Contact.MailingCountryCode.getDescribe();
		List<Schema.PicklistEntry> countries = fieldResult.getPicklistValues();
		for (Contact cont: cmList)
		{
			// on an update, the code gets priority - only change the county
			if (cont.County__c != null)
			{
				for (Schema.PickListEntry validCounty: counties)
				{
					if (cont.County__c == validCounty.getLabel())
					{
						system.debug ('County picklist: ' + validCounty);
						cont.MailingState = cont.County__c;
						cont.MailingStateCode = validCounty.getValue();
						cont.County__c = '';
						system.debug ('State: ' + cont.MailingState);
						system.debug ('CountryCode: ' + cont.MailingCountryCode);
						break;
					}
				}
				if (cont.County__c != '')
				{
					if (cont.MailingCity == null) cont.MailingCity = cont.County__c;
					else cont.MailingCity += ', ' + cont.County__c;
					cont.County__c = '';
				}
			}
			system.debug ('After Country: ' + cont.MailingCountry);
			system.debug ('After CountryCode: ' + cont.MailingCountryCode);
			system.debug ('After State: ' + cont.MailingState);
			system.debug ('After StateCode: ' + cont.MailingStateCode);
		}
	}

}