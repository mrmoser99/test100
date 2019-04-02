Global class VertexGetUpfrontTax
{
  /*WebService static String VertexGetUpfrontTax(string applicationid)
    {
        DOM.Document doc = new DOM.Document();
        map<id,decimal> upfronttaxduemap = new map<id,decimal>();
        
        List<genesis__Application_Equipment__c> appequipslist = new List<genesis__Application_Equipment__c>();
        List<genesis__Application_Equipment__c> appequipslistwithoutupfront = new List<genesis__Application_Equipment__c>();
        List<genesis__Application_Equipment__c> appequipslistwithandwithoutupfront = [select id,Name,
                                                             genesis__Estimated_Selling_Price__c,
                                                             genesis__Application__r.name,
                                                             genesis__Application__r.genesis__Payment_Amount__c,
                                                             genesis__Application__r.genesis__Term__c,
                                                             genesis__Application__r.genesis__Expected_Start_Date__c,
                                                             genesis__Equipment__r.name,
                                                             City__c,ZipCode__c,Vertex_State__c,Upfront_Tax_Amount__c,
                                                             genesis__Application__r.Transaction_Code__c,
                                                             genesis__Application__r.Lease_Type__c,
                                                             genesis__Application__r.Contract_Type__c,
                                                             genesis__Application__r.Total_Upfront_Tax_Amount__c,
                                                             Tax_Payment_Type__c,Upfront_Tax_Processed__c,
                                                             Override_Upfront_Tax_Flag__c,Upfront_Tax_Basis__c
                                                             from genesis__Application_Equipment__c
                                                             where genesis__Application__r.id=:applicationid];
        
        system.debug('@@@@@@@' + appequipslistwithandwithoutupfront);
        system.debug('@@@@@@@' + appequipslistwithoutupfront);
        system.debug('@@@@@@@' + appequipslist);
           
        for(genesis__Application_Equipment__c genappequip:appequipslist)
          {
          if(genappequip.Override_Upfront_Tax_Flag__c=='Yes')
             {
               genappequip.Upfront_Tax_Amount__c=0;
               genappequip.Upfront_Tax_Processed__c=true;
               appequipslistwithoutupfront.add(genappequip);
                }
            else if(genappequip.Override_Upfront_Tax_Flag__c=='No' && genappequip.Upfront_Tax_Processed__c!=true)
                 {
                 appequipslist.add(genappequip);
                 }    
              }
              update appequipslistwithoutupfront; 
              update appequipslist;
              system.debug('@@@@@@@2' + appequipslist); 
            
            dom.Document methoddoc=VertexUtil.FramingXMLReQuest(appequipslistwithandwithoutupfront);
        	system.debug('methoddocccccccc'+methoddoc.toXMlString());
            HttpRequest req = new HttpRequest();
        	req.setMethod('POST');
        	req.setEndpoint('http://demo0027.vertexinc.com:80/vertex-ws/services/CalculateTax80');
         	req.setHeader('Content-Type','text/xml');
        	req.setBody(methoddoc.toXMlString());
        
        	Http http = new Http();
        	HttpResponse res = http.send(req);
        	System.assertEquals(200, res.getStatusCode());
        	 map<string,decimal>valuesmap = new map<string,decimal>();
        string responsedocumentnumber;
        Dom.Document doc1 = new Dom.Document();
        doc1.load(res.getbody());
        DOM.XMLNode root = doc1.getRootElement(); 
           for (Dom.XMLNode child: root.getChildren()) {
            for (Dom.XMLNode grandchild: child.getChildren()) {
              for (Dom.XMLNode grandchild1: grandchild.getChildren()) {
               for (Dom.XMLNode grandchild2: grandchild1.getChildren()) {
                  for (Dom.XMLNode grandchild3: grandchild2.getChildren()) {
                       if(grandchild2.getName()=='LineItem' && grandchild3.getName()=='TotalTax')
                              {
                              valuesmap.put(grandchild2.getAttributeValue(grandchild2.getAttributeKeyAt(0), grandchild2.getAttributeKeyNsAt(0)),decimal.valueOf(grandchild3.getText().trim()));
                              system.debug('Mappppppppppp' + valuesmap);
                              }
                             }
                           }
                         }  
                       }
                     }  
            for(genesis__Application_Equipment__c appequip:appequipslist )  
                     {
                   appequip.Upfront_Tax_Amount__c=valuesmap.get(appequip.name);
                   appequip.Upfront_Tax_Processed__c=true;
                   appequip.genesis__Application__r.Total_Upfront_Tax_Amount__c+=appequip.Upfront_Tax_Amount__c;
                   upfronttaxduemap.put(appequip.genesis__Application__r.id,appequip.genesis__Application__r.Total_Upfront_Tax_Amount__c);    
                   system.debug('@@@@@@' + appequip.Upfront_Tax_Amount__c);
                        }
                        
                   list<genesis__Applications__c> appslist = [select id,Total_Upfront_Tax_Amount__c from genesis__Applications__c where id IN:upfronttaxduemap.keyset()];           
                   list<genesis__Applications__c> appslisttobeupdated= new list<genesis__Applications__c>();
                   for(genesis__Applications__c app:appslist)    
                        {
                        app.Total_Upfront_Tax_Amount__c=upfronttaxduemap.get(app.id);
                        appslisttobeupdated.add(app);
                        }
                        
                     update appequipslist; 
                     update appslisttobeupdated;
                     
                      system.debug('Old Listtttttttttttt' + appequipslist);  
                      system.debug('New Listttttttttt' + appslisttobeupdated);       
           
            return 'Tax Calculation Processed Successfully';   
      }   */ 
      
    }