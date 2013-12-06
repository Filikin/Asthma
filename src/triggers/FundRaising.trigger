trigger FundRaising on Fundraising__c (before insert) 
{
	TriggerDispatcher.MainEntry ('Fundraising', trigger.isBefore, trigger.isDelete, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isExecuting,
		trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
}