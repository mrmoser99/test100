@isTest
global class Mock_ATS_TokenGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://api.dllgroup.com/oauth/token', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJbaW52YWxpZCBmaWVsZF0iLCJzY3AiOiJjcmVhdGVfYW5kX21hbmFnZV9maW5hbmNpYWxfY29udHJhY3RzIiwidmVyIjoiMS4wIiwiaXNzIjoiZXh0ZXJuYWxnYXRld2F5LmRsbC5jb3JwIiwib2lkIjoiW2ludmFsaWQgZmllbGRdIiwiZ2l2ZW5fbmFtZSI6Ik5vIExEQVAiLCJ0aWQiOiJbaW52YWxpZCBmaWVsZF0iLCJhdWQiOiJbaW52YWxpZCBmaWVsZF0iLCJhY3IiOiIxIiwidXBuIjoiTm8gTERBUCIsInVuaXF1ZV9uYW1lIjoiTm8gTERBUCIsIm5iZiI6MTUxODM1MTA1MywiYXBwaWRhY3IiOiIwIiwiYXBwaWQiOiJkYWJiNzAyZC1jNTlhLTQ5YTMtOTMwZi1iZjc1Zjg5NWYwYjQiLCJleHAiOjE1MTg5NTU4NTMsImlhdCI6MTUxODM1MTA1MywiZmFtaWx5X25hbWUiOiJObyBMREFQIn0.erqVtqqUdzIfnwBAJ_b-eYzun0ahJCCtM3NAwJV_bv5Yd1qP7lhSMsDxVtPupGYGfLgc0DlyIAJrRaMlJ1OxSTL1SbNoJZjeF0Z-W60JywnjdGsPP-mg-ARyPN0jKL0whcehfE6PjAkEfjW8_HkzFAZ6qn1ls-rhTvmyQQIto-hJcZ7VQAyQs8k6YjYIw42iEB-TBDzjuPiYV5_dftEDMdCr5apCUZoZAaOWGg6Y-7NZoahWEcVASvQtW7QkrOGGrhAp9ZXLoKBav-GLJWUDP-gfyxzl7hqAhzZQgTWtHw9xvE-a_s6i-5NAoJeTwRbG3NuB0blsvD9Q9noc0FDLhw","token_type": "Bearer","expires_in": "604800","expires_on": "1518955853","resource": "DLL corp","refresh_token": "3pd4KvkxkV51l5T9lCQGDlJnqsstack8M8oItEZFUK6p5y","scope": "create_and_manage_financial_contracts"}');
        res.setStatusCode(200);
        return res;
    }
}