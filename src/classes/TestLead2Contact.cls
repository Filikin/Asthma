@isTest
private class TestLead2Contact 
{
/*	static testMethod void ConvertLeadToContactWithInvalidCountyTest()
    {
    	Lead[] leadsbefore = [select ID, Name from Lead];

		ID membershipRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Membership'].id;
    	Lead testLead = new Lead (Salutation='Mr.', FirstName = 'Test', LastName = 'Testing123', Company = 'Self', EMail = 'test@test123.com', Status='Open - not converted', Phone='08654323', RecordTypeID=membershipRecordType);
    	testLead.Country = 'France';
    	testLead.County__c = 'Paris';
    	insert testLead;
    	
    	Lead[] leadsafter = [select ID, Name from Lead];
    	System.Assert (leadsafter.size() > leadsbefore.size());
    	
    	Contact createdContact = [select County__c, MailingCity, Salutation, FirstName, Email, MobilePhone, AccountID from Contact where email=:testLead.Email limit 1];
    	System.AssertEquals (createdContact.FirstName, testLead.FirstName);
      	System.AssertEquals ('08654323', createdContact.MobilePhone);
      	System.AssertEquals ('Mr.', createdContact.Salutation);
      	System.Assert (createdContact.MailingCity.contains ('Paris'));
   	
	   	Lead testLead2 = new Lead (FirstName = 'Test', LastName = 'Testing124', Company = 'TestAccount', EMail = 'test@test124.com', Status='Open - not converted', RecordTypeID=membershipRecordType, Phone='2344');
    	insert testLead2;
      	Contact createdContact2 = [select FirstName, Email, MobilePhone from Contact where email=:testLead2.Email limit 1];
  	
     	System.AssertEquals (createdContact2.FirstName, testLead2.FirstName);
    }
 
	static testMethod void ConvertLeadToContactWithConfusedCountyTest()
    {
    	Lead[] leadsbefore = [select ID, Name from Lead];

		ID membershipRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Membership'].id;
    	Lead testLead = new Lead (Salutation='Mr.', FirstName = 'Test', LastName = 'Testing123', Company = 'Self', EMail = 'test@test123.com', Status='Open - not converted', Phone='08654323', RecordTypeID=membershipRecordType);
    	testLead.Country = 'United Kingdom';
    	testLead.County__c = 'Derry';
    	insert testLead;
    	
    	Lead[] leadsafter = [select ID, Name from Lead];
    	System.Assert (leadsafter.size() > leadsbefore.size());
    	
    	Contact createdContact = [select County__c, MailingState, Salutation, FirstName, Email, MobilePhone, AccountID from Contact where email=:testLead.Email limit 1];
      	System.AssertEquals ('Derry', createdContact.MailingState);
   }
  
	static testMethod void ConvertLeadToContactWithValidCountyTest()
    {
    	Lead[] leadsbefore = [select ID, Name from Lead];

		ID membershipRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Membership'].id;
    	Lead testLead = new Lead (Salutation='Mr.', FirstName = 'Test', LastName = 'Testing123', Company = 'Self', EMail = 'test@test123.com', Status='Open - not converted', Phone='08654323', RecordTypeID=membershipRecordType);
    	testLead.Country = 'Ireland';
    	testLead.County__c = 'County Cork';
    	insert testLead;
    	
    	Lead[] leadsafter = [select ID, Name from Lead];
    	System.Assert (leadsafter.size() > leadsbefore.size());
    	
    	Contact createdContact = [select County__c, MailingState, Salutation, FirstName, Email, MobilePhone, AccountID from Contact where email=:testLead.Email limit 1];
    	System.AssertEquals (createdContact.FirstName, testLead.FirstName);
      	System.AssertEquals ('08654323', createdContact.MobilePhone);
      	System.AssertEquals ('Mr.', createdContact.Salutation);
//      	System.AssertEquals ('Cork', createdContact.MailingState);
   	
	   	Lead testLead2 = new Lead (FirstName = 'Test', LastName = 'Testing124', Company = 'TestAccount', EMail = 'test@test124.com', Status='Open - not converted', RecordTypeID=membershipRecordType, Phone='2344');
    	insert testLead2;
      	Contact createdContact2 = [select FirstName, Email, MobilePhone from Contact where email=:testLead2.Email limit 1];
  	
     	System.AssertEquals (createdContact2.FirstName, testLead2.FirstName);
    }
 */   
	static testMethod void ConvertLeadToContactTest()
    {
    	Lead[] leadsbefore = [select ID, Name from Lead];

		ID membershipRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Membership'].id;
    	Lead testLead = new Lead (Salutation='Mr.', FirstName = 'Test', LastName = 'Testing123', Company = 'Self', EMail = 'test@test123.com', Status='Open - not converted', MobilePhone='08654323', RecordTypeID=membershipRecordType);
    	insert testLead;
    	
    	Lead[] leadsafter = [select ID, Name from Lead];
    	System.Assert (leadsafter.size() > leadsbefore.size());
    	
    	Contact createdContact = [select Salutation, FirstName, Email, MobilePhone, AccountID from Contact where email=:testLead.Email limit 1];
    	System.AssertEquals (createdContact.FirstName, testLead.FirstName);
      	System.AssertEquals ('08654323', createdContact.MobilePhone);
      	System.AssertEquals ('Mr.', createdContact.Salutation);
   	
	   	Lead testLead2 = new Lead (FirstName = 'Test', LastName = 'Testing124', Company = 'TestAccount', EMail = 'test@test124.com', Status='Open - not converted', RecordTypeID=membershipRecordType, Phone='2344');
    	insert testLead2;
      	Contact createdContact2 = [select FirstName, Email, MobilePhone from Contact where email=:testLead2.Email limit 1];
  	
     	System.AssertEquals (createdContact2.FirstName, testLead2.FirstName);
    }
    
