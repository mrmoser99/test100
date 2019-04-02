global class MockHttpResponseGenerator implements HttpCalloutMock {
     public HTTPResponse respond(HTTPRequest req)
        {         
          HttpResponse resp = new HttpResponse();
          resp.setStatusCode(200);
          resp.setStatus('OK');       
          resp.setBody('{"access_token":"00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY.cDC5L4E6PKbsIQ4cBRJD8FXmyrRuxpIOSOY8jZjHAX7KzUUB","instance_url":"https://ap2.salesforce.com","id":"https://login.salesforce.com/id/00D280000018HvvEAE/00528000001kQShAAM","token_type":"Bearer","issued_at":"1484826597893","signature":"Fi7S9LKkcQy7W84CtIME4IjJCQtWhg3NQ1TFx4KAawc="}');

          return resp;
      }
  
}