public class BillAndChargeTriggerHandler
{
    public static final set<string> firstSet = new set<string>{'Estimated Property Tax', 'Service Fees', 'Insurance Fees', 'Late Fees', 'Finance Charge'};
    public static final set<string> secondSet = new set<string>{'Estimated Property Tax', 'Service Fees'};
    public static void afterinsertAndUpdate(Set<Id> clAccIds)
    {
        try
        {
            Map<ID, cllease__Lease_Account__c> parentLSConts = new  Map<ID, cllease__Lease_Account__c>();
            parentLSConts = new  Map<Id, cllease__Lease_Account__c>([SELECT
                id, 
                (SELECT
                    ID, 
                    cllease__Rental_Due_Amount__c, 
                    cllease__Tax_Due_Amount__c, 
                    cllease__Lease_Account__c, 
                    cllease__Rental_Paid_Amount__c
                FROM
                    cllease__Dues_Details__r
                WHERE
                    cllease__Due_Date__c = This_month AND cllease__Due_Date__c = This_Year), 
                (SELECT
                    ID, 
                    cllease__Lease_Account__c, 
                    cllease__Original_Amount__c, 
                    cllease__Fee_Definition__c, 
                    cllease__Fee_Definition__r.name  
                FROM
                    cllease__Charges__r
                WHERE
                    Createddate = This_month AND Createddate = This_Year AND cllease__Fee_Definition__r.name in: firstSet)
            FROM
                cllease__Lease_Account__c
            WHERE
                ID in: clAccIds]);
            list<cllease__Charge__c> chargeList = new  list<cllease__Charge__c>();
            list<cllease__Lease_account_Due_Details__c> dueList = new  list<cllease__Lease_account_Due_Details__c>();
            for(Id laId: parentLSConts.keyset())
            {
                cllease__Lease_Account__c myParentadd = parentLSConts.get(laId);
                chargeList.addAll(myParentadd.cllease__Charges__r);
                dueList.addAll(myParentadd.cllease__Dues_Details__r);
            }
            system.debug('======chargeList======' + chargeList);
            system.debug('======dueList======' + dueList);
            Map<Id, Map<integer, decimal>> chargeMap = new  Map<Id, Map<integer, decimal>>();
            Map<Id, Map<integer, decimal>> dueMap = new  Map<Id, Map<integer, decimal>>();
            for(cllease__Charge__c charge: chargeList)
            {
                if(firstSet.contains(charge.cllease__Fee_Definition__r.name))
                {
                    system.debug('=========first======');
                    if(chargeMap.containskey(charge.cllease__Lease_Account__c))
                    {
                        Map<integer, decimal> chargeMapChild = chargeMap.get(charge.cllease__Lease_Account__c);
                        if(chargeMapChild.containskey(1))
                        {
                            decimal d = chargeMapChild.get(1) + (charge.cllease__Original_Amount__c != null ? charge.cllease__Original_Amount__c : 0);
                            chargeMapChild.put(1, d);
                            chargeMap.put(charge.cllease__Lease_Account__c, chargeMapChild);
                        }
                        else
                        {
                            chargeMapChild.put(1, (charge.cllease__Original_Amount__c != null ? charge.cllease__Original_Amount__c : 0));
                            chargeMap.put(charge.cllease__Lease_Account__c, chargeMapChild);
                        }
                    }
                    else
                    {
                        Map<integer, decimal> chargeMapChild = new  Map<integer, decimal>();
                        chargeMapChild.put(1, (charge.cllease__Original_Amount__c != null ? charge.cllease__Original_Amount__c : 0));
                        chargeMap.put(charge.cllease__Lease_Account__c, chargeMapChild);
                    }
                    system.debug('=========first if chargeMap======' + chargeMap);
                }
                if(secondSet.contains(charge.cllease__Fee_Definition__r.name))
                {
                    system.debug('=========second======');
                    if(chargeMap.containskey(charge.cllease__Lease_Account__c))
                    {
                        Map<integer, decimal> chargeMapChild = chargeMap.get(charge.cllease__Lease_Account__c);
                        if(chargeMapChild.containskey(2))
                        {
                            decimal d = chargeMapChild.get(2) + (charge.cllease__Original_Amount__c != null ? charge.cllease__Original_Amount__c : 0);
                            chargeMapChild.put(2, d);
                            chargeMap.put(charge.cllease__Lease_Account__c, chargeMapChild);
                        }
                        else
                        {
                            chargeMapChild.put(2, (charge.cllease__Original_Amount__c != null ? charge.cllease__Original_Amount__c : 0));
                            chargeMap.put(charge.cllease__Lease_Account__c, chargeMapChild);
                        }
                    }
                    else
                    {
                        Map<integer, decimal> chargeMapChild = new  Map<integer, decimal>();
                        chargeMapChild.put(2, (charge.cllease__Original_Amount__c != null ? charge.cllease__Original_Amount__c : 0));
                        chargeMap.put(charge.cllease__Lease_Account__c, chargeMapChild);
                    }
                    system.debug('=========second if chargeMap======' + chargeMap);
                }
            }
            for(cllease__Lease_account_Due_Details__c due: dueList)
            {
                if(dueMap.containskey(due.cllease__Lease_Account__c))
                {
                    Map<integer, decimal> dueMapChild = dueMap.get(due.cllease__Lease_Account__c);
                    dueMapChild.put(1, dueMapChild.get(1) + (due.cllease__Rental_Due_Amount__c != null ? due.cllease__Rental_Due_Amount__c : 0));
                    dueMapChild.put(2, dueMapChild.get(2) + (due.cllease__Tax_Due_Amount__c != null ? due.cllease__Tax_Due_Amount__c : 0));
                    dueMapChild.put(3, dueMapChild.get(3) + (due.cllease__Rental_Paid_Amount__c != null ? due.cllease__Rental_Paid_Amount__c : 0));
                    dueMap.put(due.cllease__Lease_Account__c, dueMapChild);
                }
                else
                {
                    Map<integer, decimal> dueMapChild = new  Map<integer, decimal>();
                    dueMapChild.put(1, (due.cllease__Rental_Due_Amount__c != null ? due.cllease__Rental_Due_Amount__c : 0));
                    dueMapChild.put(2, (due.cllease__Tax_Due_Amount__c != null ? due.cllease__Tax_Due_Amount__c : 0));
                    dueMapChild.put(3, (due.cllease__Rental_Paid_Amount__c != null ? due.cllease__Rental_Paid_Amount__c : 0));
                    dueMap.put(due.cllease__Lease_Account__c, dueMapChild);
                }
            }
            system.debug('======dueMap======' + dueMap);
            system.debug('======chargeMap======' + chargeMap);
            List<cllease__Lease_Account__c> updateLeaseAccList = new  List<cllease__Lease_Account__c>();
            for(Id laId1: parentLSConts.keyset())
            {
                decimal dec1 = 0;
                decimal dec2 = 0;
                decimal dec3 = 0;
                decimal dec4 = 0;
                decimal dec5 = 0;
                if(dueMap.containskey(laId1))
                {
                    Map<integer, decimal> dueMapChild = dueMap.get(laId1);
                    dec1 = dueMapChild.get(1);
                    dec2 = dueMapChild.get(2);
                    dec5 = dueMapChild.get(3);
                }
                if(chargeMap.containskey(laId1))
                {
                    Map<integer, decimal> chargeMapChild = chargeMap.get(laId1);
                    dec3 = (chargeMapChild.containskey(1) ? chargeMapChild.get(1) : 0);
                    dec4 = (chargeMapChild.containskey(2) ? chargeMapChild.get(2) : 0);
                }
                updateLeaseAccList.add(new  cllease__Lease_Account__c(Id = laId1,
                                                                      Due_This_Period_Conga__c = dec1 + dec3,
                                                                      Payment_Amount_Conga__c = dec1 + dec4,
                                                                      Tax_Conga__c = dec2 + dec4, 
                                                                      Applied_Amount_Conga__c = dec5));
            }
            Update updateLeaseAccList;
        }
        catch(Exception e)
        {
            System.debug('!!!Exception' + e.getMessage());
        }
    }
}