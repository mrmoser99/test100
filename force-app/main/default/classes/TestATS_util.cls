@isTest
public class TestATS_util {
    
    static TestMethod void ATS_util1() {
        
        ATS_util.address address1 = new ATS_util.address('addressLine1', 'city', 'state', 'postalCode');
        ATS_util.lessee ats = new ATS_util.lessee('testname', '1234567898', address1);
        ATS_util.cost cost1 = new ATS_util.cost('costTypeCode', 200.00);
        list<ATS_util.cost> licost = new list<ATS_util.cost>();
        ATS_util.asset asset = new ATS_util.asset('assetDescription', 100,'manufacturer', licost);
        ATS_util.structure structure = new ATS_util.structure('purchaseOption', 10, 'frequency', 1000.00, 12.00,300.00);        

        
        
    }

}