@isTest
public with sharing class TestPeriodClose {
 		
	static testmethod void test1(){
		cllease__Calendar__c  c = new cllease__Calendar__c();
		c.cllease__start_year__c = 2018;
		c.cllease__start_year_fiscal__c = 2018;
		c.cllease__start_month__c = 1;
		c.cllease__start_month__c = 1;
		c.cllease__start_day__c = 1;
		insert c;
		
		cllease__Period_Status__c p = new cllease__Period_Status__c();
		p.cllease__Calendar_Name__c = c.id;
		p.cllease__Period_Number__c = 1;
		p.cllease__status__c = 'Never Opened';
		p.cllease__start_date__c = date.valueOf('2018-01-01');
		p.cllease__end_date__c = date.valueOf('2018-01-31');
		p.cllease__quarter__c = 1;
		
		
		insert p;
		
		cllease__Period_Status__c p2 = new cllease__Period_Status__c();
		p2.cllease__Calendar_Name__c = c.id;
		p2.cllease__Period_Number__c = 1;
		p2.cllease__status__c = 'Never Opened';
		p2.cllease__start_date__c = date.valueOf('2018-02-01');
		p2.cllease__end_date__C = date.valueOf('2018-02-28');
		p2.cllease__quarter__c = 1;
		
		insert p2;
		
		p.cllease__status__c = 'Open';
		update p;
		
		
		p.cllease__status__c = 'Closed';
		update p;
		
		
 	}
}