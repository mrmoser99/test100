@isTest
global class Mock_ATS_ResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id": "5dfc1a9e-4cb3-4dd0-8c1e-6aa514048f5d","title": "success","message": "Credit application successfully received for partnerOrderId: bd8df8c2-815e-400b-ba4d-0a7fd4f14014"}');
        res.setStatusCode(200);
        return res;
    }
}