public with sharing class MarkDonationsPostedController 
{
	private List<Opportunity> donationList;
	
	public MarkDonationsPostedController(ApexPages.StandardSetController stdSetController) 
	{
    	donationList = (List<Opportunity>)stdSetController.getSelected();
		Initialise();
	}
	
	public MarkDonationsPostedController(Integer testSize)
	{
		donationList = [select ID from Opportunity limit :testSize];
		Initialise();
	}

	public void Initialise ()
	{
    	donationList = [select ID, Name, Account.Name, CloseDate, Amount, StageName from Opportunity where id in :donationList];
	}	
	
	public pageReference markPosted ()
	{
		for (Integer i=0; i<donationList.size(); i++)
		{
			donationList[i].StageName = 'Posted';
		}
		update donationList;
		Pagereference returnPage = new Pagereference ('/006');
		return returnPage;
	}
	
	public static testMethod void testRows ()
	{
		ID donationType = [select ID from RecordType where Name='Donation' limit 1].id;
    	Lead testLead = new Lead (FirstName = 'Test', LastName = 'Testing123', Company = 'TestAccount', EMail = 'test@test123.com', Status='Open - not converted', Donation_Amount__c=10, RecordTypeID=donationType);
    	insert testLead;
		
    	Lead testLead2 = new Lead (FirstName = 'Test', LastName = 'Testing123', Company = 'TestAccount', EMail = 'test@test123.com', Status='Open - not converted', Donation_Amount__c=10, RecordTypeID=donationType);
    	insert testLead2;

 		MarkDonationsPostedController pc = new MarkDonationsPostedController(2);
 		pc.markPosted();
 	}

	public static testMethod void testDefaultDonation ()
	{
		Contact donor = new Contact (LastName='Me');
		insert donor;
		
 		Opportunity donation = new Opportunity (Name='Single', CloseDate=system.today(), StageName='Pledged');
 		insert donation;

 		MarkDonationsPostedController pc = new MarkDonationsPostedController(2);
 		pc.markPosted();
 	}
}