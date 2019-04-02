/**
 * Created by samuelmeyers on 11/26/18.
 */
@isTest
global with sharing class FMZ_EDQAddressCalloutMock implements HttpCalloutMock{

    private string mockSearchResponse = '{"totalMatches": 2,'+
            '"count": 2,'+
            '"results": [{"suggestion": "10 Main, Bethel PA 19507",'+
            '"matched": [[3,7],[0,2]],'+
            '"format": "https://api.edq.com/capture/address/v2/format?country=USA&id=b83c0b90-b221-48db-a877-b6cf06f857d9_U40_24_0_0_0%3D10%24QL7%24GEO0"},'+
            '{"suggestion": "10 Main, Carmel NY 10512",'+
            '"matched": [[19,21],[3,7],[0,2]],'+
            '"format": "https://api.edq.com/capture/address/v2/format?country=USA&id=acc85af6-f9d7-484e-89f0-10ecc0de5e79_U40_24_0_0_0%3D10%24QL7%24GEO0"}]}';

    private string mockFormatResponse = '{"address": [{'+
            '"addressLine1": "10 Main"},{"addressLine2": ""},{"addressLine3": ""},{"locality": "Bethel"},{"province": "PA"},'+
            '{"postalCode": "19507-8904"},{"country": "UNITED STATES OF AMERICA"}],'+
            '"components": [{"streetNumber1": "10"},{"street1": "Main"},{"locality1": "Bethel"},{"county1": "Berks"},'+
            '{"provinceCode1": "PA"},{"postalCode1": "19507-8904"},{"country1": "UNITED STATES OF AMERICA"},{"countryISO1": "USA"}],'+
            '"metadata": {"dpv": {"cmraIndicator": " ","seedIndicator": "N","dpvIndicator": "N","footnotes": ["AA","M3"],'+
            '"vacancyIndicator": " ","noStatsIndicator": " ","pbsaIndicator": " "}}}';

    global HTTPResponse respond(HTTPRequest req) {
        String requestUrl = req.getEndpoint();

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(requestUrl.contains('search')){
            res.setBody(mockSearchResponse);
            res.setStatusCode(200);
        }else if(requestUrl.contains('format')){
            res.setBody(mockFormatResponse);
            res.setStatusCode(200);
        }else{
            System.assert(false, 'Unhandled Mock Callout');
        }
        return res;
    }

}