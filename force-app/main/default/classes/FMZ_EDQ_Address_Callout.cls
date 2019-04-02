/**
 * Created by samuelmeyers on 11/12/18.
 */

public class FMZ_EDQ_Address_Callout {
    private static final String EDQ_ADDRESS_VALIDATION_BASE_URL = 'https://api.edq.com/capture/address/v2/';
    private static final String EDQ_SEARCH_STRING = 'search';
    private static final String EDQ_FORMAT_STRING = 'format';
    private static final String EDQ_QUERY_STRING = 'query';
    private static final String EDQ_COUNTRY_STRING = 'country';
    private static final String EDQ_AUTH_TOKEN_STRING = 'auth-token';
    private static final String EDQ_ID_STRING = 'id';
    private static final String EDQ_SPACE_TOKEN = '%20';
    private static final String EDQ_DEFAULT_COUNTRY_CODE = 'USA';

    public static List<Match> getAddressMatches(String addressSearch) {
        String url = EDQ_ADDRESS_VALIDATION_BASE_URL + EDQ_SEARCH_STRING;
        url += '?' + EDQ_AUTH_TOKEN_STRING + '=' + Label.FMZ_EDQ_Auth_Token;
        url += '&' + EDQ_QUERY_STRING + '=' + addressSearch.trim().replace(' ', EDQ_SPACE_TOKEN);
        url += '&' + EDQ_COUNTRY_STRING + '=' + EDQ_DEFAULT_COUNTRY_CODE;

        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        // Send the request, and return a response
        HttpResponse res = h.send(req);

        JSONParser parser = JSON.createParser(res.getBody());
        List<Match> matches = new List<Match>();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Match m = (Match) parser.readValueAs(Match.class);
                        matches.add(m);
                    }
                }
            }
        }
        return matches;
    }

    public static Address getAddressFormat(String formatUrl) {
        String url = formatUrl + '&' + EDQ_AUTH_TOKEN_STRING + '=' + Label.FMZ_EDQ_Auth_Token;

        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        // Send the request, and return a response
        HttpResponse res = h.send(req);

        JSONParser parser = JSON.createParser(res.getBody());
        Address a = new Address();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if (parser.getText() == 'addressLine1') {
                    parser.nextToken();
                    a.addressLine1 = parser.getText();
                }else if (parser.getText() == 'locality') {
                    parser.nextToken();
                    a.city = parser.getText();
                }else if (parser.getText() == 'province') {
                    parser.nextToken();
                    a.state = parser.getText();
                }else if (parser.getText() == 'postalCode') {
                    parser.nextToken();
                    a.postalCode = parser.getText();
                }else if (parser.getText() == 'county1') {
                    parser.nextToken();
                    a.county = parser.getText();
                }else if (parser.getText() == 'country') {
                    parser.nextToken();
                    a.country = parser.getText();
                }
            }
        }
        
        a.validStatus = 'Verified by Experian';
        a.validTime = Datetime.now();

        return a;
    }

    public class Match {
        @AuraEnabled
        public String suggestion;

        @AuraEnabled
        public String format;

        public Match(String suggestion, String format){
            this.suggestion = suggestion;
            this.format = format;
        }
    }

    public class Address {
        @AuraEnabled
        public String addressLine1;

        @AuraEnabled
        public String city;

        @AuraEnabled
        public String county;

        @AuraEnabled
        public String state;

        @AuraEnabled
        public String country;

        @AuraEnabled
        public String postalCode;

        @AuraEnabled
        public String validStatus;

        @AuraEnabled
        public Datetime validTime;
    }
}