	static testMethod void ConvertLeadToContactTestWithContactPresent()
    {
    	Contact currentContact = new Contact (FirstName = 'Test', LastName = 'Testing123', EMail = 'test@test123.com');
    	insert currentContact;
    	
    	Lead[] leadsbefore = [select ID, Name from Lead];

		ID membershipRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Membership'].id;
    	Lead testLead = new Lead (FirstName = 'Test', LastName = 'Testing123', Company = 'TestAccount', EMail = 'test@test123.com', Status='Open - not converted', RecordTypeID=membershipRecordType);
 		testLead.Phone = '+3538500123';
    	insert testLead;
    	
    	Lead[] leadsafter = [select ID, Name from Lead];
    	System.Assert (leadsafter.size() > leadsbefore.size());
    	
    	Contact createdContact = [select FirstName, Email, AccountID from Contact where email=:testLead.Email limit 1];
    	System.AssertEquals (createdContact.FirstName, testLead.FirstName);
    	System.AssertEquals (currentContact.id, createdContact.id);
    	
	   	Lead testLead2 = new Lead (FirstName = 'Test', LastName = 'Testing124', Company = 'TestAccount', EMail = 'test@test124.com', Status='Open - not converted', RecordTypeID=membershipRecordType, Phone='+35386033333');
    	insert testLead2;
      	Contact createdContact2 = [select FirstName, Email from Contact where email=:testLead2.Email limit 1];
  	
     	System.AssertEquals (createdContact2.FirstName, testLead2.FirstName);
    }

 	static testMethod void UpdateLeadTest()
    {
     	Campaign camp = new Campaign (Name='Test');
    	insert camp;
		ID membershipRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Membership'].id;
  	 	Lead testLead = new Lead (FirstName = 'Test', LastName = 'Testing123', Company = 'TestAccount', Status='Open - not converted', RecordTypeID=membershipRecordType);
    	insert testLead;
    	CampaignMember cm = new CampaignMember (CampaignID=camp.id, LeadId=testLead.id);
    	insert cm;

		testLead.Email = 'test@test123.com';
		testLead.Phone = '+3538500123';
		update testLead;
		    	
		cm.Status = 'Responded';
		update cm;
		
     	Contact createdContact = [select ID, FirstName, LastName, Email, AccountID from Contact where email=:testLead.Email limit 1];
	   	System.AssertEquals (createdContact.FirstName, testLead.FirstName);
	/*	
		List <CampaignMember> cmList = [select ID from CampaignMember where ContactID=:createdContact.ID limit 1];
		system.assertEquals (1, cmList.size());

		List <CampaignMember> cmListLead = [select ID from CampaignMember where LeadID=:testLead.ID limit 1];
		system.assertEquals (0, cmListLead.size());
    	*/
    }
    
