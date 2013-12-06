// this code is not designed for batch updates, because it needs to create donations for some leads
public with sharing class CreateUpdateLeadClass implements TriggerDispatcher.ITriggerEntry
{
	public void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
		List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
	{
		if (trigger.isInsert)
		{
			LeadBeingInserted (newList);
		}
		else if (trigger.isUpdate)
		{
			LeadBeingUpdated (oldMap, newList);
		}
	}

	map <ID, RecordType>recordIDToName;
	private void getRecordTypes ()
	{
		recordIDToName = new map <ID, RecordType> ([select ID, Name from RecordType where sObjectType = 'Lead']);	
	}
	
	public void LeadBeingInserted (List<Lead> cmList)
	{
		if (cmList.size() > 20) return; // this won't work for batch updates

		List<Opportunity>donations = new List<Opportunity>();
		List<npe03__Recurring_Donation__c>recurringDonations = new List<npe03__Recurring_Donation__c>();
		getRecordTypes ();
		for (Lead ld: cmList)
		{
	    	ld.Conversion_Error__c = '';
			RecordType leadType = (RecordType)recordIDToName.get(ld.RecordTypeID);
			if (leadType != null)
			{
				if (leadType.Name == 'Membership')
				{
					Contact cont = CreateOrFindContact (ld, leadType.Name);
					if (cont != null)
					{
						UpdateContactOptions (ld, cont);
						if (isValid (ld.Phone)) cont.Phone = ld.Phone;
						if (isValid (ld.MobilePhone)) cont.MobilePhone = ld.MobilePhone;
						update cont;
					}
				}
				else if (leadType.Name == 'Donation' && isValidDecimal (ld.Donation_amount__c))
				{
					Contact cont = CreateOrFindContact (ld, leadType.Name);
					if (cont != null)
					{
						if (ld.Type_of_donation__c != 'Single Credit/Debit Card') UpdateContactOptions (ld, cont);
						if (isValid (ld.Phone)) cont.Phone = ld.Phone;
						if (isValid (ld.MobilePhone)) cont.MobilePhone = ld.MobilePhone;
						update cont;
						cont = [select ID, AccountID, LastName, FirstName,
							Bank_account_name__c, Bank_account_number__c, Bank_address__c, Bank_name__c, Bank_sort_code__c
							from Contact where ID = :cont.id];
						
						if (ld.Type_of_donation__c == 'Single Credit/Debit Card') donations.add (CreateSingleDonation (ld, cont));
						else if (ld.Type_of_donation__c == 'Regular Credit/Debit Card') recurringDonations.add (CreateRecurringCCDonation (ld, cont));
						else if (ld.Type_of_donation__c == 'Regular Direct Debit') 
						{
							recurringDonations.add (CreateRecurringDDDonation (ld, cont));
							update cont;
						}
						else 
						{
							ld.Status = 'Open - Not Contacted';
							ld.Conversion_Error__c = 'Invalid donation type';
						}
					}
				}
				else if (leadType.Name == 'Shop')
				{
					if (!isValidDecimal (ld.Postage_Packaging__c)) ld.Conversion_Error__c += ' Post and Packaging value invalid';
					else if (!isValid (ld.Description)) ld.Conversion_Error__c += ' List of purchases invalid';
					else
					{
						Contact cont = CreateOrFindContact (ld, leadType.Name);
						if (cont != null)
						{
							if (isValid (ld.Phone)) cont.Phone = ld.Phone;
							if (isValid (ld.MobilePhone)) cont.MobilePhone = ld.MobilePhone;
							if (!CreateShopItems (ld, cont)) ld.Status = 'Open - Not Contacted';
						}
					}
				}
			}
			
		    if (ld.Status.contains('Open'))
		    {
		    	if (!isValid(ld.Email)) ld.Conversion_Error__c += ' Email address invalid ';
	    		if (!isValid(ld.LastName)) ld.Conversion_Error__c += ' Surname invalid';
	    		if (leadType.Name == 'Donation' && !isValidDecimal (ld.Donation_amount__c)) ld.Conversion_Error__c += ' Donation amount invalid';
    		}
		}
		if (donations.size() > 0) insert donations;
		if (recurringDonations.size() > 0) insert recurringDonations;
	}

	public boolean CreateShopItems (Lead ld, Contact cont)
	{
		// first need a map of all the products
		Map<String, ID> productMap = new Map<String, ID>();
		for (Product__c oneProduct: [Select ID, Product_Ref__c from Product__c])
		{
			productMap.put (oneProduct.Product_Ref__c, oneProduct.ID);	
		}
		
		Savepoint sp = Database.setSavepoint();
		try
		{
			Sale__c sale = new Sale__c (Contact__c=cont.id, Date_of_Order__c=system.today(), Phone_number_for_shipping_address__c=ld.Shipping_Phone__c, Shipping_Address__c=ld.Shipping_Address__c);
			sale.Postage_Packaging__c = ld.Postage_Packaging__c;
			insert sale;
			List<Sale_Item__c> items = new List<Sale_Item__c>();
			
			for (Object oneItem: (List<Object>)JSON.deserializeUntyped(ld.Description))
			{
				Map<String, Object> workingItem = (Map<String, Object>)oneItem;
				Sale_Item__c newItem = new Sale_Item__c (Sale_Order__c=sale.id);
				newItem.Product__c = productMap.get ((String)workingItem.get('line_item_label'));
				Decimal quant = Decimal.valueOf((String)workingItem.get('quantity'));
				newItem.Quantity__c = quant>0?quant:1;
				
				items.add (newItem);
			}
			insert items;
			return true;
		}
		catch (Exception e)
		{
			Database.rollback(sp);
			ld.Conversion_Error__c += 'Problem with product list: ';
			ld.Conversion_Error__c += e.getMessage().left(150);
		}
		return false;
	}

	public Opportunity CreateSingleDonation (Lead ld, Contact cont)
	{
		Opportunity donation = new Opportunity (CloseDate=system.today(), StageName='Pledged', Amount=ld.Donation_Amount__c);
   		donation.Name = cont.FirstName + ' ' + cont.LastName + ' - Donation ' + system.today().format();
   		donation.AccountID = cont.AccountID;
   		if (isValid (ld.What_prompted_donation__c)) donation.What_prompted_donation__c = ld.What_prompted_donation__c;
		return donation;
	}
	
	public npe03__Recurring_Donation__c CreateRecurringCCDonation (Lead ld, Contact cont)
	{
		npe03__Recurring_Donation__c donation = CreateRecurringDonation (ld, cont);
		donation.Name = cont.FirstName + ' ' + cont.LastName + ' - Credit/Debit Card';
		return donation;
	}
	
	public npe03__Recurring_Donation__c CreateRecurringDonation (Lead ld, Contact cont)
	{
		npe03__Recurring_Donation__c donation = new npe03__Recurring_Donation__c (npe03__Contact__c=cont.id, npe03__Open_Ended_Status__c='Open', npe03__Amount__c=ld.Donation_amount__c);
		donation.npe03__Date_Established__c = system.today();
		donation.npe03__Next_Payment_Date__c = ld.Donation_start_date__c;
		donation.npe03__Installment_Period__c = 'Monthly';
		donation.npe03__Schedule_Type__c = 'Multiply By';
   		if (isValid (ld.What_prompted_donation__c)) donation.What_prompted_donation__c = ld.What_prompted_donation__c;
		return donation;
	}

	public npe03__Recurring_Donation__c CreateRecurringDDDonation (Lead ld, Contact cont)
	{
		npe03__Recurring_Donation__c donation = CreateRecurringDonation (ld, cont);
		donation.Name = cont.FirstName + ' ' + cont.LastName + ' - Direct Debit';
		
		// copy bank details
		cont.Bank_account_name__c = isValid (ld.Name_of_bank_account__c)?ld.Name_of_bank_account__c:'';
		cont.Bank_account_number__c = isValid (ld.Bank_account_number__c)?ld.Bank_account_number__c:'';
		cont.Bank_address__c = isValid (ld.Bank_address__c)?ld.Bank_address__c:'';
		cont.Bank_name__c = isValid (ld.Bank_name__c)?ld.Bank_name__c:'';
		cont.Bank_sort_code__c = isValid (ld.Bank_account_number__c)?ld.Bank_sort_code__c:'';
		return donation;
	}
	
	public Contact CreateOrFindContact (Lead ld, String leadType)
	{
   		system.debug ('Lead country: ' + ld.Country + ' Lead country code: ' + ld.CountryCode);
		Contact returnContact=null;
	   	if (isValid(ld.Email) && isValid(ld.LastName) && ld.Status.contains('Open'))
	   	{
	   		List <Contact> existingContacts = new List<Contact>();
	   		if (isValid(ld.Payer_Ref__c)) existingContacts = [select Id from Contact where (EMail = :ld.Email and LastName=:ld.LastName) or Payer_Ref__c = :ld.Payer_Ref__c];
	   		else 
	   		{
	   			if (isValid (ld.MobilePhone)) existingContacts = [select Id from Contact where (MobilePhone = :ld.MobilePhone and LastName=:ld.LastName)];
	   			if (existingContacts.size() == 0) existingContacts = [select Id from Contact where (EMail = :ld.Email and LastName=:ld.LastName)];
	   		}
				   		
			try
			{
		   		if (existingContacts.size() > 0) returnContact = updateMember (existingContacts[0], ld);
		   		else returnContact = createMember (ld, leadType);
	   			ld.Status = 'Closed - Converted';
			}
			catch (Exception e)
			{
				ld.Conversion_Error__c = e.getMessage().left(250);
			}
	   	}
	   	return returnContact;
	}
	
	public void LeadBeingUpdated (Map<ID, sObject> oldCMMap, List<Lead> cmList)
	{
		LeadBeingInserted (cmList);
	}
	
	public Contact createMember (Lead newLead, String leadType)
	{
		Contact newContact = new Contact (FirstName = isValid (newLead.FirstName)?newLead.FirstName:'',
			LastName=newLead.LastName, Email=newLead.Email,
			MailingStreet=isValid(newLead.Street)?newLead.Street:'',
			MailingCity=isValid(newLead.City)?newLead.City:'',
			MailingState=isValid(newLead.State)?newLead.State:'',
			MailingPostalCode=isValid(newLead.PostalCode)?newLead.PostalCode:'',
			MailingCountryCode=isValid(newLead.CountryCode)?newLead.CountryCode:'',
			Payer_Ref__c=isValid(newLead.Payer_Ref__c)?newLead.Payer_Ref__c:'',
			Receives_ezine__c=newLead.Sign_up_to_newsletter__c,
			Salutation = isValid(newLead.Salutation)?newLead.Salutation:'',
			County__c = isValid(newLead.County__c)?newLead.County__c:'',
			Gender__c = isValid(newLead.Gender__c)?newLead.Gender__c:'',
			Source__c = 'Web');
		
		// if creating a contact for membership, then set to ordinary member, else non-member
		if (leadType == 'Membership') newContact.Member_Type__c = 'Ordinary Member';
		else newContact.Member_Type__c = 'Non member';
		
		system.debug ('Lead Country: ' + newLead.Country);
		system.debug ('Contact Country: ' + newContact.MailingCountry);
		system.debug ('Lead Country code: ' + newLead.CountryCode);
		system.debug ('Contact Country code: ' + newContact.MailingCountryCode);
		insert newContact;	
		return newContact;
	}

	public void	UpdateContactOptions (Lead ld, Contact cont)
	{
		cont.Post_Opt_Out__c = !ld.Contact_by_post__c;
		cont.HasOptedOutOfEmail = !ld.Contact_by_email__c;
		cont.Landline_Opt_Out__c = !ld.Contact_by_phone__c;
		cont.Mobile_Opt_Out__c = !ld.Contact_by_phone__c;
		cont.SMS_Opt_Out__c = !ld.Contact_by_SMS__c;
	}

	public void copyLandLineOrMobile (Lead ld, Contact cont)
	{
		if (isValid (ld.Phone))
		{
			String phone = ld.Phone.deleteWhitespace();
			if (phone.startsWith('08') || phone.startsWith('003538') || phone.startsWith('+3538'))
				cont.MobilePhone = phone;
			else cont.Phone = phone;
		}
	}
	
	public Contact updateMember (Contact existingContact, Lead updatedLead)
	{
		if (isValid (updatedLead.FirstName)) existingContact.FirstName = updatedLead.FirstName;
		if (isValid(updatedLead.Street)) existingContact.MailingStreet = updatedLead.Street;
		if (isValid(updatedLead.City))	existingContact.MailingCity = updatedLead.City;
		if (isValid(updatedLead.State))	existingContact.MailingState = updatedLead.State;
		if (isValid(updatedLead.PostalCode)) existingContact.MailingPostalCode = updatedLead.PostalCode;
		if (isValid(updatedLead.CountryCode)) existingContact.MailingCountryCode = updatedLead.CountryCode;
		if (isValid(updatedLead.Payer_Ref__c)) existingContact.Payer_Ref__c = updatedLead.Payer_Ref__c;
		existingContact.Receives_ezine__c = updatedLead.Sign_up_to_newsletter__c;
		if (isValid(updatedLead.Title)) existingContact.Title = updatedLead.Title;
		if (isValid(updatedLead.County__c)) existingContact.County__c = updatedLead.County__c;
		
		update existingContact;	
		return existingContact;
	}
	
	public static boolean isValid (String text)
	{
		if (text <> null && text <> '' && text <> '[not provided]') return true;
		else return false;
	}

	public static boolean isValidDecimal (Decimal text)
	{
		if (text <> null) return true;
		else return false;
	}

}