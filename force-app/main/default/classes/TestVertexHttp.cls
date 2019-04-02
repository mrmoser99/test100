public class TestVertexHttp {
    public static void vertex() {
        String httpBody =   ' <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:vertexinc:o-series:tps:8:0"> '+
'    <soapenv:Header/>                                                                                                    '+
'    <soapenv:Body>                                                                                                       '+
'       <urn:VertexEnvelope>                                                                                              '+
'          <urn:Login>                                                                                                    '+
'             <!--Optional:-->                                                                                            '+
'             <urn:UserName>Testuser07</urn:UserName>                                                                      '+
'             <!--Optional:-->                                                                                            '+
'             <urn:Password>Welcome0824</urn:Password>                                                                   '+
'             <!--Optional:-->                                                                                            '+
'          </urn:Login>                                                                                                   '+
'          <urn:InvoiceRequest documentDate="2018-3-4" transactionType="LEASE">                                           '+     
'         <urn:Seller>                                                                                                    '+
'             <urn:Company>DLLOS</urn:Company>                                                                            '+
'         </urn:Seller>                                                                                                   '+
'         <urn:LineItem lineItemId="CHG-00007196">                                                                        '+
'             <urn:Customer>                                                                                              '+
'                 <urn:Destination>                                                                                       '+
'                     <urn:City>Washington</urn:City>                                                                     '+
'                     <urn:MainDivision>DC</urn:MainDivision>                                                             '+
'                     <urn:ZipCode>20500-0005</urn:ZipCode>                                                               '+
'                 </urn:Destination>                                                                                      '+
'             </urn:Customer>                                                                                             '+
'             <urn:ExtendedPrice>100.00</urn:ExtendedPrice>                                                               '+
'             <urn:FlexibleFields>                                                                                        '+
'                 <urn:FlexibleCodeField fieldId="1">INV</urn:FlexibleCodeField>                                          '+
'                 <urn:FlexibleCodeField fieldId="2">FMV</urn:FlexibleCodeField>                                          '+
'                 <urn:FlexibleCodeField fieldId="3">ST</urn:FlexibleCodeField>                                           '+
'                 <urn:FlexibleCodeField fieldId="4">A</urn:FlexibleCodeField>                                            '+
'                 <urn:FlexibleCodeField fieldId="5">I</urn:FlexibleCodeField>                                            '+
'                 <urn:FlexibleCodeField fieldId="6">Stream</urn:FlexibleCodeField>                                       '+
'                 <urn:FlexibleCodeField fieldId="7">N</urn:FlexibleCodeField>                                            '+
'                 <urn:FlexibleCodeField fieldId="8">N</urn:FlexibleCodeField>                                            '+
'                 <urn:FlexibleCodeField fieldId="9">CLS-cllease__Charge__c</urn:FlexibleCodeField>                       '+
'                 <urn:FlexibleCodeField fieldId="10">0</urn:FlexibleCodeField>                                           '+
'                 <urn:FlexibleCodeField fieldId="11">CEP-0000000807</urn:FlexibleCodeField>                              '+
'                 <urn:FlexibleCodeField fieldId="12">CLS-cllease__Charge__c</urn:FlexibleCodeField>                      '+
'                 <urn:FlexibleCodeField fieldId="13">F</urn:FlexibleCodeField>                                           '+
'                 <urn:FlexibleCodeField fieldId="14">F</urn:FlexibleCodeField>                                           '+
'                 <urn:FlexibleCodeField fieldId="15">RENT</urn:FlexibleCodeField>                                        '+
'                 <urn:FlexibleCodeField fieldId="16">N/A</urn:FlexibleCodeField>                                         '+
'                 <urn:FlexibleCodeField fieldId="17">LES-0000000749</urn:FlexibleCodeField>                              '+
'                 <urn:FlexibleCodeField fieldId="18">0</urn:FlexibleCodeField>                                           '+
'                 <urn:FlexibleNumericField fieldId="1">30</urn:FlexibleNumericField>                                     '+
'                 <urn:FlexibleNumericField fieldId="2">0</urn:FlexibleNumericField>                                      '+
'                 <urn:FlexibleNumericField fieldId="3">0</urn:FlexibleNumericField>                                      '+
'                 <urn:FlexibleNumericField fieldId="4">0</urn:FlexibleNumericField>                                      '+
'                 <urn:FlexibleNumericField fieldId="5">0</urn:FlexibleNumericField>                                      '+
'                 <urn:FlexibleDateField fieldId="1">2018-3-4</urn:FlexibleDateField>                                     '+
'             </urn:FlexibleFields>                                                                                       '+
'         </urn:LineItem>                                                                                                 '+
'     </urn:InvoiceRequest>                                                                                               '+
'       </urn:VertexEnvelope>                                                                                             '+
'    </soapenv:Body>                                                                                                      '+
' </soapenv:Envelope>                                                                                                     ';


String httpUrl = 'https://dllgroup.ondemand.vertexinc.com/vertex-ws/services/CalculateTax80';
//String httpUrl = 'http://demo0027.vertexinc.com:80/vertex-ws/services/LookupTaxAreas80';
Http http = new Http();
HttpRequest req = new HttpRequest();
req.setMethod('POST');
req.setEndpoint(httpUrl);
req.setHeader('Content-Type', 'text/xml');
req.setBody(httpBody);
HttpResponse res = http.send(req);
System.debug('Response: '+res.getBody());
System.debug('Response getStatus(): '+res.getStatus());
System.debug('Response header keys: ');
for(String keyStr : res.getHeaderKeys()) {
    System.debug('key: '+keyStr+'   value: '+res.getHeader(keyStr));
}

    }
}