    static testMethod void DonationTest()
    {
		ID donationRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Donation'].id;
    	Lead testLead = new Lead (FirstName = 'Test', LastName = 'Testing123', Company = 'TestAccount', EMail = 'test@test123.com', Status='Open - not converted', Donation_Amount__c=10, What_prompted_donation__c='Have asthma');
    	testLead.RecordTypeID=donationRecordType;
    	testLead.Type_of_donation__c = 'Single Credit/Debit Card';
    	testLead.Contact_by_phone__c = false;
    	insert testLead;
		
		String expectedName = 	testLead.FirstName + ' ' + testLead.LastName + ' - Donation ' + system.today().format();
		
		Opportunity donation = [select Description, AccountID, Amount, CampaignID from Opportunity where Name = :expectedName limit 1];
		system.assertEquals (testLead.Donation_Amount__c, donation.Amount); 
		system.assertNotEquals (null, donation.AccountID); 
    }
    
    static testMethod void RecurringCCDonationTest()
    {
		ID donationRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Donation'].id;
    	Lead testLead = new Lead (FirstName = 'Test', LastName = 'Testing123', Company = 'TestAccount', EMail = 'test@test123.com', Status='Open - not converted', Donation_Amount__c=10, What_prompted_donation__c='Have asthma');
    	testLead.RecordTypeID=donationRecordType;
    	testLead.Type_of_donation__c = 'Regular Credit/Debit Card';
    	insert testLead;
		
		String expectedName = 	testLead.FirstName + ' ' + testLead.LastName + '%';
		
    	Contact createdContact = [select Landline_Opt_Out__c, Mobile_Opt_Out__c, Salutation, FirstName, Email, MobilePhone, AccountID from Contact where email=:testLead.Email limit 1];
      	System.Assert (createdContact.Landline_Opt_Out__c);
      	System.Assert (createdContact.Mobile_Opt_Out__c);

		npe03__Recurring_Donation__c donation = [select npe03__Contact__c, npe03__Amount__c from npe03__Recurring_Donation__c where Name LIKE :expectedName limit 1];
		system.assertEquals (testLead.Donation_Amount__c, donation.npe03__Amount__c); 
		system.assertNotEquals (null, donation.npe03__Contact__c); 
    }

    static testMethod void RecurringDDDonationTest()
    {
		ID donationRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Donation'].id;
    	Lead testLead = new Lead (FirstName = 'Test', LastName = 'Testing123', Company = 'TestAccount', EMail = 'test@test123.com', Status='Open - not converted', Donation_Amount__c=10, What_prompted_donation__c='Have asthma');
    	testLead.RecordTypeID=donationRecordType;
    	testLead.Type_of_donation__c = 'Regular Direct Debit';
    	insert testLead;
		
		String expectedName = 	testLead.FirstName + ' ' + testLead.LastName + '%';
		
		npe03__Recurring_Donation__c donation = [select npe03__Contact__c, npe03__Amount__c from npe03__Recurring_Donation__c where Name LIKE :expectedName limit 1];
		system.assertEquals (testLead.Donation_Amount__c, donation.npe03__Amount__c); 
		system.assertNotEquals (null, donation.npe03__Contact__c); 
    }
    
    static testMethod void ShopTest ()
    {
    	Product__c inhaler = new Product__c (Name='Inhaler', Max_quantity_per_order__c=5, Members_Price__c=20, 	Non_members_Price__c=30, Product_Ref__c='10007', Status__c='In Stock');
    	insert inhaler;
		ID shopRecordType = [select ID from RecordType where sObjectType='Lead' and Name='Shop'].id;
    	Lead testLead = new Lead (FirstName = 'Test', LastName = 'Testing123', Company = 'Self', EMail = 'test@test123.com', Status='Open - not converted', Postage_Packaging__c=3.5, Description='[{"line_item_label":"10007","quantity":"2.00"}]');
    	testLead.RecordTypeID=shopRecordType;
    	insert testLead;

		Sale__c oneSale = [select ID from Sale__c where Postage_Packaging__c=3.5];
		List<Sale_Item__c> items = [select ID, Product__r.Name, Quantity__c from Sale_Item__c where Sale_Order__c=:oneSale.id];
		system.assertEquals (2, items[0].Quantity__c); 	
		system.assertEquals ('Inhaler', items[0].Product__r.Name); 	
    }
 }