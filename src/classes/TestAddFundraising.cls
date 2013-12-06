@isTest
private class TestAddFundraising 
{
    static testMethod void fundRaisingTest() 
    {
    	Account org = new Account (Name='TestAccount');
    	insert org;
    	Contact testPerson = new Contact (LastName = 'me', AccountID=org.ID);
    	insert testPerson;
    	Fundraising__c fund = new Fundraising__c (Contact__c = testPerson.Id);
    	insert fund;
    	
    	Fundraising__c resultFund = [select ID, Organisation__c from Fundraising__c where ID=:fund.id limit 1];
    	System.assertEquals (org.id, resultFund.Organisation__c);
    }
}