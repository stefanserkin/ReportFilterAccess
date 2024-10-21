public class FolderShareUtil {

    public static List<User> getSharedUsers(String folderFullName) {
        List<User> users = new List<User>();

        HttpRequest req = new HttpRequest();
        // Use getOrgDomainUrl() to get the base URL of your Salesforce org
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/m/61.0');  // Adjust for API version 61.0
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        
        req.setHeader('SOAPAction', '""'); // Correctly set the SOAPAction header with an empty value
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());  // Use session ID for authorization

        // Adjust the Metadata API SOAP XML payload for a correct folder name
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
            'xmlns:met="http://soap.sforce.com/2006/04/metadata">' +
            '<soapenv:Header>' +
            '<met:SessionHeader>' +
            '<met:sessionId>' + UserInfo.getSessionId() + '</met:sessionId>' +
            '</met:SessionHeader>' +
            '</soapenv:Header>' +
            '<soapenv:Body>' +
            '<met:readMetadata>' +
            '<met:type>ReportFolder</met:type>' +
            '<met:fullName>' + folderFullName + '</met:fullName>' + // Ensure the fullName is accurate
            '</met:readMetadata>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';

        req.setBody(body);

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Debug the full response body for further inspection
        System.debug('Full Response Body: ' + res.getBody());

        // Parse the response to extract folder shares
        if (res.getStatusCode() == 200) {
            List<String> usernames = new List<String>();
            // Sample logic to parse XML response
            Dom.Document doc = new Dom.Document();
            doc.load(res.getBody());
            
            Dom.XMLNode envelopeNode = doc.getRootElement();
            Dom.XMLNode bodyNode = envelopeNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode responseNode = bodyNode.getChildElement('readMetadataResponse', null);
            Dom.XMLNode resultNode = responseNode.getChildElement('result', null);
            Dom.XMLNode folderNode = resultNode.getChildElement('records', null);
            
            // Extract folder name
            String folderName = folderNode.getChildElement('name', null).getText();
            System.debug('Folder Name: ' + folderName);

            // Extract folder shares
            for (Dom.XMLNode folderShareNode : folderNode.getChildElements()) {
                if (folderShareNode.getName() == 'folderShares') {
                    String accessLevel = folderShareNode.getChildElement('accessLevel', null).getText();
                    String sharedTo = folderShareNode.getChildElement('sharedTo', null).getText();
                    String sharedToType = folderShareNode.getChildElement('sharedToType', null).getText();
                    
                    System.debug('Access Level: ' + accessLevel);
                    System.debug('Shared To: ' + sharedTo);
                    System.debug('Shared To Type: ' + sharedToType);
                    usernames.add(sharedTo);
                }
            }
            System.debug('usernames --> ' + usernames);
            users = getUsersFromUsernames(usernames);
        } else {
            System.debug('Failed with status code: ' + res.getStatusCode());
        }
        return users;
    }

    private static List<User> getUsersFromUsernames(List<String> usernames) {
        return [
            SELECT Id, Username, Name
              FROM User 
             WHERE Username IN :usernames
              WITH USER_MODE
        ];
    }



    public static void callMetadataAPI() {
        HttpRequest req = new HttpRequest();
        
        // Use getOrgDomainUrl() to get the base URL of your Salesforce org
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/m/61.0');  // Adjust for API version 61.0
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        
        req.setHeader('SOAPAction', '""'); // Correctly set the SOAPAction header with an empty value
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());  // Use session ID for authorization

        // Adjust the Metadata API SOAP XML payload for a correct folder name
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
            'xmlns:met="http://soap.sforce.com/2006/04/metadata">' +
            '<soapenv:Header>' +
            '<met:SessionHeader>' +
            '<met:sessionId>' + UserInfo.getSessionId() + '</met:sessionId>' +
            '</met:SessionHeader>' +
            '</soapenv:Header>' +
            '<soapenv:Body>' +
            '<met:readMetadata>' +
            '<met:type>ReportFolder</met:type>' +
            '<met:fullName>stoplying__SecretReports</met:fullName>' + // Ensure the fullName is accurate
            '</met:readMetadata>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';

        req.setBody(body);

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Debug the full response body for further inspection
        System.debug('Full Response Body: ' + res.getBody());

        // Parse the response to extract folder shares
        if (res.getStatusCode() == 200) {
            try {
                // Load the response body into the DOM document for parsing
                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
                
                // Get the root element (Envelope)
                Dom.XMLNode envelopeNode = doc.getRootElement();
                if (envelopeNode == null) {
                    System.debug('Envelope node is null.');
                    return;
                }
                
                // Get the Body element (make sure to use the correct namespace)
                Dom.XMLNode bodyNode = envelopeNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                if (bodyNode == null) {
                    System.debug('Body node is null.');
                    return;
                }
                
                // Get the readMetadataResponse element (use the Metadata namespace)
                Dom.XMLNode responseNode = bodyNode.getChildElement('readMetadataResponse', 'http://soap.sforce.com/2006/04/metadata');
                if (responseNode == null) {
                    System.debug('readMetadataResponse node is null.');
                    return;
                }
                
                // Get the result element (again using the Metadata namespace)
                Dom.XMLNode resultNode = responseNode.getChildElement('result', 'http://soap.sforce.com/2006/04/metadata');
                if (resultNode == null) {
                    System.debug('result node is null.');
                    return;
                }
                
                // Iterate through all child elements under the records node
                for (Dom.XMLNode node : resultNode.getChildElements()) {
                    // We're looking for the records element with the xsi:type of ReportFolder
                    if (node.getName() == 'records' && node.getAttribute('xsi:type', null) == 'ReportFolder') {
                        System.debug('Found the records node with xsi:type ReportFolder.');

                        // Extract folder name
                        Dom.XMLNode folderNameNode = node.getChildElement('name', null);
                        if (folderNameNode == null) {
                            System.debug('Folder name node is null.');
                        } else {
                            String folderName = folderNameNode.getText();
                            System.debug('Folder Name: ' + folderName);
                        }

                        // Extract folder shares
                        for (Dom.XMLNode folderShareNode : node.getChildElements()) {
                            if (folderShareNode.getName() == 'folderShares') {
                                Dom.XMLNode accessLevelNode = folderShareNode.getChildElement('accessLevel', null);
                                Dom.XMLNode sharedToNode = folderShareNode.getChildElement('sharedTo', null);
                                Dom.XMLNode sharedToTypeNode = folderShareNode.getChildElement('sharedToType', null);

                                String accessLevel = (accessLevelNode != null) ? accessLevelNode.getText() : 'Unknown';
                                String sharedTo = (sharedToNode != null) ? sharedToNode.getText() : 'Unknown';
                                String sharedToType = (sharedToTypeNode != null) ? sharedToTypeNode.getText() : 'Unknown';
                                
                                System.debug('Access Level: ' + accessLevel);
                                System.debug('Shared To: ' + sharedTo);
                                System.debug('Shared To Type: ' + sharedToType);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Error parsing response: ' + e.getMessage());
            }
        } else {
            System.debug('Failed with status code: ' + res.getStatusCode());
        }
    }
    
}
